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
    default = Sys.CPU_THREADS
    help = "number of processors to use for parallelization (0 to disable)"
    "--nthreads", "-t"
    default = 2
    help = "number of threads to use on each processor"
end

if "FINCH_TEST_ARGS" in keys(ENV)
    ARGS = split(ENV["FINCH_TEST_ARGS"], " ")
end

parsed_args = parse_args(ARGS, s)

if isempty(parsed_args["include"])
    pattern = ".*"
else
    @assert all(x -> all(isascii, x), parsed_args["include"])
    pattern = "(" * join(parsed_args["include"], "|") * ")"
end
if !isempty(parsed_args["exclude"])
    @assert all(x -> all(isascii, x), parsed_args["exclude"])
    pattern = "(?!" * join(parsed_args["exclude"], "|") * ")" * pattern 
end

pattern = Regex("^" * pattern * "\$")

function should_run(name)
    global parsed_args
    inc = parsed_args["include"]
    exc = parsed_args["exclude"]
    return (isempty(inc) || name in inc) && !(name in exc)
end

using Finch

runtests(Finch, name=pattern, nworkers=parsed_args["nprocs"], nworker_threads=parsed_args["nthreads"], worker_init_expr=quote
    using Finch
    using SparseArrays
    parsed_args=$parsed_args
end)
