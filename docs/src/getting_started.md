```@meta
CurrentModule = Finch
```

# Tensor Formats

### Creating Tensors
You can create Finch tensors using the [`Tensor`](@ref) constructor. The first argument specifies the storage format.

```jldoctest tensorformats; setup = :(using Finch)
julia> A = Tensor(Dense(SparseList(Element(0.0))), 4, 3)
4×3 Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 0.0  0.0  0.0
 0.0  0.0  0.0
 0.0  0.0  0.0
 0.0  0.0  0.0
```

### Initializing with Data
To initialize a tensor with data:

```jldoctest tensorformats
julia> A = [0.0 0.0 4.4; 1.1 0.0 0.0; 2.2 0.0 5.5; 3.3 0.0 0.0]
4×3 Matrix{Float64}:
 0.0  0.0  4.4
 1.1  0.0  0.0
 2.2  0.0  5.5
 3.3  0.0  0.0

julia> B = Tensor(Dense(SparseList(Element(0.0))), A)
4×3 Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}:
 0.0  0.0  4.4
 1.1  0.0  0.0
 2.2  0.0  5.5
 3.3  0.0  0.0

```

# High-Level Array API

### Basic Array Operations
Finch tensors support indexing, slicing, mapping, broadcasting, and reducing.
Many functions in the Julia standard array library are supported.

```jldoctest arrayapi; setup = :(using Finch)
julia> A = fsparse([1, 1, 2, 3], [2, 4, 5, 6], [1.0, 2.0, 3.0])
3×6 Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}:
 0.0  1.0  0.0  2.0  0.0  0.0
 0.0  0.0  0.0  0.0  3.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0

julia> A .+ 1
3×6 Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{1.0, Float64, Int64, Vector{Float64}}}}}:
 1.0  2.0  1.0  3.0  1.0  1.0
 1.0  1.0  1.0  1.0  4.0  1.0
 1.0  1.0  1.0  1.0  1.0  1.0
```

# Sparse and Structured Utilities

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

# Array Fusion

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

# File I/O

### Reading and Writing Files
Finch supports multiple formats, such as `.bsp`, `.mtx`, and `.tns`. Use `fread` and `fwrite` to read and write tensors.

```julia
julia> fwrite("tensor.bsp", A)

julia> B = fread("tensor.bsp")

```

