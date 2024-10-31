```@meta
CurrentModule = Finch
```
# Optimization Tips for Finch

It's easy to ask Finch to run the same operation in different ways. However,
different approaches have different performance. The right approach really
depends on your particular situation. Here's a collection of general approaches
that help Finch generate faster code in most cases.

## Concordant Iteration

By default, Finch stores arrays in column major order (first index fast). When
the storage order of an array in a Finch expression corresponds to the loop
order, we call this
*concordant* iteration. For example, the following expression represents a
concordant traversal of a sparse matrix, as the outer loops access the higher
levels of the tensor tree:

```jldoctest example1; setup=:(using Finch)
A = Tensor(Dense(SparseList(Element(0.0))), fsparse([2, 3, 4, 1, 3], [1, 1, 1, 3, 3], [1.1, 2.2, 3.3, 4.4, 5.5], (4, 3)))
s = Scalar(0.0)
@finch for j=_, i=_ ; s[] += A[i, j] end

# output

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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:96 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

We can investigate the generated code with `@finch_code`.  This code iterates
over only the nonzeros in order. If our matrix is `m × n` with `nnz` nonzeros,
this takes `O(n + nnz)` time.

```jldoctest example1
@finch_code for j=_, i=_ ; s[] += A[i, j] end

# output

ERROR: UndefVarError: `s` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] macro expansion
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157 [inlined]
 [2] top-level scope
   @ none:217
```


When the loop order does not correspond to storage order, we call this
*discordant* iteration. For example, if we swap the loop order in the
above example, then Finch needs to randomly access each sparse column for each
row `i`. We end up needing to find each `(i, j)` pair because we don't know
whether it will be zero until we search for it. In all, this takes time
`O(n * m * log(nnz))`, much less efficient! We shouldn't randomly access sparse
arrays unless we really need to and they support it efficiently!

Note the double for loop in the following code

```jldoctest example1
@finch_code for i=_, j=_ ; s[] += A[i, j] end # DISCORDANT, DO NOT DO THIS

# output

ERROR: UndefVarError: `s` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] macro expansion
   @ ~/Projects/Finch.jl/src/FinchNotation/syntax.jl:157 [inlined]
 [2] top-level scope
   @ none:217
```

TL;DR: As a quick heuristic, if your array indices are all in alphabetical order, then
the loop indices should be reverse alphabetical.

## Appropriate Fill Values

The @finch macro requires the user to specify an output format. This is the most
flexibile approach, but can sometimes lead to densification unless the output
fill value is appropriate for the computation.

For example, if `A` is `m × n` with `nnz` nonzeros, the following Finch kernel will
densify `B`, filling it with `m * n` stored values:

```jldoctest example1
A = Tensor(Dense(SparseList(Element(0.0))), fsparse([2, 3, 4, 1, 3], [1, 1, 1, 3, 3], [1.1, 2.2, 3.3, 4.4, 5.5], (4, 3)))
B = Tensor(Dense(SparseList(Element(0.0)))) #DO NOT DO THIS, B has the wrong fill value
@finch (B .= 0; for j=_, i=_; B[i, j] = A[i, j] + 1 end; return B)
countstored(B)

# output

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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:96 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

Since `A` is filled with `0.0`, adding `1` to the fill value produces `1.0`. However, `B` can only represent a fill value of `0.0`. Instead, we should specify `1.0` for the fill.

