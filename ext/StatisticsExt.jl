module StatisticsExt

using Finch
using Finch: LazyTensor
using Finch: AbstractTensor
using Finch: AbstractTensorOrBroadcast

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

function _mean(f, tns:: LazyTensor{T, N}, dims=:) where {T, N}
    dims = dims == Colon() ? (1:N) : collect(dims)
    n = mapreduce(i -> tns.shape[i], *, unique(dims); init=1)
    result = sum(tns; dims=dims)
    return result ./ n
end

end