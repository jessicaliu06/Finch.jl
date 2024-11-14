```@meta
CurrentModule = Finch
```

# Tensor Formats

### Creating Tensors
You can create Finch tensors using the [`Tensor`](@ref) constructor. The first argument specifies the storage format.

```jldoctest tensorformats; setup = :(using Finch)
julia> A = Tensor(Dense(SparseList(Element(0.0))), 4, 3)
4×3-Tensor
└─ Dense [:,1:3]
   ├─ [:, 1]: SparseList (0.0) [1:4]
   ├─ [:, 2]: SparseList (0.0) [1:4]
   └─ [:, 3]: SparseList (0.0) [1:4]
```

### Initializing with Data
To initialize a tensor with data:

```jldoctest tensorformats
julia> A = [0.0 0.0 4.4; 1.1 0.0 0.0; 2.2 0.0 5.5; 3.3 0.0 0.0]
julia> B = Tensor(Dense(SparseList(Element(0.0))), A)
4×3-Tensor
└─ Dense [:,1:3]
   ├─ [:, 1]: SparseList (0.0) [1:4]
   │  ├─ [2]: 1.1
   │  ├─ [3]: 2.2
   │  └─ [4]: 3.3
   ├─ [:, 2]: SparseList (0.0) [1:4]
   └─ [:, 3]: SparseList (0.0) [1:4]
      ├─ [1]: 4.4
      └─ [3]: 5.5
```

# High-Level Array API

### Basic Array Operations
Finch tensors support indexing, slicing, mapping, broadcasting, and reducing.
Many functions in the Julia standard array library are supported.

```jldoctest arrayapi; setup = :(using Finch)
julia> A = fsparse([1, 1, 2, 3], [2, 4, 5, 6], [1.0, 2.0, 3.0])
3×6-Tensor
└─ SparseCOO{2} (0.0) [:,1:6]
   ├─ [1, 2]: 1.0
   ├─ [1, 4]: 2.0
   └─ [2, 5]: 3.0

julia> A .+ 1
3×6-Tensor
└─ Dense [:,1:6]
   ├─ [:, 1]: Dense [1:3]
   │  ├─ [1]: 1.0
   │  ├─ [2]: 1.0
   │  └─ [3]: 1.0
   ├─ [:, 2]: Dense [1:3]
   │  ├─ [1]: 2.0
   │  ├─ [2]: 1.0
   │  └─ [3]: 1.0
   ├─ ⋮
   ├─ [:, 5]: Dense [1:3]
   │  ├─ [1]: 1.0
   │  ├─ [2]: 4.0
   │  └─ [3]: 1.0
   └─ [:, 6]: Dense [1:3]
      ├─ [1]: 1.0
      ├─ [2]: 1.0
      └─ [3]: 1.0
```

# Sparse and Structured Utilities

### Sparse Constructors
Convenient constructors for sparse tensors include [`fsparse`](@ref), [`fspzeros`](@ref), and [`fsprand`](@ref).
To get a list of the nonzero coordinates, use [`ffindnz`](@ref).

```jldoctest sparseutils; setup = :(using Finch)
julia> I = ([1, 2, 3], [1, 2, 3])
julia> V = [1.0, 2.0, 3.0]
julia> S = fsparse(I, V)
3×3-Tensor
└─ SparseCOO (0.0) [:,1:3]
   ├─ [1, 1]: 1.0
   ├─ [2, 2]: 2.0
   └─ [3, 3]: 3.0
```

### Fill Values
Fill values represent default values for uninitialized elements.

- **[`get_fill_value`](@ref)**: Retrieve the fill value.
- **[`set_fill_value`](@ref)**: Set a new fill value.
- **[`dropfill!`](@ref)**: Remove elements matching the fill value.

```jldoctest sparseutils
julia> t = Tensor(Dense(SparseList(Element(0.0))), 3, 3)
julia> getfill(t)
0.0

julia> setfill!(t, -1.0)
julia> dropfill!(t)
```

# Array Fusion

Finch supports composing operations into a single kernel with `lazy` and `compute`.

```jldoctest fusion; setup = :(using Finch)
julia> A = fsparse([1, 1, 2, 3], [2, 4, 5, 6], [1.0, 2.0, 3.0]);
julia> B = A .* 2;
julia> C = lazy(A)
julia> D = lazy(B)
julia> E = (C .+ D) ./ 2

julia> compute(E)
3×6-Tensor
└─ SparseDict (0.0) [:,1:6]
   ├─ [:, 2]: SparseDict (0.0) [1:3]
   │  └─ [1]: 1.5
   ├─ [:, 4]: SparseDict (0.0) [1:3]
   │  └─ [1]: 3.0
   └─ [:, 5]: SparseDict (0.0) [1:3]
      └─ [2]: 4.5
```

```@docs
lazy
compute
```

# File I/O

### Reading and Writing Files
Finch supports multiple formats, such as `.bsp`, `.mtx`, and `.tns`. Use `fread` and `fwrite` to read and write tensors.

```jldoctest fileio; setup = :(using Finch)
julia> fwrite("tensor.bsp", A)
julia> B = fread("tensor.bsp")
```