```jldoctest example1
A = Tensor(Dense(SparseList(Element(0.0))), fsparse([2, 3, 4, 1, 3], [1, 1, 1, 3, 3], [1.1, 2.2, 3.3, 4.4, 5.5], (4, 3)))
B = Tensor(Dense(SparseList(Element(1.0))))
@finch (B .= 1; for j=_, i=_; B[i, j] = A[i, j] + 1 end; return B)
countstored(B)

# output

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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:96 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

## Static Versus Dynamic Values

In order to skip some computations, Finch must be able to determine the value of
program variables. Continuing our above example, if we obscure the value of `1`
behind a variable `x`, Finch can only determine that `x` has type `Int`, not that it is `1`.

```jldoctest example1
A = Tensor(Dense(SparseList(Element(0.0))), fsparse([2, 3, 4, 1, 3], [1, 1, 1, 3, 3], [1.1, 2.2, 3.3, 4.4, 5.5], (4, 3)))
B = Tensor(Dense(SparseList(Element(1.0))))
x = 1 #DO NOT DO THIS, Finch cannot see the value of x anymore
@finch (B .= 1; for j=_, i=_; B[i, j] = A[i, j] + x end; return B)
countstored(B)

# output

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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:96 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

However, there are some situations where you may want a value to be dynamic. For example, consider the function `saxpy(x, a, y) = x .* a .+ y`. Because we do not know the value of `a` until we run the function, we should treat it as dynamic, and the following implementation is reasonable:

```julia
function saxpy(x, a, y)
    z = Tensor(SparseList(Element(0.0)))
    @finch (z .= 0; for i=_; z[i] = a * x[i] + y[i] end; return z)
end
```

## Use Known Functions

Unless you declare the properties of your functions using Finch's [User-Defined Functions](@ref) interface, Finch doesn't know how they work. For example, using a lambda obscures
the meaning of `*`.

```jldoctest example1
A = Tensor(Dense(SparseList(Element(0.0))), fsparse([2, 3, 4, 1, 3], [1, 1, 1, 3, 3], [1.1, 2.2, 3.3, 4.4, 5.5], (4, 3)))
B = ones(4, 3)
C = Scalar(0.0)
f(x, y) = x * y # DO NOT DO THIS, Obscures *
@finch (C .= 0; for j=_, i=_; C[] += f(A[i, j], B[i, j]) end; return C)

# output

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
 [23] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [24] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_2}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i_1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.DefineInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:src}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.SieveInstance{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:!}, Finch.FinchNotation.LiteralInstance{!}}, Tuple{Finch.FinchNotation.CallInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:isequal}, Finch.FinchNotation.LiteralInstance{isequal}}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}, Finch.FinchNotation.LiteralInstance{0.0}}}}}, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:dst}, Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_1}, Finch.FinchNotation.IndexInstance{:i_1}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i_2}, Finch.FinchNotation.IndexInstance{:i_2}}}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:tmp}, Finch.FinchNotation.VariableInstance{:tmp}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:dst}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [25] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [26] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [27] macro expansion
    @ ~/Projects/Finch.jl/src/interface/copy.jl:77 [inlined]
 [28] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [29] dropfills_helper!(dst::Tensor{DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, src::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [30] dropfills!
    @ ~/Projects/Finch.jl/src/interface/copy.jl:96 [inlined]
 [31] Tensor(lvl::DenseLevel{Int64, SparseListLevel{Int64, Vector{Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, arr::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}})
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:44
 [32] top-level scope
    @ none:1
```

Checking the generated code, we see that this code is indeed densifying (notice the for-loop which repeatedly evaluates `f(B[i, j], 0.0)`).

```jldoctest example1
@finch_code (C .= 0; for j=_, i=_; C[] += f(A[i, j], B[i, j]) end; return C)

# output

ERROR: UndefVarError: `C` not defined in `Main`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
 [1] top-level scope
   @ none:217

```

## Type Stability

Julia code runs fastest when the compiler can [infer the
types](https://docs.julialang.org/en/v1/manual/performance-tips/#Write-%22type-stable%22-functions)
of all intermediate values.  Finch does not check that the generated code is
type-stable. In situations where tensors have nonuniform index or element types,
or the computation itself might involve multiple types, one should check that
the output of `@finch_kernel` code is type-stable with
[`@code_warntype`](https://docs.julialang.org/en/v1/stdlib/InteractiveUtils/#InteractiveUtils.@code_warntype).