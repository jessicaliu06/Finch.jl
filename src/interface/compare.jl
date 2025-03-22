@staged function helper_equal(A, B)
    idxs = [Symbol(:i_, n) for n in 1:ndims(A)]
    exts = Expr(:block, (:($idx = _) for idx in reverse(idxs))...)
    return quote
        size(A) == size(B) || return false
        check = Scalar(true)
        @finch $(Expr(
            :for,
            exts,
            quote
                check[] &= (A[$(idxs...)] == B[$(idxs...)])
            end,
        ))
        return check[]
    end
end

function Base.:(==)(A::AbstractTensor, B::AbstractTensor)
    return helper_equal(A, B)
end

function Base.:(==)(A::AbstractTensor, B::AbstractArray)
    return helper_equal(A, B)
end

function Base.:(==)(A::AbstractArray, B::AbstractTensor)
    return helper_equal(A, B)
end

@staged function helper_isequal(A, B)
    idxs = [Symbol(:i_, n) for n in 1:ndims(A)]
    exts = Expr(:block, (:($idx = _) for idx in reverse(idxs))...)
    return quote
        size(A) == size(B) || return false
        check = Scalar(true)
        @finch $(Expr(
            :for,
            exts,
            quote
                check[] &= isequal(A[$(idxs...)], B[$(idxs...)])
            end,
        ))
        return check[]
    end
end

function Base.isequal(A::AbstractTensor, B::AbstractTensor)
    return helper_isequal(A, B)
end

function Base.isequal(A::AbstractTensor, B::AbstractArray)
    return helper_isequal(A, B)
end

function Base.isequal(A::AbstractArray, B::AbstractTensor)
    return helper_isequal(A, B)
end

function helper_argmin(A, dims)
    @assert 1 <= dims <= length(size(A))
    if (length(size(A)) >= 2)
        return map(x -> x[2], reduce(minby, map(Pair, A, CartesianIndices(size(A))), dims=dims, init=Inf=>CartesianIndex(fill(0, length(size(A)))...)))
    else
        return map(x -> x[2], reduce(minby, map(Pair, A, 0), dims=dims, init=Inf=>0))
    end
end

function Base.argmin(A::AbstractTensor, dims::Number)
    return helper_argmin(A, dims)
end

function Base.argmin(A::AbstractArray, dims::Number)
    return helper_argmin(A, dims)
end

function helper_argmax(A, dims)
    @assert 1 <= dims <= length(size(A))
    if (length(size(A)) >= 2)
        return map(x -> x[2], reduce(maxby, map(Pair, A, CartesianIndices(size(A))), dims=dims, init=-Inf=>CartesianIndex(fill(0, length(size(A)))...)))
    else
        return map(x -> x[2], reduce(maxby, map(Pair, A, 0), dims=dims, init=-Inf=>0))
    end
end

function Base.argmax(A::AbstractTensor, dims::Number)
    return helper_argmax(A, dims)
end

function Base.argmin(A::AbstractArray, dims::Number)
    return helper_argmax(A, dims)
end
