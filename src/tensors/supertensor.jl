"""
    SuperTensor{N,B,T} <: AbstractArray{T,N}

`SuperTensor{N,B,T}` is an abstract representation of a high-order tensor
with `N` dimensions, where `B` is number of modes of the underlying base array 
and `T` is the type of the elements in the array.
"""
struct SuperTensor{N,B,T} <: AbstractArray{T,N}
	shape::NTuple{N,Int}          # Logical shape of the tensor represented by the SuperTensor
    base::Array{T,B}              # Base tensor
    map::NTuple{N,Int}            # Maps each dimension of the tensor to a dimension of the base tensor (1 through B)
end

Base.IndexStyle(::Type{<:SuperTensor}) = IndexCartesian()

"""
    SuperTensor(shape::NTuple{N,Int}, base::Array{T,B}, map::NTuple{N,Int}) where {N,B,T}

Constructs a `SuperTensor` of order `N` given its logical shape, a base tensor of order `B`,
and a mapping `map` that maps each mode of the logical tensor to a mode of the base tensor.
This constructor is to be used primarily as a helper function for the other constructor.
"""
function SuperTensor(shape::NTuple{N,Int}, base::Array{T,B}, map::NTuple{N,Int}) where {N,B,T}
    return SuperTensor{N,B,T}(shape, base, map)
end

"""
    SuperTensor(arr::AbstractArray{T,N}, map::NTuple{N,Int}) where {T,N}

Constructs a `SuperTensor` given an input tensor `arr` of order `N` and a mapping `map` that maps each
mode of the input tensor to a mode of the base tensor.

The mapping `map` must be a tuple of length `N`, where each entry is an integer between `1` and `B` and
`B` is the number of modes desired in the base tensor. For example, if the input tensor has shape `(3, 4, 5, 6)`
and we want the base tensor to have shape `(12, 30)`, we would use `map = (1, 1, 2, 2)`.

This constructor computes the shape of the base tensor and reshapes the input tensor into the base tensor,
including any necessary permutations (i.e., transpositions) of the modes.
"""
function SuperTensor(arr::AbstractArray{T,N}, map::NTuple{N,Int}) where {T,N}
    # NOTE: The modes of the input tensor are indexed from 1 to N, and the modes of the base tensor are indexed from 1 to B.

    # Get the dimensions of the input tensor.
    shape = size(arr)

    # Compute the shape of the base tensor by multiplying together the sizes of the logical modes that map to each base mode.
    B = maximum(map)
    base_shape = ntuple(b -> prod(shape[d] for d in 1:N if map[d] == b), B)

    # Permute the array so that logical modes mapped to the same base mode are next to each other.
    groups = [findall(d -> map[d] == b, 1:N) for b in 1:B]      # Group logical modes by their corresponding base mode.
    perm = vcat(groups...)                                      # Create a permutation of the modes that places logical modes that are going to the same base mode next to each other.
    permuted_arr = permutedims(arr, perm)                       # Permute (i.e., transpose) the array according to this permutation.

    # Reshape the permuted array into the shape of the base tensor.
    base = reshape(permuted_arr, base_shape)
    return SuperTensor{N,B,T}(shape, base, map)
end

"""
    Base.size(A::SuperTensor)

Returns a tuple containing the logical dimensions of `A`. Specifically, this refers to
the dimensions of the tensor represented by the SuperTensor, not the dimensions of the base tensor.
"""
function Base.size(A::SuperTensor)
    return A.shape
end

"""
    Base.getindex(A::SuperTensor{N,B}, I::Vararg{Int, N}) where {N,B}

Returns the value at a specified coordinate of `A`. The input coordinate is a logical coordinate
corresponding to the tensor represented by the SuperTensor. These logical coordinates must first
be converted to coordinates on the base tensor.
"""
function Base.getindex(A::SuperTensor{N,B}, I::Vararg{Int, N}) where {N,B}
    # Convert logical coordinates to base coordinates
    base_idcs = Vector{Int}(undef, B)

    # For each base tensor mode, find the logical modes which have been mapped to this base mode.
    for b in 1:B
        dims = [d for d in 1:N if A.map[d] == b]

        # If only one logical mode maps to this base mode, we can directly use the logical mode.
        if length(dims) == 1
            base_idcs[b] = I[dims[1]]
        else # Otherwise, multiple logical modes map to this base mode, so we need to flatten them and compute the linear coordinate in the flattened array.
            subshape = A.shape[dims]                                    # Get the shape of the subarray formed by the logical modes that map to this single base mode.
            subidcs = ntuple(k -> I[dims[k]], length(dims))             # Get the logical coordinate corresponding to these logical modes.
            base_idcs[b] = LinearIndices(subshape)[subidcs...]          # Compute the linear coordinate in the subarray.
                                                                        # Map the Cartesian coordinates to a single linear coordinate (i.e., index in the base array).
        end
    end

    return A.base[base_idcs...]
end

