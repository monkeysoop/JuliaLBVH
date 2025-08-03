include("aabb.jl")
include("morton_codes.jl")
include("lbvh.jl")



"""
```julia
function Delta(sorted_morton_codes::Vector{MortonCodeT}, i::Int32, codeI::MortonCodeT, j::Int32)::Int32 where {MortonCodeT<:AbstractMortonCodeType}
```

A helper function which tries to find the most significant bit position at which the bits of 2 morton codes differ, if the 2 codes the same than it uses the morton codes indecies

# Arguments
- `sorted_morton_codes`: a sorted vector of the primitives morton codes
- `i`: the index of the first morton code (corresponds to the primitives index)
- `code_i`: the morton code associated with `i`
- `j`: the index of the second morton code (corresponds to the primitives index)

# Returns
- `Int32`: -1 if `j` is an invalid index into `sorted_morton_codes` if the 2 codes don't match then it is equal to the number of bits of the underlying type of the morton codes minus the most significant bits position in which the 2 codes differ if the 2 codes are equal then the primitive indecies are used instead of the morton codes and it is also offset by the types number of bits (this makes it like a secondary condition that is sometimes used in sortings)

# Notes
- this function might be undetermenistic (will result in hugely different tree if there are tiny differences in the sorted morton codes buffer) if different non stable sorts of the morton codes are used
"""
function Delta(sorted_morton_codes::Vector{MortonCodeT}, i::Int32, code_i::MortonCodeT, j::Int32)::Int32 where {MortonCodeT<:AbstractMortonCodeType}
    if ((j < 0) || (j > (length(sorted_morton_codes) - 1)))
        return -1
    end

    code_j::MortonCodeT = sorted_morton_codes[j + 1]
    
    if (code_i == code_j) 
        return (sizeof(MortonCodeT) * 8 + leading_zeros(xor(i, j)))
    end

    return leading_zeros(xor(code_i, code_j))
end

"""
```julia
function DetermineRange(sorted_morton_codes::Vector{MortonCodeType}, idx::Int32)::Tuple{Int32, Int32} where {MortonCodeT<:AbstractMortonCodeType}
```

Calculates the range of primitives in the subtree of each internal node using only the sorted morton codes and the internal nodes index (this is a unique and almost arbitrary index)

# Arguments
- `sorted_morton_codes`: a sorted vector of the primitives morton codes
- `idx`: the current internal nodes index

# Returns
- `Tuple{Int32, Int32}`: a range given by a start and end index corresponding to the primitives in the current nodes subtree 
"""
function DetermineRange(sorted_morton_codes::Vector{MortonCodeT}, idx::Int32)::Tuple{Int32, Int32} where {MortonCodeT<:AbstractMortonCodeType}
    code::MortonCodeT = sorted_morton_codes[idx + 1]
    deltaL::Int32 = Delta(sorted_morton_codes, idx, code, Int32(idx - 1))
    deltaR::Int32 = Delta(sorted_morton_codes, idx, code, Int32(idx + 1))
    d::Int32 = ((deltaR >= deltaL) ? 1 : -1)
    
    deltaMin::Int32 = min(deltaL, deltaR)
    lMax::Int32 = 2
    while (Delta(sorted_morton_codes, idx, code, (idx + (lMax * d))) > deltaMin) 
        lMax *= 2
    end

    l::Int32 = 0
    t::Int32 = (lMax >> 1)
    while (t > 0)
        if (Delta(sorted_morton_codes, idx, code, (idx + (l + t) * d)) > deltaMin) 
            l += t
        end
        
        t >>= 1
    end
    
    jdx::Int32 = idx + l * d
    
    return min(idx, jdx), max(idx, jdx)
end

"""
```julia
function FindSplit(sorted_morton_codes::Vector{MortonCodeType}, first::Int32, last::Int32)::Int32 where {MortonCodeT<:AbstractMortonCodeType}
```

Calculates an index inside a range using morton codes such that it makes the result balanced in terms of the morton codes

# Arguments
- `sorted_morton_codes`: a sorted vector of the primitives morton codes
- `first`: the start of the range
- `last`: the end of the range

# Returns
- `Int32`: an index between `first` and `last` that splits the morton codes somewhat evenly
"""
function FindSplit(sorted_morton_codes::Vector{MortonCodeT}, first::Int32, last::Int32)::Int32 where {MortonCodeT<:AbstractMortonCodeType}
    firstCode::MortonCodeT = sorted_morton_codes[first + 1]
    
    commonPrefix::Int32 = Delta(sorted_morton_codes, first, firstCode, last)
    
    split::Int32 = first
    stride::Int32 = (last - first + 1) >> 1
    
    if (((split + stride) < last) && (Delta(sorted_morton_codes, first, firstCode, (split + stride)) > commonPrefix))
        split += stride
    end
    
    while (stride > 1)
        stride = (stride + 1) >> 1
        if (((split + stride) < last) && (Delta(sorted_morton_codes, first, firstCode, (split + stride)) > commonPrefix))
            split += stride
        end
    end

    return split
end

