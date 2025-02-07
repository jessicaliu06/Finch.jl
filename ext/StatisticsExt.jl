module StatisticsExt

using Finch
using Finch: LazyTensor
using Finch: AbstractTensor
using Finch: AbstractTensorOrBroadcast
using Finch.FinchLogic
using Finch: fixpoint_type, identify

isdefined(Base, :get_extension) ? (using Statistics) : (using ..Statistics)

"""
"""
    Statistics.mean(tns:: LazyTensor; dims=:) = _mean(identity, tns, dims)

"""
"""
    Statistics.mean(f, tns:: LazyTensor; dims=:) = _mean(f, tns, dims)

"""
"""
    Statistics.mean(tns:: AbstractTensorOrBroadcast; dims=:) = compute(_mean(identity, lazy(tns), dims))

"""
"""
    Statistics.mean(f, tns:: AbstractTensorOrBroadcast; dims=:) = compute(_mean(f, lazy(tns), dims))

function _premean(logic, tns:: LazyTensor{T, N}, dims=:) where {T, N}
    dims = dims == Colon() ? (1:N) : collect(dims)
    extrude = ((tns.extrude[n] for n in 1:N if !(n in dims))...,)
    shape = ((tns.shape[n] for n in 1:N if !(n in dims))...,)
    init = 0
    fields = [field(gensym(:i)) for _ in 1:N]
    S = fixpoint_type(+, init, eltype(tns))
    data = aggregate(immediate(+), immediate(init), logic(tns.data, fields), fields[dims]...)
    n = mapreduce(i -> tns.shape[i], *, unique(dims); init=1)
    result = LazyTensor{S}(identify(data), extrude, shape, init)
    return (result, n)
end

function _mean(f, tns:: LazyTensor{T, N}, dims=:) where {T, N}
    logic = (arr, fields) -> mapjoin(immediate(f), relabel(arr, fields))
    result, count = _premean(logic, tns, dims)
    return result ./ count
end


"""
"""
    Statistics.varm(tns:: LazyTensor, m; corrected=true, dims=:) = _varm(tns, m, corrected, dims)

"""
"""
    Statistics.varm(tns:: AbstractTensorOrBroadcast, m; corrected=true, dims=:) = compute(_varm(lazy(tns), m, corrected, dims))


function _varm(tns::LazyTensor{T, N}, m::LazyTensor{T2, N2}, corrected=true, dims=:) where {T, N, T2, N2}
    logic = (arr, fields) -> mapjoin(immediate(abs2), mapjoin(immediate(-), relabel(arr, fields), relabel(m.data, fields)))
    result, count = _premean(logic, tns, dims)
    return result ./ (count - corrected)
end

"""
"""
    Statistics.var(tns:: LazyTensor; corrected=true, mean=nothing, dims=:) = _var(tns, corrected, mean, dims)
"""
"""
    Statistics.var(tns:: AbstractTensorOrBroadcast; corrected=true, mean=nothing, dims=:) = compute(_var(lazy(tns), corrected, mean, dims))

function _var(tns::LazyTensor, corrected, m, dims)
  if m === nothing
      m = Statistics.mean(tns; dims=dims)
      m = expanddims(m, (ndims(m)+1):ndims(tns))
    #   mean = dims === Colon() ? mean[] : mean
  end
  return varm(tns, m; corrected=corrected, dims=dims)
end

"""
"""
#TODO: Use stable LinearAlgebra.norm
    Statistics.std(tns::Union{LazyTensor, AbstractTensorOrBroadcast}; corrected=true, mean=nothing, dims=:) =
        sqrt.(var(tns; corrected=corrected, mean=mean, dims=dims))

end
