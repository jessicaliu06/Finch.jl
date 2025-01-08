#!/usr/bin/env julia
if abspath(PROGRAM_FILE) == @__FILE__
    using Pkg
    Pkg.activate(@__DIR__)
    Pkg.develop(PackageSpec(path = joinpath(@__DIR__, "..")))
    Pkg.instantiate()
end

using Test
using ArgParse
using ReTestItems

s = ArgParseSettings("Run Finch.jl tests. By default, all tests are run unless --include or --exclude options are provided. 
Finch compares to reference output which depends on the system word size (currently $(Sys.WORD_SIZE)-bit).To overwrite $(Sys.WORD_SIZE==32 ? 64 : 32)-bit output, run this with a $(Sys.WORD_SIZE==32 ? 64 : 32)-bit julia executable.
If the environment variable FINCH_TEST_ARGS is set, it will override the given arguments.")

@add_arg_table! s begin
    "--overwrite", "-w"
    action = :store_true
    help = "overwrite reference output for $(Sys.WORD_SIZE)-bit systems"
    "--include", "-i"
    nargs = '*'
    default = []
    help = "list of test suites to include, e.g., --include constructors merges"
    "--exclude", "-e"
    nargs = '*'
    default = []
    help = "list of test suites to exclude, e.g., --exclude parallel algebra"
    "--nprocs", "-p"
    default = 22
    arg_type = Int
    help = "number of processors to use for parallelization (0 to disable)"
    "--nthreads", "-t"
    default = 2
    arg_type = Int
    help = "number of threads to use on each processor"
end

if "FINCH_TEST_ARGS" in keys(ENV)
    ARGS = split(ENV["FINCH_TEST_ARGS"], " ")
end

parsed_args = parse_args(ARGS, s)

using Finch

runtests(Finch, nworkers=parsed_args["nprocs"], nworker_threads=parsed_args["nthreads"], worker_init_expr=quote
    using Finch
    using SparseArrays
    parsed_args=$parsed_args
    Base.eval(ReTestItems, quote
        struct TestItem
            number::Base.RefValue{Int} # populated by runtests coordinator once all test items are known
            name::String
            id::String # in case file/name isn't a sufficiently stable identifier for reporting purposes
            tags::Vector{Symbol}
            default_imports::Bool
            setups::Vector{Symbol}
            retries::Int
            timeout::Union{Int,Nothing} # in seconds
            skip::Union{Bool,Expr}
            failfast::Union{Bool,Nothing}
            file::String
            line::Int
            project_root::String
            code::Any
            testsetups::Vector{TestSetup} # populated by runtests coordinator
            workerid::Base.RefValue{Int} # populated when the test item is scheduled
            testsets::Vector{DefaultTestSet} # populated when the test item is finished running
            eval_number::Base.RefValue{Int} # to keep track of how many items have been run so far
            stats::Vector{PerfStats} # populated when the test item is finished running
            scheduled_for_evaluation::ScheduledForEvaluation # to keep track of whether the test item has been scheduled for evaluation
        end
    end)
end) do ti
    global parsed_args
    inc = parsed_args["include"]
    exc = parsed_args["exclude"]
    return (isempty(inc) || ti.name in inc) && !(ti.name in exc)
end
