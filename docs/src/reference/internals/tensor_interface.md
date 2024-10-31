```@meta
CurrentModule = Finch
```

# Tensor Interface

The `AbstractTensor` interface (defined in `src/abstract_tensor.jl`) is the interface through which Finch understands tensors. It is a high-level interace which allows tensors to interact with the rest of the Finch system. The interface is designed to be extensible, allowing users to define their own tensor types and behaviors. For a minimal example, read the definitions in [`/ext/SparseArraysExt.jl`](https://github.com/finch-tensor/Finch.jl/blob/main/ext/SparseArraysExt.jl) and in [`/src/interface/abstractarray.jl`](https://github.com/finch-tensor/Finch.jl/blob/main/src/interface/abstractarray.jl). Once these methods are defined that tell Finch how to generate code for an array, the `AbstractTensor` interface will also use Finch to generate code for several Julia `AbstractArray` methods, such as `getindex`, `setindex!`, `map`, and `reduce`. An important note: `getindex` and `setindex!` are not a source of truth for Finch tensors. Search the codebase for `::AbstractTensor` for a full list of methods that are implemented for `AbstractTensor`. Note than most `AbstractTensor` implement `labelled_show` and `labelled_children` methods instead of `show(::IO, ::MIME"text/plain", t::AbstractTensor)` for pretty printed display.

## Tensor Methods

```@docs
declare!
instantiate
freeze!
thaw!
unfurl
fill_value
virtual_eltype
virtual_fill_value
virtual_size
virtual_resize!
moveto
virtual_moveto
labelled_show
labelled_children
is_injective
is_atomic
is_concurrent
```

# Level Interface

```jldoctest example1; setup=:(using Finch)
julia> A = [0.0 0.0 4.4; 1.1 0.0 0.0; 2.2 0.0 5.5; 3.3 0.0 0.0]
4×3 Matrix{Float64}:
 0.0  0.0  4.4
 1.1  0.0  0.0
 2.2  0.0  5.5
 3.3  0.0  0.0

julia> A_fbr = Tensor(Dense(Dense(Element(0.0))), A)
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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1

```

We refer to a node in the tree as a subfiber. All of the nodes at the same level
are stored in the same datastructure, and disambiguated by an integer
`position`.  in the above example, there are three levels: the rootmost level
contains only one subfiber, the root. The middle level has 3 subfibers, one for
each column. The leafmost level has 12 subfibers, one for each element of the
array.  For example, the first level is `A_fbr.lvl`, and we can represent it's
third position as `SubFiber(A_fbr.lvl.lvl, 3)`. The second level is `A_fbr.lvl.lvl`,
and we can access it's 9th position as `SubFiber(A_fbr.lvl.lvl.lvl, 9)`. For
instructional purposes, you can use parentheses to call a subfiber on an index to
select among children of a subfiber.

```jldoctest example1
julia> Finch.SubFiber(A_fbr.lvl.lvl, 3)
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> A_fbr[:, 3]
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> A_fbr(3)
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> Finch.SubFiber(A_fbr.lvl.lvl.lvl, 9)
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> A_fbr[1, 3]
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

julia> A_fbr(3)(1)
ERROR: UndefVarError: `A_fbr` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:1

```

When we print the tree in text, positions are numbered from top to bottom.
However, if we visualize our tree with the root at the top, positions range from
left to right:

![Dense Format Index Tree](../../assets/levels-A-d-d-e.png)

Because our array is sparse, (mostly zero, or another fill value), it would be
more efficient to store only the nonzero values. In Finch, each level is
represented with a different format. A sparse level only stores non-fill values.
This time, we'll use a tensor constructor with `sl` (for "`SparseList` of
nonzeros") instead of `d` (for "`Dense`"):

```jldoctest example1
julia> A_fbr = Tensor(Dense(SparseList(Element(0.0))), A)
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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

![CSC Format Index Tree](../../assets/levels-A-d-sl-e.png)

Our `Dense(SparseList(Element(0.0)))` format is also known as
["CSC"](https://en.wikipedia.org/wiki/Sparse_matrix#Compressed_sparse_column_.28CSC_or_CCS.29)
and is equivalent to
[`SparseMatrixCSC`](https://sparsearrays.juliasparse.org/dev/#man-csc). The
[`Tensor`](@ref) function will perform a zero-cost copy between Finch fibers and
sparse matrices, when available.  CSC is an excellent general-purpose
representation when we expect most of the columns to have a few nonzeros.
However, when most of the columns are entirely fill (a situation known as
hypersparsity), it is better to compress the root level as well:

```jldoctest example1
julia> A_fbr = Tensor(SparseList(SparseList(Element(0.0))), A)
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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [31] Tensor(lvl::SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Matrix{Float64})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

![DCSC Format Index Tree](../../assets/levels-A-sl-sl-e.png)

Here we see that the entirely zero column has also been compressed. The
`SparseList(SparseList(Element(0.0)))` format is also known as
["DCSC"](https://ieeexplore.ieee.org/document/4536313).

The
["COO"](https://docs.scipy.org/doc/scipy/reference/generated/scipy.sparse.coo_matrix.html)
(or "Coordinate") format is often used in practice for ease of interchange
between libraries. In an `N`-dimensional array `A`, COO stores `N` lists of
indices `I_1, ..., I_N` where `A[I_1[p], ..., I_N[p]]` is the `p`^th stored
value in column-major numbering. In Finch, `COO` is represented as a multi-index
level, which can handle more than one index at once. We use curly brackets to
declare the number of indices handled by the level:

```jldoctest example1
julia> A_fbr = Tensor(SparseCOO{2}(Element(0.0)), A)
ERROR: Unfurled not lowered completely
Stacktrace:
   [1] error(s::String)
     @ Base ./error.jl:35
   [2] lower_access(ctx::Finch.FinchCompiler, node::Finch.FinchNotation.FinchNode, tns::Finch.Unfurled)
     @ Finch ~/Projects/Finch.jl/src/tensors/combinators/unfurled.jl:111
   [3] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:180
   [4] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
   [5] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
   [6] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:230
   [7] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
   [8] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
   [9] (::Finch.var"#55#65")(ctx_3::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:216
  [10] #39
     @ ~/Projects/Finch.jl/src/lower.jl:38 [inlined]
  [11] open_scope(f::Finch.var"#39#40"{Finch.var"#55#65", Finch.FinchCompiler}, ctx::Finch.ScopeContext)
     @ Finch ~/Projects/Finch.jl/src/scopes.jl:96
  [12] open_scope(f::Finch.var"#55#65", ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:37
  [13] #54
     @ ~/Projects/Finch.jl/src/lower.jl:215 [inlined]
  [14] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [15] contain(f::Finch.var"#42#43"{Finch.var"#54#64", Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [16] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [17] contain(f::Finch.var"#54#64", ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [18] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [19] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:212
  [20] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [21] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [22] (::Finch.var"#51#61")(ctx_3::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:171
  [23] #39
     @ ~/Projects/Finch.jl/src/lower.jl:38 [inlined]
  [24] open_scope(f::Finch.var"#39#40"{Finch.var"#51#61", Finch.FinchCompiler}, ctx::Finch.ScopeContext)
     @ Finch ~/Projects/Finch.jl/src/scopes.jl:96
  [25] open_scope(f::Finch.var"#51#61", ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:37
  [26] #50
     @ ~/Projects/Finch.jl/src/lower.jl:170 [inlined]
  [27] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [28] contain(f::Finch.var"#42#43"{Finch.var"#50#60", Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [29] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [30] contain(f::Finch.var"#50#60", ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [31] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [32] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:169
  [33] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [34] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [35] #588
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:25 [inlined]
  [36] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [37] contain(f::Finch.var"#42#43"{Finch.var"#588#590"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [38] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [39] contain(f::Finch.var"#588#590"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [40] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [41] #587
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:24 [inlined]
  [42] (::Finch.var"#42#43"{Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler})(code_2::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:54
  [43] contain(f::Finch.var"#42#43"{Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [44] contain(f::Function, ctx::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:111
  [45] contain(f::Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [46] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [47] lower
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:22 [inlined]
  [48] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.ThunkStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [49] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [50] #603
     @ ~/Projects/Finch.jl/src/looplets/lookups.jl:40 [inlined]
  [51] #39
     @ ~/Projects/Finch.jl/src/lower.jl:38 [inlined]
  [52] open_scope(f::Finch.var"#39#40"{Finch.var"#603#606"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.ScopeContext)
     @ Finch ~/Projects/Finch.jl/src/scopes.jl:96
  [53] open_scope(f::Finch.var"#603#606"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:37
  [54] (::Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol})(ctx_2::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/looplets/lookups.jl:39
  [55] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [56] contain(f::Finch.var"#42#43"{Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [57] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [58] contain(f::Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [59] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [60] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.LookupStyle)
     @ Finch ~/Projects/Finch.jl/src/looplets/lookups.jl:27
  [61] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.LookupStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [62] lower_loop(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ext::Finch.Extent)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:266
  [63] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:207
  [64] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [65] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [66] #603
     @ ~/Projects/Finch.jl/src/looplets/lookups.jl:40 [inlined]
  [67] #39
     @ ~/Projects/Finch.jl/src/lower.jl:38 [inlined]
  [68] open_scope(f::Finch.var"#39#40"{Finch.var"#603#606"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.ScopeContext)
     @ Finch ~/Projects/Finch.jl/src/scopes.jl:96
  [69] open_scope(f::Finch.var"#603#606"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:37
  [70] (::Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol})(ctx_2::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/looplets/lookups.jl:39
  [71] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [72] contain(f::Finch.var"#42#43"{Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [73] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [74] contain(f::Finch.var"#601#604"{Finch.FinchNotation.FinchNode, Symbol}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [75] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [76] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.LookupStyle)
     @ Finch ~/Projects/Finch.jl/src/looplets/lookups.jl:27
  [77] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.LookupStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [78] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [79] #588
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:25 [inlined]
  [80] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [81] contain(f::Finch.var"#42#43"{Finch.var"#588#590"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [82] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
  [83] contain(f::Finch.var"#588#590"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [84] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [85] #587
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:24 [inlined]
  [86] (::Finch.var"#42#43"{Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler})(code_2::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:54
  [87] contain(f::Finch.var"#42#43"{Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
  [88] contain(f::Function, ctx::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:111
  [89] contain(f::Finch.var"#587#589"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
  [90] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
  [91] lower
     @ ~/Projects/Finch.jl/src/looplets/thunks.jl:22 [inlined]
  [92] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.ThunkStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [93] lower_loop(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ext::Finch.Extent)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:266
  [94] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:207
  [95] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
  [96] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
  [97] #48
     @ ~/Projects/Finch.jl/src/lower.jl:155 [inlined]
  [98] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
  [99] contain(f::Finch.var"#42#43"{Finch.var"#48#58"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [100] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
 [101] contain(f::Finch.var"#48#58"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [102] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [103] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:154
 [104] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
 [105] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
 [106] #49
     @ ~/Projects/Finch.jl/src/lower.jl:162 [inlined]
 [107] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [108] contain(f::Finch.var"#42#43"{Finch.var"#49#59"{Finch.FinchNotation.FinchNode}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [109] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
 [110] contain(f::Finch.var"#49#59"{Finch.FinchNotation.FinchNode}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [111] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [112] lower(ctx::Finch.FinchCompiler, root::Finch.FinchNotation.FinchNode, ::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:159
 [113] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode, style::Finch.DefaultStyle)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:59
 [114] (::Finch.FinchCompiler)(root::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:58
 [115] (::Finch.var"#279#281")(ctx_3::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/execute.jl:112
 [116] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [117] contain(f::Finch.var"#42#43"{Finch.var"#279#281", Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [118] contain
     @ ~/Projects/Finch.jl/src/environment.jl:111 [inlined]
 [119] contain(f::Finch.var"#279#281", ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [120] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [121] (::Finch.var"#278#280"{Finch.FinchCompiler})(ctx_2::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/execute.jl:111
 [122] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [123] contain(f::Finch.var"#42#43"{Finch.var"#278#280"{Finch.FinchCompiler}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [124] contain(f::Function, ctx::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [125] contain(f::Finch.var"#278#280"{Finch.FinchCompiler}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [126] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [127] lower_global(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
     @ Finch ~/Projects/Finch.jl/src/execute.jl:101
 [128] (::Finch.var"#276#277"{Symbol, DataType})(ctx_2::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/execute.jl:88
 [129] #42
     @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [130] contain(f::Finch.var"#42#43"{Finch.var"#276#277"{Symbol, DataType}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [131] contain(f::Function, ctx::Finch.JuliaContext)
     @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [132] contain(f::Finch.var"#276#277"{Symbol, DataType}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
     @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [133] contain(f::Function, ctx::Finch.FinchCompiler)
     @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [134] #execute_code#275
     @ ~/Projects/Finch.jl/src/execute.jl:85 [inlined]
 [135] macro expansion
     @ ~/Projects/Finch.jl/src/execute.jl:62 [inlined]
 [136] var"##execute_impl_generator#236"(ex::Type, algebra::Type, mode::Type)
     @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [137] (::Finch.var"#273#274"{DataType, DataType, DataType})()
     @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [138] #s353#272
     @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [139] var"#s353#272"(::Any, ex::Any, algebra::Any, mode::Any)
     @ Finch ./none:0
 [140] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
     @ Core ./boot.jl:707
 [141] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Matrix{Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
     @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [142] execute
     @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [143] macro expansion
     @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [144] macro expansion
     @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [145] macro expansion
     @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [146] dropfills_helper!(dst::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, src::Matrix{Float64})
     @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [147] dropfills!
     @ ~/Projects/Finch.jl/src/interface/copy.jl:99 [inlined]
 [148] Tensor(lvl::SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}, arr::Matrix{Float64})
     @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
```

![COO Format Index Tree](../../assets/levels-A-sc2-e.png)

The COO format is compact and straightforward, but doesn't support random
access. For random access, one should use the `SparseDict` or `SparseBytemap` format. A full listing
of supported formats is described after a rough description of shared common internals of level,
relating to types and storage.

## Types and Storage of Level

All levels have a `postype`, typically denoted as `Tp` in the constructors, used for internal pointer types but accessible by the
function:

```@docs
postype
```

Additionally, many levels have a `Vp` or `Vi` in their constructors; these stand for vector of element type `Tp` or `Ti`.
More generally, levels are paramterized by the types that they use for storage. By default, all levels use `Vector`, but a user
could could change any or all of the storage types of a tensor so that the tensor would be stored on a GPU or CPU or some combination thereof,
or even just via a vector with a different allocation mechanism.  The storage type should behave like `AbstractArray`
and needs to implement the usual abstract array functions and `Base.resize!`. See the tests for an example.

When levels are constructed in short form as in the examples above, the index, position, and storage types are inferred
from the level below. All the levels at the bottom of a Tensor (`Element, Pattern, Repeater`) specify an index type, position type,
and storage type even if they don't need them. These are used by levels that take these as parameters.

## Level Methods

Tensor levels are implemented using the following methods:

```@docs
declare_level!
assemble_level!
reassemble_level!
freeze_level!
level_ndims
level_size
level_axes
level_eltype
level_fill_value
```

# Combinator Interface

Tensor Combinators allow us to modify the behavior of tensors. The `AbstractCombinator` interface (defined in [`src/tensors/abstract_combinator.jl`](https://github.com/finch-tensor/Finch.jl/blob/main/src/tensors/abstract_combinator.jl)) is the interface through which Finch understands tensor combinators. The interface requires the combinator to overload all of the tensor methods, as well as the methods used by Looplets when lowering ranges, etc. For a minimal example, read the definitions in [`/src/tensors/combinators/offset.jl`](https://github.com/finch-tensor/Finch.jl/blob/main/src/tensors/combinators/offset.jl).