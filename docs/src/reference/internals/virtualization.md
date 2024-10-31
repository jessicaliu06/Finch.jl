```@meta
CurrentModule = Finch
```

### Program Instances

Finch relies heavily on Julia's
[metaprogramming capabilities](https://docs.julialang.org/en/v1/manual/metaprogramming/) (
[macros](https://docs.julialang.org/en/v1/manual/metaprogramming/#Macros) and
[generated functions](https://docs.julialang.org/en/v1/manual/metaprogramming/#Generated-functions)
in particular) to produce code. To review briefly, a macro allows us to inspect
the syntax of it's arguments and generate replacement syntax. A generated
function allows us to inspect the type of the function arguments and produce
code for a function body.

In normal Finch usage, we might call Finch as follows:

```jldoctest example1; setup = :(using Finch)
julia> C = Tensor(SparseList(Element(0)));

julia> A = Tensor(SparseList(Element(0)), [0, 2, 0, 0, 3]);
ERROR: MethodError: no method matching zero(::Type{Any})
This error has been manually thrown, explicitly, so the method may exist but be intentionally marked as unimplemented.

Closest candidates are:
  zero(::Type{Union{Missing, T}}) where T
   @ Base missing.jl:105
  zero(!Matched::Type{Union{}}, Any...)
   @ Base number.jl:310
  zero(!Matched::Type{Dates.Time})
   @ Dates ~/.julia/juliaup/julia-1.11.1+0.aarch64.apple.darwin14/share/julia/stdlib/v1.11/Dates/src/types.jl:460
  ...

Stacktrace:
  [1] zero(::Type{Any})
    @ Base ./missing.jl:106
  [2] reduce_empty(::typeof(+), ::Type{Any})
    @ Base ./reduce.jl:343
  [3] reduce_empty(::typeof(Base.add_sum), ::Type{Any})
    @ Base ./reduce.jl:350
  [4] mapreduce_empty(::typeof(identity), op::Function, T::Type)
    @ Base ./reduce.jl:369
  [5] reduce_empty(op::Base.MappingRF{typeof(identity), typeof(Base.add_sum)}, ::Type{Any})
    @ Base ./reduce.jl:358
  [6] reduce_empty_iter
    @ ./reduce.jl:381 [inlined]
  [7] mapreduce_empty_iter(f::Function, op::Function, itr::Vector{Any}, ItrEltype::Base.HasEltype)
    @ Base ./reduce.jl:377
  [8] _mapreduce(f::typeof(identity), op::typeof(Base.add_sum), ::IndexLinear, A::Vector{Any})
    @ Base ./reduce.jl:429
  [9] _mapreduce_dim
    @ ./reducedim.jl:337 [inlined]
 [10] mapreduce
    @ ./reducedim.jl:329 [inlined]
 [11] _sum
    @ ./reducedim.jl:987 [inlined]
 [12] _sum
    @ ./reducedim.jl:986 [inlined]
 [13] sum(a::Vector{Any})
    @ Base ./reducedim.jl:982
 [14] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:116 [inlined]
 [15] var"##setindex_helper_generator#280"(arr::Type, src::Type, inds::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [16] (::Finch.var"#1800#1806"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [17] #s352#1799
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [18] var"#s352#1799"(::Any, arr::Any, src::Any, inds::Any)
    @ Finch ./none:0
 [19] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [20] setindex!
    @ ~/Projects/Finch.jl/src/interface/index.jl:103 [inlined]
 [21] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [22] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}, src::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}, arr::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1

julia> B = Tensor(Dense(Element(0)), [11, 12, 13, 14, 15]);
ERROR: MethodError: no method matching zero(::Type{Any})
This error has been manually thrown, explicitly, so the method may exist but be intentionally marked as unimplemented.

Closest candidates are:
  zero(::Type{Union{Missing, T}}) where T
   @ Base missing.jl:105
  zero(!Matched::Type{Union{}}, Any...)
   @ Base number.jl:310
  zero(!Matched::Type{Dates.Time})
   @ Dates ~/.julia/juliaup/julia-1.11.1+0.aarch64.apple.darwin14/share/julia/stdlib/v1.11/Dates/src/types.jl:460
  ...

Stacktrace:
  [1] zero(::Type{Any})
    @ Base ./missing.jl:106
  [2] reduce_empty(::typeof(+), ::Type{Any})
    @ Base ./reduce.jl:343
  [3] reduce_empty(::typeof(Base.add_sum), ::Type{Any})
    @ Base ./reduce.jl:350
  [4] mapreduce_empty(::typeof(identity), op::Function, T::Type)
    @ Base ./reduce.jl:369
  [5] reduce_empty(op::Base.MappingRF{typeof(identity), typeof(Base.add_sum)}, ::Type{Any})
    @ Base ./reduce.jl:358
  [6] reduce_empty_iter
    @ ./reduce.jl:381 [inlined]
  [7] mapreduce_empty_iter(f::Function, op::Function, itr::Vector{Any}, ItrEltype::Base.HasEltype)
    @ Base ./reduce.jl:377
  [8] _mapreduce(f::typeof(identity), op::typeof(Base.add_sum), ::IndexLinear, A::Vector{Any})
    @ Base ./reduce.jl:429
  [9] _mapreduce_dim
    @ ./reducedim.jl:337 [inlined]
 [10] mapreduce
    @ ./reducedim.jl:329 [inlined]
 [11] _sum
    @ ./reducedim.jl:987 [inlined]
 [12] _sum
    @ ./reducedim.jl:986 [inlined]
 [13] sum(a::Vector{Any})
    @ Base ./reducedim.jl:982
 [14] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:116 [inlined]
 [15] var"##setindex_helper_generator#280"(arr::Type, src::Type, inds::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [16] (::Finch.var"#1800#1806"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [17] #s352#1799
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [18] var"#s352#1799"(::Any, arr::Any, src::Any, inds::Any)
    @ Finch ./none:0
 [19] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [20] setindex!
    @ ~/Projects/Finch.jl/src/interface/index.jl:103 [inlined]
 [21] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [22] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}, src::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}, arr::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1

julia> @finch (C .= 0; for i=_; C[i] = A[i] * B[i] end);
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] macro expansion
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157 [inlined]
 [2] macro expansion
   @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [3] top-level scope
   @ none:1

julia> C
0-Tensor
└─ SparseList (0) [1:0]

```

The
[`@macroexpand`](https://docs.julialang.org/en/v1/base/base/#Base.macroexpand)
macro allows us to see the result of applying a macro. Let's examine what
happens when we use the `@finch` macro (we've stripped line numbers from the
result to clean it up):

```jldoctest example1; filter=r"Finch\.FinchNotation\."
julia> (@macroexpand @finch (C .= 0; for i=_; C[i] = A[i] * B[i] end)) |> Finch.striplines |> Finch.regensym
quote
    _res_1 = (Finch.execute)((Finch.FinchNotation.block_instance)((Finch.FinchNotation.block_instance)((Finch.FinchNotation.declare_instance)((Finch.FinchNotation.tag_instance)(variable_instance(:C), (Finch.FinchNotation.finch_leaf_instance)(C)), literal_instance(0)), begin
                        let i = index_instance(i)
                            (Finch.FinchNotation.loop_instance)(i, Finch.FinchNotation.Dimensionless(), (Finch.FinchNotation.assign_instance)((Finch.FinchNotation.access_instance)((Finch.FinchNotation.tag_instance)(variable_instance(:C), (Finch.FinchNotation.finch_leaf_instance)(C)), literal_instance(Finch.FinchNotation.Updater()), (Finch.FinchNotation.tag_instance)(variable_instance(:i), (Finch.FinchNotation.finch_leaf_instance)(i))), (Finch.FinchNotation.literal_instance)(Finch.FinchNotation.initwrite), (Finch.FinchNotation.call_instance)((Finch.FinchNotation.tag_instance)(variable_instance(:*), (Finch.FinchNotation.finch_leaf_instance)(*)), (Finch.FinchNotation.access_instance)((Finch.FinchNotation.tag_instance)(variable_instance(:A), (Finch.FinchNotation.finch_leaf_instance)(A)), literal_instance(Finch.FinchNotation.Reader()), (Finch.FinchNotation.tag_instance)(variable_instance(:i), (Finch.FinchNotation.finch_leaf_instance)(i))), (Finch.FinchNotation.access_instance)((Finch.FinchNotation.tag_instance)(variable_instance(:B), (Finch.FinchNotation.finch_leaf_instance)(B)), literal_instance(Finch.FinchNotation.Reader()), (Finch.FinchNotation.tag_instance)(variable_instance(:i), (Finch.FinchNotation.finch_leaf_instance)(i))))))
                        end
                    end), (Finch.FinchNotation.yieldbind_instance)(variable_instance(:C))); )
    begin
        C = _res_1[:C]
    end
    begin
        _res_1
    end
end

```

In the above output, `@finch` creates an AST of program instances, then calls
`Finch.execute` on it. A program instance is a struct that contains the program
to be executed along with its arguments. Although we can use the above
constructors (e.g. `loop_instance`) to make our own program instance, it is most
convenient to use the unexported macro `Finch.finch_program_instance`:

```jldoctest example1
julia> using Finch: @finch_program_instance

julia> prgm = Finch.@finch_program_instance (C .= 0; for i=_; C[i] = A[i] * B[i] end; return C)
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157
```

As we can see, our program instance contains not only the AST to be executed,
but also the data to execute the program with. The type of the program instance
contains only the program portion; there may be many program instances with
different inputs, but the same program type. We can run our program using
`Finch.execute`, which returns a `NamedTuple` of outputs.

```jldoctest example1; filter=r"Finch\.FinchNotation\."
julia> typeof(prgm)
ERROR: UndefVarError: `prgm` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> C = Finch.execute(prgm).C
ERROR: UndefVarError: `prgm` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1
```

This functionality is sufficient for building finch kernels programatically. For
example, if we wish to define a function `pointwise_sum()` that takes the
pointwise sum of a variable number of vector inputs, we might implement it as
follows:

```jldoctest example1
julia> function pointwise_sum(As...)
           B = Tensor(Dense(Element(0)))
           isempty(As) && return B
           i = Finch.FinchNotation.index_instance(:i)
           A_vars = [Finch.FinchNotation.tag_instance(Finch.FinchNotation.variable_instance(Symbol(:A, n)), As[n]) for n in 1:length(As)]
           #create a list of variable instances with different names to hold the input tensors
           ex = @finch_program_instance 0
           for A_var in A_vars
               ex = @finch_program_instance $A_var[i] + $ex
           end
           prgm = @finch_program_instance (B .= 0; for i=_; B[i] = $ex end; return B)
           return Finch.execute(prgm).B
       end
pointwise_sum (generic function with 1 method)

julia> pointwise_sum([1, 2], [3, 4])
ERROR: MethodError: no method matching zero(::Type{Any})
This error has been manually thrown, explicitly, so the method may exist but be intentionally marked as unimplemented.

Closest candidates are:
  zero(::Type{Union{Missing, T}}) where T
   @ Base missing.jl:105
  zero(!Matched::Type{Union{}}, Any...)
   @ Base number.jl:310
  zero(!Matched::Type{Dates.Time})
   @ Dates ~/.julia/juliaup/julia-1.11.1+0.aarch64.apple.darwin14/share/julia/stdlib/v1.11/Dates/src/types.jl:460
  ...

Stacktrace:
  [1] zero(::Type{Any})
    @ Base ./missing.jl:106
  [2] reduce_empty(::typeof(+), ::Type{Any})
    @ Base ./reduce.jl:343
  [3] reduce_empty(::typeof(Base.add_sum), ::Type{Any})
    @ Base ./reduce.jl:350
  [4] mapreduce_empty(::typeof(identity), op::Function, T::Type)
    @ Base ./reduce.jl:369
  [5] reduce_empty(op::Base.MappingRF{typeof(identity), typeof(Base.add_sum)}, ::Type{Any})
    @ Base ./reduce.jl:358
  [6] reduce_empty_iter
    @ ./reduce.jl:381 [inlined]
  [7] mapreduce_empty_iter(f::Function, op::Function, itr::Vector{Any}, ItrEltype::Base.HasEltype)
    @ Base ./reduce.jl:377
  [8] _mapreduce(f::typeof(identity), op::typeof(Base.add_sum), ::IndexLinear, A::Vector{Any})
    @ Base ./reduce.jl:429
  [9] _mapreduce_dim
    @ ./reducedim.jl:337 [inlined]
 [10] mapreduce
    @ ./reducedim.jl:329 [inlined]
 [11] _sum
    @ ./reducedim.jl:987 [inlined]
 [12] _sum
    @ ./reducedim.jl:986 [inlined]
 [13] sum(a::Vector{Any})
    @ Base ./reducedim.jl:982
 [14] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:116 [inlined]
 [15] var"##setindex_helper_generator#280"(arr::Type, src::Type, inds::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [16] (::Finch.var"#1800#1806"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [17] #s352#1799
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [18] var"#s352#1799"(::Any, arr::Any, src::Any, inds::Any)
    @ Finch ./none:0
 [19] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [20] setindex!
    @ ~/Projects/Finch.jl/src/interface/index.jl:103 [inlined]
 [21] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [22] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:+}, Finch.FinchNotation.LiteralInstance{+}}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A2}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:+}, Finch.FinchNotation.LiteralInstance{+}}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.LiteralInstance{0}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:safe})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:+}, Finch.FinchNotation.LiteralInstance{+}}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A2}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:+}, Finch.FinchNotation.LiteralInstance{+}}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i}, Finch.FinchNotation.IndexInstance{:i}}}}, Finch.FinchNotation.LiteralInstance{0}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:B}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] pointwise_sum(::Vector{Int64}, ::Vararg{Vector{Int64}})
    @ Main ./none:12
 [26] top-level scope
    @ none:1

```

## Virtualization

Finch generates different code depending on the types of the arguments to the
program. For example, in the following program, Finch generates different code
depending on the types of `A` and `B`. In order to execute a program, Finch
builds a typed AST (Abstract Syntax Tree), then calls `Finch.execute` on it. The
AST object is just an instance of a program to execute, and contains the program
to execute along with the data to execute it.  The type of the program instance
contains only the program portion; there may be many program instances with
different inputs, but the same program type. During compilation, Finch uses the
type of the program to construct a more ergonomic representation, which is then
used to generate code. This process is called "virtualization".  All of the
Finch AST nodes have both instance and virtual representations. For example, the
literal `42` is represented as `Finch.FinchNotation.LiteralInstance(42)` and
then virtualized to `literal(42)`.  The virtualization process is implemented by
the `virtualize` function.
```jldoctest example2; setup = :(using Finch)
julia> A = Tensor(SparseList(Element(0)), [0, 2, 0, 0, 3]);
ERROR: MethodError: no method matching zero(::Type{Any})
This error has been manually thrown, explicitly, so the method may exist but be intentionally marked as unimplemented.

Closest candidates are:
  zero(::Type{Union{Missing, T}}) where T
   @ Base missing.jl:105
  zero(!Matched::Type{Union{}}, Any...)
   @ Base number.jl:310
  zero(!Matched::Type{Dates.Time})
   @ Dates ~/.julia/juliaup/julia-1.11.1+0.aarch64.apple.darwin14/share/julia/stdlib/v1.11/Dates/src/types.jl:460
  ...

Stacktrace:
  [1] zero(::Type{Any})
    @ Base ./missing.jl:106
  [2] reduce_empty(::typeof(+), ::Type{Any})
    @ Base ./reduce.jl:343
  [3] reduce_empty(::typeof(Base.add_sum), ::Type{Any})
    @ Base ./reduce.jl:350
  [4] mapreduce_empty(::typeof(identity), op::Function, T::Type)
    @ Base ./reduce.jl:369
  [5] reduce_empty(op::Base.MappingRF{typeof(identity), typeof(Base.add_sum)}, ::Type{Any})
    @ Base ./reduce.jl:358
  [6] reduce_empty_iter
    @ ./reduce.jl:381 [inlined]
  [7] mapreduce_empty_iter(f::Function, op::Function, itr::Vector{Any}, ItrEltype::Base.HasEltype)
    @ Base ./reduce.jl:377
  [8] _mapreduce(f::typeof(identity), op::typeof(Base.add_sum), ::IndexLinear, A::Vector{Any})
    @ Base ./reduce.jl:429
  [9] _mapreduce_dim
    @ ./reducedim.jl:337 [inlined]
 [10] mapreduce
    @ ./reducedim.jl:329 [inlined]
 [11] _sum
    @ ./reducedim.jl:987 [inlined]
 [12] _sum
    @ ./reducedim.jl:986 [inlined]
 [13] sum(a::Vector{Any})
    @ Base ./reducedim.jl:982
 [14] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:116 [inlined]
 [15] var"##setindex_helper_generator#280"(arr::Type, src::Type, inds::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [16] (::Finch.var"#1800#1806"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [17] #s352#1799
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [18] var"#s352#1799"(::Any, arr::Any, src::Any, inds::Any)
    @ Finch ./none:0
 [19] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [20] setindex!
    @ ~/Projects/Finch.jl/src/interface/index.jl:103 [inlined]
 [21] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [22] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}}, src::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0, Int64, Int64, Vector{Int64}}}, arr::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1

julia> B = Tensor(Dense(Element(0)), [11, 12, 13, 14, 15]);
ERROR: MethodError: no method matching zero(::Type{Any})
This error has been manually thrown, explicitly, so the method may exist but be intentionally marked as unimplemented.

Closest candidates are:
  zero(::Type{Union{Missing, T}}) where T
   @ Base missing.jl:105
  zero(!Matched::Type{Union{}}, Any...)
   @ Base number.jl:310
  zero(!Matched::Type{Dates.Time})
   @ Dates ~/.julia/juliaup/julia-1.11.1+0.aarch64.apple.darwin14/share/julia/stdlib/v1.11/Dates/src/types.jl:460
  ...

Stacktrace:
  [1] zero(::Type{Any})
    @ Base ./missing.jl:106
  [2] reduce_empty(::typeof(+), ::Type{Any})
    @ Base ./reduce.jl:343
  [3] reduce_empty(::typeof(Base.add_sum), ::Type{Any})
    @ Base ./reduce.jl:350
  [4] mapreduce_empty(::typeof(identity), op::Function, T::Type)
    @ Base ./reduce.jl:369
  [5] reduce_empty(op::Base.MappingRF{typeof(identity), typeof(Base.add_sum)}, ::Type{Any})
    @ Base ./reduce.jl:358
  [6] reduce_empty_iter
    @ ./reduce.jl:381 [inlined]
  [7] mapreduce_empty_iter(f::Function, op::Function, itr::Vector{Any}, ItrEltype::Base.HasEltype)
    @ Base ./reduce.jl:377
  [8] _mapreduce(f::typeof(identity), op::typeof(Base.add_sum), ::IndexLinear, A::Vector{Any})
    @ Base ./reduce.jl:429
  [9] _mapreduce_dim
    @ ./reducedim.jl:337 [inlined]
 [10] mapreduce
    @ ./reducedim.jl:329 [inlined]
 [11] _sum
    @ ./reducedim.jl:987 [inlined]
 [12] _sum
    @ ./reducedim.jl:986 [inlined]
 [13] sum(a::Vector{Any})
    @ Base ./reducedim.jl:982
 [14] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:116 [inlined]
 [15] var"##setindex_helper_generator#280"(arr::Type, src::Type, inds::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [16] (::Finch.var"#1800#1806"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [17] #s352#1799
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [18] var"#s352#1799"(::Any, arr::Any, src::Any, inds::Any)
    @ Finch ./none:0
 [19] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [20] setindex!
    @ ~/Projects/Finch.jl/src/interface/index.jl:103 [inlined]
 [21] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [22] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Vector{Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}}, src::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, ElementLevel{0, Int64, Int64, Vector{Int64}}}, arr::Vector{Int64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1

julia> s = Scalar(0);

julia> typeof(A)
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> typeof(B)
ERROR: UndefVarError: `B` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> inst = Finch.@finch_program_instance begin
           for i = _
               s[] += A[i]
           end
       end
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157

julia> typeof(inst)
ERROR: UndefVarError: `inst` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> Finch.virtualize(Finch.JuliaContext(), :inst, typeof(inst))
ERROR: UndefVarError: `inst` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> @finch_code begin
           for i = _
               s[] += A[i]
           end
       end
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] macro expansion
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157 [inlined]
 [2] macro expansion
   @ ~/Projects/Finch.jl/src/execute.jl:217 [inlined]
 [3] top-level scope
   @ none:1

julia> @finch_code begin
           for i = _
               s[] += B[i]
           end
       end
ERROR: UndefVarError: `B` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] macro expansion
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157 [inlined]
 [2] macro expansion
   @ ~/Projects/Finch.jl/src/execute.jl:217 [inlined]
 [3] top-level scope
   @ none:1

```

### The "virtual" IR Node

Users can also create their own virtual nodes to represent their custom types.
While most calls to virtualize result in a Finch IR Node, some objects, such as
tensors and dimensions, are virtualized to a `virtual` object, which holds the
custom virtual type.  These types may contain constants and other virtuals, as
well as reference variables in the scope of the executing context. Any aspect of
virtuals visible to Finch should be considered immutable, but virtuals may
reference mutable variables in the scope of the executing context.

```@docs
virtualize
FinchNotation.virtual
```

### Virtual Methods

Many methods have analogues we can call on the virtual version of the object.
For example, we can call `size` an an array, and `virtual_size` on a virtual
array. The virtual methods are used to generate code, so if they are pure they
may return an expression which computes the results, and if they have side
effects they may accept a context argument into which they can emit their
side-effecting code.

In addition to the special compiler methods which are prefixed `virtual_`, there
is also a function `virtual_call`, which is used to evaluate function calls on
Finch IR when it would result in a virtual object. The behavior should mirror
the concrete behavior of the corresponding function.

```@docs
virtual_call
```

## Working with Finch IR

Calling print on a finch program or program instance will print the
structure of the program as one would call constructors to build it. For
example,

```jldoctest example2; setup = :(using Finch)
julia> prgm_inst = Finch.@finch_program_instance for i = _
            s[] += A[i]
        end;
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157

julia> println(prgm_inst)
ERROR: UndefVarError: `prgm_inst` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> prgm_inst
ERROR: UndefVarError: `prgm_inst` not defined in `Main`
Suggestion: check for spelling errors or missing imports.

julia> prgm = Finch.@finch_program for i = _
               s[] += A[i]
           end;
ERROR: UndefVarError: `A` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157


julia> println(prgm)
loop(index(i), virtual(Finch.FinchNotation.Dimensionless()), assign(access(literal(Scalar{0, Int64}(0)), literal(Finch.FinchNotation.Updater())), literal(+), access(literal(Tensor(SparseList{Int64}(Element{0, Int64, Int64}([2, 3]), 5, [1, 3], [2, 5]))), literal(Finch.FinchNotation.Reader()), index(i))))

julia> prgm
Finch program: for i = virtual(Finch.FinchNotation.Dimensionless)
  Scalar{0, Int64}(0)[] <<+>>= Tensor(SparseList{Int64}(Element{0, Int64, Int64}([2, 3]), 5, [1, 3], [2, 5]))[i]
end

```

Both the virtual and instance representations of Finch IR define
[SyntaxInterface.jl](https://github.com/willow-ahrens/SyntaxInterface.jl) and
[AbstractTrees.jl](https://github.com/JuliaCollections/AbstractTrees.jl)
representations, so you can use the standard `operation`, `arguments`, `istree`, and `children` functions to inspect the structure of the program, as well as the rewriters defined by [RewriteTools.jl](https://github.com/willow-ahrens/RewriteTools.jl)

```jldoctest example2; setup = :(using Finch, AbstractTrees, SyntaxInterface, RewriteTools)
julia> using Finch.FinchNotation;


julia> PostOrderDFS(prgm)
PostOrderDFS{FinchNode}(loop(index(i), virtual(Dimensionless()), assign(access(literal(Scalar{0, Int64}(0)), literal(Updater())), literal(+), access(literal(Tensor(SparseList{Int64}(Element{0, Int64, Int64}([2, 3]), 5, [1, 3], [2, 5]))), literal(Reader()), index(i)))))

julia> (@capture prgm loop(~idx, ~ext, ~val))
true

julia> idx
Finch program: i

```