```@meta
CurrentModule = Finch
```

# Finch.jl

Finch is a Julia-to-Julia compiler for sparse or structured multidimensional arrays. Finch empowers users to write high-level array programs which are transformed behind-the-scenes into fast sparse code.

## Why Finch.jl?

Finch was built to make sparse and structured array programming easier and more
efficient.  Finch.jl leverages compiler technology to automatically generate
customized, fused sparse kernels for each specific use case. This allows users
to write readable, high-level sparse array programs without worrying about the
performance of the generated code. Finch can automatically generate efficient
implementations even for unique problems that lack existing library solutions.

## Installation:

Finch is a registered package, so you can install it with the Julia package
manager.

```julia
julia> using Pkg; Pkg.add("Finch")

```

## Quickstart

```julia
julia> using Finch

# Create a sparse tensor
julia> A = Tensor(CSCFormat(), [1 0 0; 0 2 0; 0 0 3])
3×3 Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 1.0  0.0  0.0
 0.0  2.0  0.0
 0.0  0.0  3.0

# Perform a simple operation
julia> B = A + A
3×3 Tensor{DenseLevel{Int64, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 2.0  0.0  0.0
 0.0  4.0  0.0
 0.0  0.0  6.0
```

## Next Steps

See the [Getting Started](#getting-started) section for an overview of Finch's
capabilities and how to use them.