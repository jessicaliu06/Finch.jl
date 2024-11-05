```@meta
CurrentModule = Finch
```

# High-Level Array API

Finch tensors also support many of the basic array operations one might expect,
including indexing, slicing, and elementwise maps, broadcast, and reduce.
For example:

```jldoctest example1; setup = :(using Finch)
julia> A = fsparse([1, 1, 2, 3], [2, 4, 5, 6], [1.0, 2.0, 3.0])
3×6-Tensor
└─ SparseCOO{2} (0.0) [:,1:6]
   ├─ [1, 2]: 1.0
   ├─ [1, 4]: 2.0
   └─ [2, 5]: 3.0

julia> A + 0
ERROR: MethodError: instantiate(::Finch.FinchCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Vector{Function}) is ambiguous.

Candidates:
  instantiate(ctx::Finch.AbstractCompiler, fbr::Finch.VirtualSubFiber, mode, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:166
  instantiate(ctx, fbr::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, mode::Finch.FinchNotation.Reader, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/levels/element_levels.jl:162

Possible fix, define
  instantiate(::Finch.AbstractCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Any)

Stacktrace:
  [1] instantiate(ctx::Finch.FinchCompiler, tns::Finch.FinchNotation.FinchNode, mode::Finch.FinchNotation.Reader, protos::Vector{Function})
    @ Finch ~/Projects/Finch.jl/src/tensors/combinators/roots.jl:10
  [2] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:47
  [3] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
  [4] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
  [5] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
  [6] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
  [7] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
  [8] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
  [9] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:50
 [10] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
 [11] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
 [12] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
 [13] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
 [14] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
 [15] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
 [16] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:31
 [17] instantiate!(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:20
 [18] (::Finch.var"#278#280"{Finch.FinchCompiler})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:110
 [19] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [20] contain(f::Finch.var"#42#43"{Finch.var"#278#280"{Finch.FinchCompiler}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [21] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [22] contain(f::Finch.var"#278#280"{Finch.FinchCompiler}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [23] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [24] lower_global(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:101
 [25] (::Finch.var"#276#277"{Symbol, DataType})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:88
 [26] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [27] contain(f::Finch.var"#42#43"{Finch.var"#276#277"{Symbol, DataType}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [28] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [29] contain(f::Finch.var"#276#277"{Symbol, DataType}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [30] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [31] #execute_code#275
    @ ~/Projects/Finch.jl/src/execute.jl:85 [inlined]
 [32] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:62 [inlined]
 [33] var"##execute_impl_generator#236"(ex::Type, algebra::Type, mode::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [34] (::Finch.var"#273#274"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [35] #s353#272
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [36] var"#s353#272"(::Any, ex::Any, algebra::Any, mode::Any)
    @ Finch ./none:0
 [37] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [38] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:scl}, Scalar{0.0, Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:arr}, Finch.SubFiber{ElementLevel{0.0, Float64, Int64, Vector{Float64}}, Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{}}}, Finch.FinchNotation.YieldBindInstance{Tuple{}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [39] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [40] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [41] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:68 [inlined]
 [42] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [43] getindex_helper
    @ ~/Projects/Finch.jl/src/util/staging.jl:51 [inlined]
 [44] getindex
    @ ~/Projects/Finch.jl/src/interface/index.jl:37 [inlined]
 [45] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [46] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [47] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i0}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.InitWriter{0.0}()}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.LiteralInstance{+}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A0}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{0}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:A1}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [48] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [49] ##compute#323
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [50] var"##compute#323"(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ./none:0
 [51] #invokelatest#2
    @ ./essentials.jl:1055 [inlined]
 [52] invokelatest
    @ ./essentials.jl:1052 [inlined]
 [53] (::Finch.LogicExecutor)(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ~/Projects/Finch.jl/src/scheduler/LogicExecutor.jl:79
 [54] compute_parse(ctx::Finch.LogicExecutor, args::Tuple{Finch.LazyTensor{Float64, 2}})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:519
 [55] compute(arg::Finch.LazyTensor{Float64, 2}; ctx::Finch.LogicExecutor, kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:511
 [56] copy
    @ ~/Projects/Finch.jl/src/interface/eager.jl:21 [inlined]
 [57] materialize
    @ ./broadcast.jl:867 [inlined]
 [58] map
    @ ~/Projects/Finch.jl/src/interface/eager.jl:37 [inlined]
 [59] +(::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, ::Int64)
    @ Finch ~/Projects/Finch.jl/src/interface/eager.jl:56

julia> A + 1
ERROR: MethodError: instantiate(::Finch.FinchCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Vector{Function}) is ambiguous.

Candidates:
  instantiate(ctx::Finch.AbstractCompiler, fbr::Finch.VirtualSubFiber, mode, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:166
  instantiate(ctx, fbr::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, mode::Finch.FinchNotation.Reader, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/levels/element_levels.jl:162

Possible fix, define
  instantiate(::Finch.AbstractCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Any)

Stacktrace:
  [1] instantiate(ctx::Finch.FinchCompiler, tns::Finch.FinchNotation.FinchNode, mode::Finch.FinchNotation.Reader, protos::Vector{Function})
    @ Finch ~/Projects/Finch.jl/src/tensors/combinators/roots.jl:10
  [2] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:47
  [3] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
  [4] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
  [5] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
  [6] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
  [7] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
  [8] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
  [9] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:50
 [10] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
 [11] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
 [12] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
 [13] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
 [14] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
 [15] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
 [16] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:31
 [17] instantiate!(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:20
 [18] (::Finch.var"#278#280"{Finch.FinchCompiler})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:110
 [19] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [20] contain(f::Finch.var"#42#43"{Finch.var"#278#280"{Finch.FinchCompiler}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [21] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [22] contain(f::Finch.var"#278#280"{Finch.FinchCompiler}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [23] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [24] lower_global(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:101
 [25] (::Finch.var"#276#277"{Symbol, DataType})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:88
 [26] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [27] contain(f::Finch.var"#42#43"{Finch.var"#276#277"{Symbol, DataType}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [28] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [29] contain(f::Finch.var"#276#277"{Symbol, DataType}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [30] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [31] #execute_code#275
    @ ~/Projects/Finch.jl/src/execute.jl:85 [inlined]
 [32] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:62 [inlined]
 [33] var"##execute_impl_generator#236"(ex::Type, algebra::Type, mode::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [34] (::Finch.var"#273#274"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [35] #s353#272
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [36] var"#s353#272"(::Any, ex::Any, algebra::Any, mode::Any)
    @ Finch ./none:0
 [37] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [38] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:scl}, Scalar{0.0, Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:arr}, Finch.SubFiber{ElementLevel{0.0, Float64, Int64, Vector{Float64}}, Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{}}}, Finch.FinchNotation.YieldBindInstance{Tuple{}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [39] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [40] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [41] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:68 [inlined]
 [42] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [43] getindex_helper
    @ ~/Projects/Finch.jl/src/util/staging.jl:51 [inlined]
 [44] getindex
    @ ~/Projects/Finch.jl/src/interface/index.jl:37 [inlined]
 [45] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [46] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [47] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{1.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{1.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i0}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{1.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.InitWriter{1.0}()}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.LiteralInstance{+}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A0}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{1}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{DenseLevel{Int64, DenseLevel{Int64, ElementLevel{1.0, Float64, Int64, Vector{Float64}}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:A1}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [48] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [49] ##compute#340
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [50] var"##compute#340"(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ./none:0
 [51] #invokelatest#2
    @ ./essentials.jl:1055 [inlined]
 [52] invokelatest
    @ ./essentials.jl:1052 [inlined]
 [53] (::Finch.LogicExecutor)(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ~/Projects/Finch.jl/src/scheduler/LogicExecutor.jl:79
 [54] compute_parse(ctx::Finch.LogicExecutor, args::Tuple{Finch.LazyTensor{Float64, 2}})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:519
 [55] compute(arg::Finch.LazyTensor{Float64, 2}; ctx::Finch.LogicExecutor, kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:511
 [56] copy
    @ ~/Projects/Finch.jl/src/interface/eager.jl:21 [inlined]
 [57] materialize
    @ ./broadcast.jl:867 [inlined]
 [58] map
    @ ~/Projects/Finch.jl/src/interface/eager.jl:37 [inlined]
 [59] +(::Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, ::Int64)
    @ Finch ~/Projects/Finch.jl/src/interface/eager.jl:56

julia> B = A .* 2
ERROR: MethodError: instantiate(::Finch.FinchCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Vector{Function}) is ambiguous.

Candidates:
  instantiate(ctx::Finch.AbstractCompiler, fbr::Finch.VirtualSubFiber, mode, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/fibers.jl:166
  instantiate(ctx, fbr::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, mode::Finch.FinchNotation.Reader, protos)
    @ Finch ~/Projects/Finch.jl/src/tensors/levels/element_levels.jl:162

Possible fix, define
  instantiate(::Finch.AbstractCompiler, ::Finch.VirtualSubFiber{Finch.VirtualElementLevel}, ::Finch.FinchNotation.Reader, ::Any)

Stacktrace:
  [1] instantiate(ctx::Finch.FinchCompiler, tns::Finch.FinchNotation.FinchNode, mode::Finch.FinchNotation.Reader, protos::Vector{Function})
    @ Finch ~/Projects/Finch.jl/src/tensors/combinators/roots.jl:10
  [2] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:47
  [3] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
  [4] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
  [5] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
  [6] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
  [7] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
  [8] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
  [9] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:50
 [10] iterate(g::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, s::Int64)
    @ Base ./generator.jl:48
 [11] collect_to!(dest::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, offs::Int64, st::Int64)
    @ Base ./array.jl:838
 [12] collect_to_with_first!(dest::Vector{Finch.FinchNotation.FinchNode}, v1::Finch.FinchNotation.FinchNode, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, st::Int64)
    @ Base ./array.jl:816
 [13] _collect(c::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}}, ::Base.EltypeUnknown, isz::Base.HasShape{1})
    @ Base ./array.jl:810
 [14] collect_similar(cont::Vector{Finch.FinchNotation.FinchNode}, itr::Base.Generator{Vector{Finch.FinchNotation.FinchNode}, Finch.InstantiateTensors{Finch.FinchCompiler}})
    @ Base ./array.jl:709
 [15] map(f::Finch.InstantiateTensors{Finch.FinchCompiler}, A::Vector{Finch.FinchNotation.FinchNode})
    @ Base ./abstractarray.jl:3371
 [16] (::Finch.InstantiateTensors{Finch.FinchCompiler})(node::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:31
 [17] instantiate!(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:20
 [18] (::Finch.var"#278#280"{Finch.FinchCompiler})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:110
 [19] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [20] contain(f::Finch.var"#42#43"{Finch.var"#278#280"{Finch.FinchCompiler}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [21] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [22] contain(f::Finch.var"#278#280"{Finch.FinchCompiler}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [23] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [24] lower_global(ctx::Finch.FinchCompiler, prgm::Finch.FinchNotation.FinchNode)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:101
 [25] (::Finch.var"#276#277"{Symbol, DataType})(ctx_2::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:88
 [26] #42
    @ ~/Projects/Finch.jl/src/lower.jl:54 [inlined]
 [27] contain(f::Finch.var"#42#43"{Finch.var"#276#277"{Symbol, DataType}, Finch.FinchCompiler}, ctx::Finch.JuliaContext; task::Nothing)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:116
 [28] contain(f::Function, ctx::Finch.JuliaContext)
    @ Finch ~/Projects/Finch.jl/src/environment.jl:111
 [29] contain(f::Finch.var"#276#277"{Symbol, DataType}, ctx::Finch.FinchCompiler; kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/lower.jl:53
 [30] contain(f::Function, ctx::Finch.FinchCompiler)
    @ Finch ~/Projects/Finch.jl/src/lower.jl:52
 [31] #execute_code#275
    @ ~/Projects/Finch.jl/src/execute.jl:85 [inlined]
 [32] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:62 [inlined]
 [33] var"##execute_impl_generator#236"(ex::Type, algebra::Type, mode::Type)
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:30
 [34] (::Finch.var"#273#274"{DataType, DataType, DataType})()
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:54
 [35] #s353#272
    @ ~/Projects/Finch.jl/src/util/staging.jl:63 [inlined]
 [36] var"#s353#272"(::Any, ex::Any, algebra::Any, mode::Any)
    @ Finch ./none:0
 [37] (::Core.GeneratedFunctionStub)(::UInt64, ::LineNumberNode, ::Any, ::Vararg{Any})
    @ Core ./boot.jl:707
 [38] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:scl}, Scalar{0.0, Float64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{}}, Finch.FinchNotation.LiteralInstance{initwrite}, Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:arr}, Finch.SubFiber{ElementLevel{0.0, Float64, Int64, Vector{Float64}}, Int64}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{}}}, Finch.FinchNotation.YieldBindInstance{Tuple{}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [39] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [40] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [41] macro expansion
    @ ~/Projects/Finch.jl/src/interface/index.jl:68 [inlined]
 [42] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [43] getindex_helper
    @ ~/Projects/Finch.jl/src/util/staging.jl:51 [inlined]
 [44] getindex
    @ ~/Projects/Finch.jl/src/interface/index.jl:37 [inlined]
 [45] macro expansion
    @ ~/Projects/Finch.jl/src/execute.jl:78 [inlined]
 [46] macro expansion
    @ ~/Projects/Finch.jl/src/util/staging.jl:59 [inlined]
 [47] execute_impl(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i0}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.InitWriter{0.0}()}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.LiteralInstance{*}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A0}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{2}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:A1}}}}}, algebra::Val{Finch.DefaultAlgebra()}, mode::Val{:fast})
    @ Finch ~/Projects/Finch.jl/src/util/staging.jl:51
 [48] execute(ex::Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.BlockInstance{Tuple{Finch.FinchNotation.DeclareInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{0.0}}, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i1}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.LoopInstance{Finch.FinchNotation.IndexInstance{:i0}, Finch.FinchNotation.Dimensionless, Finch.FinchNotation.AssignInstance{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Updater()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.InitWriter{0.0}()}, Finch.FinchNotation.CallInstance{Finch.FinchNotation.LiteralInstance{*}, Tuple{Finch.FinchNotation.AccessInstance{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A0}, Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}, Finch.FinchNotation.LiteralInstance{Finch.FinchNotation.Reader()}, Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i0}, Finch.FinchNotation.IndexInstance{:i0}}, Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:i1}, Finch.FinchNotation.IndexInstance{:i1}}}}, Finch.FinchNotation.LiteralInstance{2}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.TagInstance{Finch.FinchNotation.VariableInstance{:A1}, Tensor{SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, SparseDictLevel{Int64, Vector{Int64}, Vector{Int64}, Vector{Int64}, Dict{Tuple{Int64, Int64}, Int64}, Vector{Int64}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}}}}}}}, Finch.FinchNotation.YieldBindInstance{Tuple{Finch.FinchNotation.VariableInstance{:A1}}}}}; algebra::Finch.DefaultAlgebra, mode::Symbol)
    @ Finch ~/Projects/Finch.jl/src/execute.jl:56
 [49] execute
    @ ~/Projects/Finch.jl/src/execute.jl:56 [inlined]
 [50] ##compute#357
    @ ~/Projects/Finch.jl/src/execute.jl:184 [inlined]
 [51] var"##compute#357"(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ./none:0
 [52] #invokelatest#2
    @ ./essentials.jl:1055 [inlined]
 [53] invokelatest
    @ ./essentials.jl:1052 [inlined]
 [54] (::Finch.LogicExecutor)(prgm::Finch.FinchLogic.LogicNode)
    @ Finch ~/Projects/Finch.jl/src/scheduler/LogicExecutor.jl:79
 [55] compute_parse(ctx::Finch.LogicExecutor, args::Tuple{Finch.LazyTensor{Float64, 2}})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:519
 [56] compute(arg::Finch.LazyTensor{Float64, 2}; ctx::Finch.LogicExecutor, kwargs::@Kwargs{})
    @ Finch ~/Projects/Finch.jl/src/interface/lazy.jl:511
 [57] copy
    @ ~/Projects/Finch.jl/src/interface/eager.jl:21 [inlined]
 [58] materialize(bc::Base.Broadcast.Broadcasted{Finch.FinchStyle{2}, Nothing, typeof(*), Tuple{Tensor{SparseCOOLevel{2, Tuple{Int64, Int64}, Vector{Int64}, Tuple{Vector{Int64}, Vector{Int64}}, ElementLevel{0.0, Float64, Int64, Vector{Float64}}}}, Int64}})
    @ Base.Broadcast ./broadcast.jl:867

julia> B[1:2, 1:2]
2×2-Tensor
└─ SparseDict (0.0) [:,1:2]
   └─ [:, 2]: SparseDict (0.0) [1:2]
      └─ [1]: 2.0

julia> map(x -> x^2, B)
3×6-Tensor
└─ SparseDict (0.0) [:,1:6]
   ├─ [:, 2]: SparseDict (0.0) [1:3]
   │  └─ [1]: 4.0
   ├─ [:, 4]: SparseDict (0.0) [1:3]
   │  └─ [1]: 16.0
   └─ [:, 5]: SparseDict (0.0) [1:3]
      └─ [2]: 36.0
```

# Array Fusion

Finch supports array fusion, which allows you to compose multiple array operations
into a single kernel. This can be a significant performance optimization, as it
allows the compiler to optimize the entire operation at once. The two functions
the user needs to know about are `lazy` and `compute`. You can use `lazy` to
mark an array as an input to a fused operation, and call `compute` to execute
the entire operation at once. For example:

```jldoctest example1
julia> C = lazy(A);

julia> D = lazy(B);

julia> E = (C .+ D)/2;

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

In the above example, `E` is a fused operation that adds `C` and `D` together
and then divides the result by 2. The `compute` function examines the entire
operation and decides how to execute it in the most efficient way possible.
In this case, it would likely generate a single kernel that adds the elements of `A` and `B`
together and divides each result by 2, without materializing an intermediate.

```@docs
lazy
compute
```

# Einsum

Finch also supports a highly general `@einsum` macro which supports any reduction over any simple pointwise array expression.

```@docs
@einsum
```