using Debugger

"""
    SuperTensor{N,B,T} <: AbstractArray{T,N}

`SuperTensor{N,B,T}` is an abstract representation of a high-order tensor
with order `N`, where `B` is number of modes of the underlying base array 
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
    base_shape = ntuple(
        b -> begin
            dims = [shape[d] for d in 1:N if map[d] == b]
            isempty(dims) ? 1 : prod(dims)
        end, B
    )

    # Permute the array so that logical modes mapped to the same base mode are next to each other.
    groups = [findall(d -> map[d] == b, 1:N) for b in 1:B]      # Group logical modes by their corresponding base mode.
    perm = vcat(groups...)                                      # Create a permutation of the modes that places logical modes that are going to the same base mode next to each other.
    permuted_arr = permutedims(arr, perm)                       # Permute (i.e., transpose) the array according to this permutation.

    # Reshape the permuted array into the shape of the base tensor.
    base = reshape(permuted_arr, base_shape)
    return SuperTensor{N,B,T}(shape, base, map)
end

function SuperTensor(arr::AbstractArray{T,N}, map::NTuple{N,Symbol}, base_idcs::Vector{Symbol}) where {T,N}
    # Get the dimensions of the input tensor.
    shape = size(arr)

    # Compute the shape of the base tensor by multiplying together the sizes of the logical modes that map to each base index.
    base_shape = ntuple(i -> begin
        b = base_idcs[i]
        dims = [shape[d] for d in 1:N if map[d] == b]
        isempty(dims) ? 1 : prod(dims)
    end, length(base_idcs))

    # Permute the array so that logical modes mapped to the same base index are next to each other.
    groups = [findall(d -> map[d] == b, 1:N) for b in base_idcs]    # Group logical modes by their corresponding base index.
    perm = vcat(groups...)                                          # Create a permutation of the modes that places logical modes that are going to the same base index next to each other.
    permuted_arr = permutedims(arr, perm)                           # Permute (i.e., transpose) the array according to this permutation.

    # Reshape the permuted array into the shape of the base tensor.
    base = reshape(permuted_arr, base_shape)

    # Construct a map in the right format for the underlying struct.
    symbol_to_number = Dict{Symbol, Int}()
    for (i, sym) in enumerate(base_idcs)
        symbol_to_number[sym] = i
    end
    final_map = ntuple(n -> symbol_to_number[map[n]], N)

    B = length(base_idcs)
    return SuperTensor{N,B,T}(shape, base, final_map)
end

function SuperTensor(arr::AbstractArray{T,N}, base_idcs::Vector{Tuple{Symbol, Vector{Int}}}) where {T,N}
    # Get the dimensions of the input tensor.
    shape = size(arr)

    # Map each logical mode to its corresponding base index symbol.
    logical_modes_map = Dict{Int, Symbol}()   
    for (sym, logical_modes) in base_idcs
        for m in logical_modes
            logical_modes_map[m] = sym
        end
    end

    # Compute the shape of the base tensor by multiplying together the sizes of the logical modes that correspond to each base index.
    base_shape = ntuple(i -> begin
        base_idx, logical_modes = base_idcs[i]
        dims = [shape[mode] for mode in logical_modes]
        isempty(dims) ? 1 : prod(dims)
    end, length(base_idcs))

    # Permute the array so that logical modes mapped to the same base index are next to each other.
    groups = [logical_modes for (_, logical_modes) in base_idcs]   # Group logical modes by their corresponding base index in the given orders of base indices and logical modes.
    perm = vcat(groups...)                                         # Create a permutation of the modes in the order specified.
    permuted_arr = permutedims(arr, perm)                          # Permute (i.e., transpose) the array according to this permutation.

    # Reshape the permuted array into the shape of the base tensor.
    base = reshape(permuted_arr, base_shape)

    # Construct a map in the right format for the underlying struct.
    symbol_to_number = Dict{Symbol, Int}()
    for (i, (sym, _)) in enumerate(base_idcs)
        symbol_to_number[sym] = i
    end
    final_map = ntuple(n -> symbol_to_number[logical_modes_map[n]], N)

    B = length(base_idcs)
    return SuperTensor{N,B,T}(shape, base, final_map)
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

function einsum(C_idcs::Vector{Symbol}, A::Array, A_idcs::Vector{Symbol}, B::Array, B_idcs::Vector{Symbol})
    all_idcs = union(A_idcs, B_idcs, C_idcs)            # All indices that appear in A, B, or C.
    sum_idcs = setdiff(all_idcs, C_idcs)                # We will sum over indices which are NOT in C.

    ranges = Dict{Symbol,UnitRange{Int}}()              # Maps each index symbol in A or B to the range in the corresponding mode.
    for (sym, size) in zip(A_idcs, size(A))             # e.g. i -> 1:5, j -> 1:3, k -> 1:4, etc.
        ranges[sym] = 1:size
    end
    for (sym, size) in zip(B_idcs, size(B))
        ranges[sym] = 1:size
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

"""
    supertensor_einsum(C_idcs::Vector{Symbol}, inputs::Vector{Tuple{Array, Vector{Symbol}}})