"""
```julia
function InitLeafs(
    lbvh_nodes::Vector{LBVHNode{N}},
    sorted_morton_codes_with_primitive_indecies::Vector{PrimitiveIndexWithMortonCode{MortonCodeT}},
    primitive_aabbs::Vector{AABB{N}},
    number_of_internal_nodes::UInt32, 
    number_of_leafs::UInt32
) where {N, MortonCodeT<:AbstractMortonCodeType}
```

Initializes the leaf nodes with their primitive indexes and their AABBs (Axis Aligned Bounding Box)

# Arguments
- `lbvh_nodes`: the buffer (vector) containing the LBVH nodes (both the internal and leaf nodes)
- `sorted_morton_codes_with_primitive_indecies`: a vector containing pairs of morton codes and the primitive indexes associated with them sorted by the morton codes
- `primitive_aabbs`: a vector with the primitives AABBs in the original order (in which the primitives came)
- `number_of_internal_nodes`: the number of internal nodes inside `lbvh_nodes`
- `number_of_leafs`: the number of leaf nodes inside `lbvh_nodes`
"""
function InitLeafs(
    lbvh_nodes::Vector{LBVHNode{N}},
    sorted_morton_codes_with_primitive_indecies::Vector{PrimitiveIndexWithMortonCode{MortonCodeT}},
    primitive_aabbs::Vector{AABB{N}},
    number_of_internal_nodes::UInt32, 
    number_of_leafs::UInt32
) where {N, MortonCodeT<:AbstractMortonCodeType}
    for i in 0:(number_of_leafs - 1)
        primitive_index::UInt32 = sorted_morton_codes_with_primitive_indecies[i + 1].primitive_index
        primitive_aabb::AABB{N} = primitive_aabbs[primitive_index + 1]
        leaf_index::UInt32 = (number_of_internal_nodes + i)
        lbvh_nodes[leaf_index + 1] = LBVHNode{N}(INVALID_LEAF_CHILD_POINTER, INVALID_LEAF_CHILD_POINTER, primitive_index, primitive_aabb)
    end
end

"""
```julia
function BuildHierarchy(
    lbvh_nodes::Vector{LBVHNode{N}},
    sorted_morton_codes::Vector{MortonCodeT},
    parent_information::Vector{UInt32},
    number_of_internal_nodes::UInt32
) where {N, MortonCodeT<:AbstractMortonCodeType}
```

Builds the LBVH tree by first calculating the current internal nodes range (the primitives between the starting and end indecies correspond to the primitives in the current internal nodes subtrees primitives) by the morton codes then it calculates the split index for determining where to split the range between its 2 childrens

# Arguments
- `lbvh_nodes`: the buffer (vector) containing the LBVH nodes (both the internal and leaf nodes)
- `sorted_morton_codes`: a sorted vector of the primitives morton codes
- `parent_information`: an out vector that will hold each nodes parent index (except root which won't be set) which is only used during the LBVH construction and this is why its seperate from the `lbvh_nodes` buffer
- `number_of_internal_nodes`: the number of internal nodes inside `lbvh_nodes`
"""
function BuildHierarchy(
    lbvh_nodes::Vector{LBVHNode{N}},
    sorted_morton_codes::Vector{MortonCodeT},
    parent_information::Vector{UInt32},
    number_of_internal_nodes::UInt32
) where {N, MortonCodeT<:AbstractMortonCodeType}
    for internal_node_index in 0:(number_of_internal_nodes - 1)
        range_start, range_end = DetermineRange(sorted_morton_codes, Int32(internal_node_index))
        range_split = FindSplit(sorted_morton_codes, range_start, range_end)

        left_child_index::UInt32 = range_split + ((range_split == range_start) ? number_of_internal_nodes : 0)
        right_child_index::UInt32 = range_split + 1 + (((range_split + 1) == range_end) ? number_of_internal_nodes : 0)

        lbvh_nodes[internal_node_index + 1] = LBVHNode{N}(left_child_index, right_child_index, INVALID_PRIMITIVE_INDEX, AABB2D(SVector(0.0f0, 0.0f0), SVector(0.0f0, 0.0f0)))

        parent_information[left_child_index + 1] = internal_node_index
        parent_information[right_child_index + 1] = internal_node_index
    end
end

"""
```julia
function CalculateBoundingBoxesBottomUp(
    lbvh_nodes::Vector{LBVHNode{N}},
    parent_information::Vector{UInt32},
    visitation_information::Vector{UInt32},
    number_of_internal_nodes::UInt32, 
    number_of_leafs::UInt32
) where {N}
```

From each leaf node it travels to its parent node and if it is the first one then it does nothing and finishes, if it is the second then it computes its parents AABB (Axis Aligned Bounding Box) by taking the union if the parents childrens AABBs and continues possibly up to the root

# Arguments
- `lbvh_nodes`: the buffer (vector) containing the LBVH nodes (both the internal and leaf nodes)
- `parent_information`: a vector that holds each nodes parent index (the roots value for obvious reasons won't be used)
- `visitation_information`: a vector that helps keep track how many child nodes have visited the current node at any given moment
- `number_of_internal_nodes`: the number of internal nodes inside `lbvh_nodes`
- `number_of_leafs`: the number of leaf nodes inside `lbvh_nodes`
"""
function CalculateBoundingBoxesBottomUp(
    lbvh_nodes::Vector{LBVHNode{N}},
    parent_information::Vector{UInt32},
    visitation_information::Vector{UInt32},
    number_of_internal_nodes::UInt32, 
    number_of_leafs::UInt32
) where {N}
    for i in 0:(number_of_leafs - 1)
        leaf_index::UInt32 = (number_of_internal_nodes + i)

        current_node_index::UInt32 = parent_information[leaf_index + 1]

        while (true)
            if (visitation_information[current_node_index + 1] == 0)
                visitation_information[current_node_index + 1] += 1
                break
            end

            current_node::LBVHNode{N} = lbvh_nodes[current_node_index + 1]
            left_child_node::LBVHNode{N} = lbvh_nodes[current_node.left_child_index + 1]
            right_child_node::LBVHNode{N} = lbvh_nodes[current_node.right_child_index + 1]

            current_node.aabb = AABBUnion(left_child_node.aabb, right_child_node.aabb)


            if (current_node_index == 0)
                break
            end

            current_node_index = parent_information[current_node_index + 1]
        end
    end
end