function einsum(C_idcs::Vector{Symbol}, A::Array, A_idcs::Vector{Symbol}, B::Array, B_idcs::Vector{Symbol}, extra_C_dims::Dict{Symbol,Int}=Dict{Symbol,Int}())
    all_idcs = union(A_idcs, B_idcs, C_idcs)            # All indices that appear in A, B, or C.
    sum_idcs = setdiff(all_idcs, C_idcs)                # We will sum over indices which are NOT in C.

    ranges = Dict{Symbol,UnitRange{Int}}()              # Maps each index symbol in A or B to the range in the corresponding mode.
    for (sym, size) in zip(A_idcs, size(A))             # e.g. i -> 1:5, j -> 1:3, k -> 1:4, etc.
        ranges[sym] = 1:size
    end
    for (sym, size) in zip(B_idcs, size(B))
        ranges[sym] = 1:size
    end

    if extra_C_dims !== nothing && !isempty(extra_C_dims)
        # Also add any extra indices in C which are not present in A or B.
        for sym in C_idcs
            if !haskey(ranges, sym) && haskey(extra_C_dims, sym)
                ranges[sym] = 1:extra_C_dims[sym]
            end
        end
    end

    # Determine the shape of C by finding the sizes of the indices in C.
    C_shape = Tuple(ranges[sym].stop for sym in C_idcs)
    C = zeros(Int, C_shape)

    # Iterate over each coordinate in the output C to compute its value.
    for C_coord in CartesianIndices(C_shape)                  
        coord_map = Dict{Symbol,Int}()                      # Maps each output index symbol to its current coordinate in the output.
        for (k, sym) in enumerate(C_idcs)
            coord_map[sym] = C_coord[k]                     # e.g. if C_coord = (2, 3) and C_idcs = [:i, :j], then coord_map contains the mappings :i -> 2 and :j -> 3
        end

        sum = 0
        for coord in Iterators.product((ranges[sym] for sym in sum_idcs)...)        # Iterate over all coordinates in the set of modes which will be summed over.
            for (k, sym) in enumerate(sum_idcs)                                     # Map each summation index symbol to its current coordinate in the summation.
                coord_map[sym] = coord[k]
            end

            A_coord = Tuple(coord_map[sym] for sym in A_idcs)                       # Determine coordinates in A and B using the index mapping.
            B_coord = Tuple(coord_map[sym] for sym in B_idcs)
            sum += A[A_coord...] * B[B_coord...]                                    # Add the product to the running sum.
        end

        C[C_coord] = sum
    end

    return C
end

function supertensor_einsum(C_idcs::Vector{Symbol}, A::Array, A_idcs::Vector{Symbol}, B::Array, B_idcs::Vector{Symbol}, extra_C_dims::Dict{Symbol,Int}=Dict{Symbol,Int}())
    # Objective: Reshape operands A and B into SuperTensors order-2 base tensors, then perform einsum on the base tensors.
    # Final format: C_ijk = A_ip B_pj      

	A_and_B_idcs = sort(collect(intersect(A_idcs, B_idcs)))     # Indices that appear in both A and B.  (will be grouped into index p)
    A_free_idcs = sort(collect(setdiff(A_idcs, B_idcs)))        # Indices that appear only in A and C.  (will be grouped into index i)
    B_free_idcs = sort(collect(setdiff(B_idcs, A_idcs) ))       # Indices that appear only in B and C.  (will be grouped into index j)
    C_only_idcs = setdiff(C_idcs, union(A_idcs, B_idcs))        # Indices that appear only in C.        (will be grouped into index k)

    perm_A = vcat([findfirst(==(sym), A_idcs) for sym in A_free_idcs],
                  [findfirst(==(sym), A_idcs) for sym in A_and_B_idcs])

    perm_B = vcat([findfirst(==(sym), B_idcs) for sym in A_and_B_idcs],
                  [findfirst(==(sym), B_idcs) for sym in B_free_idcs])

    perm_C = vcat([findfirst(==(sym), C_idcs) for sym in A_free_idcs],
                  [findfirst(==(sym), C_idcs) for sym in B_free_idcs],
                  [findfirst(==(sym), C_idcs) for sym in C_only_idcs])

    A_perm = permutedims(A, perm_A)
    B_perm = permutedims(B, perm_B)

    A_idcs_perm = A_idcs[perm_A]
    B_idcs_perm = B_idcs[perm_B]
    C_idcs_perm = C_idcs[perm_C]

    mapA = ntuple(length(A_idcs)) do i
        if A_idcs_perm[i] in A_free_idcs
            1
        else
            2
        end
    end

    mapB = ntuple(length(B_idcs)) do i
        if B_idcs_perm[i] in A_and_B_idcs
            1
        else
            2
        end
    end

    superTensorA = SuperTensor(A_perm, mapA)
    superTensorB = SuperTensor(B_perm, mapB)

    A_base_idcs = [:i, :p]
    B_base_idcs = [:p, :j]
    C_base_idcs = !isempty(extra_C_dims) ? [:i, :j, :k] : [:i, :j]

    C_base = einsum(C_base_idcs,
                    superTensorA.base, A_base_idcs,
                    superTensorB.base, B_base_idcs,
                    extra_C_dims!==nothing ? Dict(:k => !isempty(extra_C_dims) ? prod(extra_C_dims[sym] for sym in C_only_idcs) : 0) : nothing)

    return C_base
end