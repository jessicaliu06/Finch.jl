mutable struct GalleyOptimizer
    estimator
    verbose
end

Base.:(==)(a::GalleyOptimizer, b::GalleyOptimizer) = a.verbose == b.verbose && a.estimator == b.estimator
Base.hash(a::GalleyOptimizer, h::UInt) = hash(GalleyOptimizer, hash(a.verbose, hash(a.estimator, h)))

GalleyOptimizer(; verbose = false, estimator=DCStats) = GalleyOptimizer(estimator, verbose)

function (ctx::GalleyOptimizer)(prgm)
    finch_mode = ctx.verbose ? :safe : :fast
    verbosity = ctx.verbose ? 3 : 0
    produce_node = prgm.bodies[end]
    output_vars = [Alias(a.name) for a in produce_node.args]
    galley_prgm = Plan(finch_hl_to_galley(normalize_hl(prgm))...)
    tns_inits, instance_prgm = galley(galley_prgm, ST=ctx.estimator, output_aliases=output_vars, verbose=verbosity, output_program_instance=true)
    timer_idx = 1
    julia_prgm = :()
    if operation(instance_prgm) == Finch.block
        for body in instance_prgm.bodies
            if ctx.verbose 
                timer_symbol = Symbol("t_$timer_idx")
                julia_prgm = :($julia_prgm;
                                $timer_symbol = time(); 
                                @finch mode=$(QuoteNode(finch_mode)) begin $(finch_unparse_program(nothing, body)) end;
                                println("Kernel ", $timer_idx, " Runtime: $(time() - $timer_symbol)"))
                timer_idx += 1
            else
                julia_prgm = :($julia_prgm; @finch mode=$(QuoteNode(finch_mode)) begin $(finch_unparse_program(nothing, body)) end)
            
            end
        end
    else
        julia_prgm = :(@finch mode=$(QuoteNode(finch_mode)) begin $(finch_unparse_program(nothing, instance_prgm)) end)
    end
    for init in tns_inits
        julia_prgm = :($init; $julia_prgm)
    end
    julia_prgm = :($julia_prgm; return Tuple([$([v.name for v in output_vars]...)]))
    julia_prgm
end

function Finch.set_options(ctx::GalleyOptimizer; estimator=DCStats, verbose=false)
    ctx.estimator=estimator
    ctx.verbose=verbose
    return ctx
end

"""
    get_stats_dict(ctx::GalleyOptimizer, prgm)

Returns a dictionary mapping the location of input tensors in the program to their statistics objects.
"""
function get_stats_dict(ctx::GalleyOptimizer, prgm)
    deferred_prgm = Finch.defer_tables(:prgm, prgm)
    expr_stats_dict = Dict()
    for node in PostOrderDFS(deferred_prgm)
        if node.kind == table
            expr_stats_dict[node.tns.ex] = ctx.estimator(node.tns.imm, [i.name for i in node.idxs])
        end
    end
    return expr_stats_dict
end

"""
    GalleyExecutor(ctx::GalleyOptimizer, tag=:global, verbose=false)

Executes a logic program by compiling it with the given compiler `ctx`. Compiled
codes are cached for each program structure. If the 'tag' argument is ':global', it maintains a set of plans 
for inputs with different sparsity structures. In this case, it first checks the cache for a plan that
was compiled for similar inputs and only compiles if it doesn't find one. If the `tag` argument is anything else,
it will only compile once for that tag and will skip this search process.
"""
@kwdef struct GalleyExecutor
    ctx::GalleyOptimizer
    tag
    verbose
end

Base.:(==)(a::GalleyExecutor, b::GalleyExecutor) = a.ctx == b.ctx && a.verbose == b.verbose
Base.hash(a::GalleyExecutor, h::UInt) = hash(GalleyExecutor, hash(a.ctx, hash(a.verbose, h)))

GalleyExecutor(ctx::GalleyOptimizer; tag = :global, verbose = false) = GalleyExecutor(ctx, tag, verbose)
function Finch.set_options(ctx::GalleyExecutor; tag = ctx.tag, verbose = ctx.verbose, kwargs...)
    GalleyExecutor(Finch.set_options(ctx.ctx; verbose=verbose, kwargs...), tag, verbose)
end

galley_codes = Dict()
function (ctx::GalleyExecutor)(prgm)
    (f, code) = if ctx.tag == :global
        cur_stats_dict = get_stats_dict(ctx.ctx, prgm)
        stats_list = get!(galley_codes, (ctx.ctx, ctx.tag, Finch.get_structure(prgm)), [])
        valid_match = nothing
        for (stats_dict, f_code) in stats_list
            if all(issimilar(cur_stats, stats_dict[cur_expr], 4) for (cur_expr, cur_stats) in cur_stats_dict)
                valid_match = f_code
            end
        end
        if isnothing(valid_match)
            thunk = Finch.logic_executor_code(ctx.ctx, prgm)
            valid_match = (eval(thunk), thunk)
            push!(stats_list, (cur_stats_dict, valid_match))
        end
        valid_match
    else
        get!(galley_codes, (ctx.ctx, ctx.tag, Finch.get_structure(prgm))) do
            thunk = Finch.logic_executor_code(ctx.ctx, prgm)
            (eval(thunk), thunk)
        end
    end
    if ctx.verbose
        println("Executing:")
        display(code)
    end
    return Base.invokelatest(f, prgm)
end

"""
    GalleyExecutorCode(ctx)

Return the code that would normally be used by the GalleyExecutor to run a program.
"""
struct GalleyExecutorCode
    ctx
end

function (ctx::GalleyExecutorCode)(prgm)
    return Finch.logic_executor_code(ctx.ctx, prgm)
end

"""
    galley_scheduler(verbose = false, estimator=DCStats)

The galley scheduler uses the sparsity patterns of the inputs to optimize the computation.
The first set of inputs given to galley is used to optimize, and the `estimator` is used to
estimate the sparsity of intermediate computations during optimization.
"""
galley_scheduler(;verbose=false) = GalleyExecutor(GalleyOptimizer(;verbose=false); verbose=false)