NOTE: This function assumes that there are two input tensors, but the logic is generalized for more than two inputs.
"""
function supertensor_einsum(output_idcs::Vector{Symbol}, inputs::Vararg{Tuple{Array, Vector{Symbol}}})
    # ========== STEP 1 ==========
    # Determine the set of tensors that each index appears in.

    idx_appearances = Dict{Symbol, Set{Symbol}}()   # Maps each index symbol to the set of tensors it appears in
                                                    # e.g. :i -> Set([:T1, :T2]), :j -> Set([:T1, :out]), etc.
    
    # Iterate over the index lists of all input tensors in order to collect the tensors in which each index appears.
    for (i, (_, idcs)) in enumerate(inputs)        
        tensor_name = Symbol("T", i)                                        # Name the input tensors in the order provided: :T1, :T2, etc.
        for s in idcs
            tensor_appearances = get!(idx_appearances, s, Set{Symbol}())    # Get the set of tensors in which this index appears.  
            push!(tensor_appearances, tensor_name)                          # Add the current tensor to this set of appearances.
        end
    end
    # Similarly, record the indices which appear in the output.
    for s in output_idcs
        tensor_appearances = get!(idx_appearances, s, Set{Symbol}())
        push!(tensor_appearances, :out)                                     # Name the output tensor :out.
    end

    # ========== STEP 2 ==========
    # Group the indices which appear in exactly the same set of tensors. These groups will later be merged into single indices in the SuperTensors.

    idx_groups = Dict{Set{Symbol}, Vector{Symbol}}()        # Maps each unique set of tensor appearances to the group of index symbols that appear in exactly that set of tensors.
                                                            # e.g. Set([:T1, :T2]) -> [:i, :j], Set([:T1, :out]) -> [:k], etc.
    
    # Assign each index to a group based on the set of tensors it appears in.
    for (idx, appearances) in idx_appearances
        idx_group = get!(idx_groups, appearances, Symbol[])
        push!(idx_group, idx)
    end

    # ========== STEP 3 ==========
    # Assign each group a new index symbol. We identify each group by the set of tensors that the indices in that group appear in.

    # Collect tensor sets (corresonding to index groups) and assign each tensor set (and thereby its index group) a new index symbol.
    tensor_sets = collect(keys(idx_groups));          
    new_idx_map = Dict{Set{Symbol}, Symbol}()               # Map each unique set of tensors (and thereby its index group) to a new index symbol (for the merged index group).
                                                            # e.g. Set([:T1, :T2]) -> :i1, Set([:T1, :out]) -> :i2, etc.
    for (k, tensor_set) in enumerate(tensor_sets)
        new_idx_map[tensor_set] = Symbol("i", k)
    end

    # ========== STEP 4 ==========
    # Construct SuperTensors for each input tensor, along with the merged indices for its base tensor.

    # IMPORTANT: When reshaping an input tensor into its base tensor, we must ensure that the mapping from
    # logical modes to base modes is consistent in all tensors. Specifically, when we flatten a group of indices,
    # we must ensure that it is flattened in the same order in all tensors. 

    # IMPORTANT: When reshaping an input tensor into its base tensor, we need to ensure that index groups that should
    # summed over are adjacent, so that the dimensions are compatible.

    superTensors = Vector{SuperTensor}()
    input_idcs = Vector{Vector{Symbol}}()

    for (i, (arr, idcs)) in enumerate(inputs)
        tensor_name = Symbol("T", i)                                # Name the input tensors in the order provided: :T1, :T2, etc.
                                                                    # This is consistent with how the input tensors were named when determining index appearances in Step 1.
 
        # Map each logical mode in this tensor to its base index symbol.
        logical_mode_map = ntuple(d ->
            begin
                idx = idcs[d]                       # Get the index symbol for this logical mode.
                appearances = idx_appearances[idx]  # Find the set of tensors that this index appears in.
                return new_idx_map[appearances]     # Find the new index symbol assigned to this set of tensors.
            end, length(idcs))

        # Map base index symbols to the list of logical modes that map to this base index.
        base_symbols_to_logical_modes = Dict{Symbol, Vector{Int}}()
        for (logical_mode, sym) in enumerate(logical_mode_map)
            logical_modes = get!(base_symbols_to_logical_modes, sym, Int[])
            push!(logical_modes, logical_mode)
        end

        # Convert the map into a vector of tuples in the form needed for the constructor.
        base_idcs = [(sym, base_symbols_to_logical_modes[sym]) for sym in collect(keys(base_symbols_to_logical_modes))]

        if length(inputs) == 2
            shared_base_idx = new_idx_map[Set([:T1, :T2])]
            if i == 1
                non_shared = filter(x -> x != shared_base_idx, [sym for (sym, _) in base_idcs])
                base_idcs = vcat([(x, base_symbols_to_logical_modes[x]) for x in non_shared],
                                [(shared_base_idx, base_symbols_to_logical_modes[shared_base_idx])])
            elseif i == 2
                non_shared = filter(x -> x != shared_base_idx, [sym for (sym, _) in base_idcs])
                base_idcs = vcat([(shared_base_idx, base_symbols_to_logical_modes[shared_base_idx])],
                                [(x, base_symbols_to_logical_modes[x]) for x in non_shared])
            end
        end
        @bp
        
        # Construct the SuperTensor
        base_idcs = [(sym, Vector{Int}(modes)) for (sym, modes) in base_idcs]
        push!(superTensors, SuperTensor(arr, base_idcs))
        push!(input_idcs, [sym for (sym, _) in base_idcs])
    end

    # ========== STEP 5 ==========
    # Construct the map for the output SuperTensor, along with the merged indices for its base tensor.

    # Map each logical mode in the output tensor to its base index symbol.
    output_logical_mode_map = ntuple(i -> 
        begin
            idx = output_idcs[i]                  # Get the index symbol for this logical mode.
            appearances = idx_appearances[idx]    # Find the set of tensors that this index appears in.
            new_idx_map[appearances]              # Find the new index symbol assigned to this set of tensors.
        end, length(output_idcs))

    # Map base index symbols to the list of logical modes that map to this base index.
    base_symbols_to_logical_modes = Dict{Symbol, Vector{Int}}()
    for (logical_mode, sym) in enumerate(output_logical_mode_map)
        logical_modes = get!(base_symbols_to_logical_modes, sym, Int[])
        push!(logical_modes, logical_mode)
    end

    # Sort the logical modes in each group to ensure consistent ordering.
    for (sym, logical_modes) in base_symbols_to_logical_modes
        base_symbols_to_logical_modes[sym] = sort(logical_modes)
    end

    # Convert the map into a vector of tuples in the form needed for the constructor.
    output_base_idcs = [(sym, base_symbols_to_logical_modes[sym]) for sym in sort(collect(keys(base_symbols_to_logical_modes)))]
    output_idcs_vec = [sym for (sym, _) in output_base_idcs]

    # ========== STEP 6 ==========
    # Call einsum on the base tensors to compute the base tensor of the output.

    output_base = einsum(output_idcs_vec,
        superTensors[1].base, input_idcs[1],
        superTensors[2].base, input_idcs[2])

    # ========== STEP 7 ==========
    # Construct the output SuperTensor.

    # Determine the shape of the output SuperTensor.
    output_shape = ntuple(i -> 
        begin
            output_idx = output_idcs[i]
            input_tensor_with_idx = findfirst(t -> output_idx in inputs[t][2], 1:length(inputs))
            axis_in_base = findfirst(==(output_idx), inputs[input_tensor_with_idx][2])
            size(inputs[input_tensor_with_idx][1], axis_in_base)
        end, length(output_idcs))

    # Map each logical mode to its corresponding base index symbol.
    logical_modes_map = Dict{Int, Symbol}()   
    for (sym, logical_modes) in output_base_idcs
        for m in logical_modes
            logical_modes_map[m] = sym
        end
    end

    # Construct a map in the right format for the underlying struct.
    symbol_to_number = Dict{Symbol, Int}()
    for (i, (sym, _)) in enumerate(output_base_idcs)
        symbol_to_number[sym] = i
    end
    output_map = ntuple(n -> symbol_to_number[logical_modes_map[n]], length(output_shape))
    
    @bp
    return SuperTensor(output_shape, output_base, output_map)
end