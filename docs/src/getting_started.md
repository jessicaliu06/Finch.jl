```@meta
CurrentModule = Finch
```
# Getting Started

## Tensor Formats

### Creating Tensors
You can create Finch tensors using the [`Tensor`](@ref) constructor, which closely follows the `Array` constructor syntax. The first argument specifies the storage format.

```jldoctest tensorformats; setup = :(using Finch)
# Create an empty 4x3 sparse matrix in CSC format
julia> A = Tensor(CSCFormat(), 4, 3);
julia> B = Tensor(COOFormat(2), A)
```

Some pre-defined formats include:

| **Signature** | **Description** |
|---------------|-----------------|
| [`DenseFormat`](@ref)`(N, z = 0.0, T = typeof(z))` | A dense format with a fill value of `z`. |
| [`CSFFormat`](@ref)`(N, z = 0.0, T = typeof(z))` | An `N`-dimensional CSC format for sparse tensors. |
| [`CSCFormat`](@ref)`(z = 0.0, T = typeof(z))` | A 2D CSC format storing matrices as dense lists. |
| [`DCSFFormat`](@ref)`(N, z = 0.0, T = typeof(z))` | A DCSF format storing tensors as nested lists. |
| [`HashFormat`](@ref)`(N, z = 0.0, T = typeof(z))` | A hash-table-based format for sparse data. |
| [`ByteMapFormat`](@ref)`(N, z = 0.0, T = typeof(z))` | A byte-map-based format for compact storage. |
| [`DCSCFormat`](@ref)`(z = 0.0, T = typeof(z))` | A 2D DCSC format storing matrices as lists. |
| [`COOFormat`](@ref)`(N, T = Float64, z = zero(T))` | An `N`-dimensional COO format for coordinate lists. |

It is also possible to build custom formats using the interface, as described in the [Tensor Formats](#tensor-formats) section.

## High-Level Array API

### Basic Array Operations
Finch tensors support indexing, slicing, mapping, broadcasting, and reducing.
Many functions in the Julia standard array library are supported.

```jldoctest arrayapi; setup = :(using Finch)
julia> A = Tensor(CSCFormat(), [0 1; 2 3]);
julia> B = A .+ 1
julia> C = max.(A, B)
julia> D = sum(C, dims=2)
julia> E = B[1, :]
```

For situations which are difficult to express in the julia standard library, Finch also supports an `@einsum` syntax:
```jldoctest arrayapi; setup = :(using Finch)
julia> @einsum F[i, j, k] *= A[i, j] * B[j, k]
julia> @einsum G[j, k] <<max>>= A[i, j] + B[j, i]
```

The `@einsum` macro is a powerful tool for expressing complex array operations concisely.

To get the full benefits of a sparse compiler, it is critical to fuse certain operations together. For this, Finch exposes two functions, [`lazy`](@ref) and [`compute`](@ref).
The `lazy` function creates a lazy tensor, which is a symbolic representation of the computation. The `compute` function evaluates the computation.

```jldoctest fusion; setup = :(using Finch)
julia> using BenchmarkTools

julia> A = fsprand(1000, 1000, 100); B = Tensor(rand(1000, 1000)); C = Tensor(rand(1000, 1000));

julia> lazy(A) .* (lazy(B) * lazy(C))
?×?-LazyTensor{Float64}

julia> @btime A .* (B * C);
  146.048 ms (859 allocations: 7.69 MiB)

julia> @btime compute(lazy(A) .* (lazy(B) * lazy(C)));
  690.292 μs (712 allocations: 60.86 KiB)

```

Different optimizers can be used with `compute`, such as the state-of-the-art `Galley` optimizer, which can adapt to the
sparsity patterns of the inputs.

```jldoctest fusion; setup = :(using Finch)
julia> A = fsprand(1000, 1000, 0.1); B = fsprand(1000, 1000, 0.1); C = fsprand(1000, 1000, 0.0001);

julia> A = lazy(A); B = lazy(B); C = lazy(C);

julia> @btime compute(sum(A * B * C));
  278.346 ms (1018 allocations: 185.12 MiB)

julia> @btime compute(sum(A * B * C), ctx=galley_scheduler());
  154.083 μs (672 allocations: 29.12 KiB)

```

## Sparse and Structured Utilities

### Sparse Constructors
Convenient constructors for sparse tensors include [`fsparse`](@ref), [`fspzeros`](@ref), and [`fsprand`](@ref).
To get a list of the nonzero coordinates, use [`ffindnz`](@ref).

```jldoctest sparseutils; setup = :(using Finch)
julia> I = ([1, 2, 3], [1, 2, 3])
([1, 2, 3], [1, 2, 3])

julia> V = [1.0, 2.0, 3.0]
3-element Vector{Float64}:
 1.0
 2.0
 3.0

julia> S = fsparse(I..., V)
3×3 Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}:
 1.0  0.0  0.0
 0.0  2.0  0.0
 0.0  0.0  3.0
```

### Fill Values
Fill values represent default values for uninitialized elements.

- **[`fill_value`](@ref)**: Retrieve the fill value.
- **[`set_fill_value!`](@ref)**: Set a new fill value.
- **[`dropfills`](@ref)** or **[`dropfills!`](@ref)**: Remove elements matching the fill value.

```jldoctest sparseutils; setup = :(using Finch)
julia> t = Tensor(Dense(SparseList(Element(0.0))), 3, 3)
3×3 Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 0.0  0.0  0.0
 0.0  0.0  0.0
 0.0  0.0  0.0

julia> fill_value(t)
0.0

julia> set_fill_value!(t, -1.0)
3×3 Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{-1.0, Float64, Int64, Vector{Float64}}}}}:
 -1.0  -1.0  -1.0
 -1.0  -1.0  -1.0
 -1.0  -1.0  -1.0

julia> tensor_tree(dropfills(t))
3×3-Tensor
└─ Dense [:,1:3]
   ├─ [:, 1]: SparseList (0.0) [1:3]
   ├─ [:, 2]: SparseList (0.0) [1:3]
   └─ [:, 3]: SparseList (0.0) [1:3]

```

## Array Fusion

Finch supports composing operations into a single kernel with [`lazy`](@ref) and [`compute`](@ref).

```jldoctest fusion; setup = :(using Finch)
julia> A = fsparse([1, 1, 2, 3], [2, 4, 5, 6], [1.0, 2.0, 3.0])
3×6 Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}:
 0.0  1.0  0.0  2.0  0.0  0.0
 0.0  0.0  0.0  0.0  3.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0

julia> B = A .* 2
3×6 Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 0.0  2.0  0.0  4.0  0.0  0.0
 0.0  0.0  0.0  0.0  6.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0

julia> C = lazy(A)
?×?-LazyTensor{Float64}

julia> D = lazy(B)
?×?-LazyTensor{Float64}

julia> E = (C .+ D) ./ 2
?×?-LazyTensor{Float64}

julia> compute(E)
3×6 Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 0.0  1.5  0.0  3.0  0.0  0.0
 0.0  0.0  0.0  0.0  4.5  0.0
 0.0  0.0  0.0  0.0  0.0  0.0

```

## File I/O

### Reading and Writing Files
Finch supports multiple formats, such as `.bsp`, `.mtx`, and `.tns`. Use `fread` and `fwrite` to read and write tensors.

```julia
julia> fwrite("tensor.bsp", A)

julia> B = fread("tensor.bsp")

```

