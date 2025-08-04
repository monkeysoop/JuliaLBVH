include("aabb.jl")
include("morton_codes.jl")



const INVALID_LEAF_CHILD_POINTER::UInt32 = 0
const INVALID_PRIMITIVE_INDEX::UInt32 = 0

mutable struct LBVHNode{N}
    left_child_index::UInt32
    right_child_index::UInt32
    primitive_index::UInt32 # only for leafs
    aabb::AABB{N}
end

const LBVHNode2D = LBVHNode{2}
const LBVHNode3D = LBVHNode{3}

struct PrimitiveIndexWithMortonCode{MortonCodeT<:AbstractMortonCodeType}
    primitive_index::UInt32
    morton_code::MortonCodeT
end




"""
```julia
function GetSortedMortonCodesWithIndecies(morton_codes::Vector{MortonCodeT})::Vector{PrimitiveIndexWithMortonCode{MortonCodeT}} where {MortonCodeT<:AbstractMortonCodeType}
```

Takes a vector of unsorted morton codes, creates pairs out of the morton codes and their indecies (0 based) and sorts them by the morton codes

# Arguments
- `morton_codes`: an unsorted vector of the primitives morton codes

# Returns
- `Vector{PrimitiveIndexWithMortonCode{MortonCodeT}}`: a sorted (by the morton codes) vector of pairs each having a morton code with their original indecies in the `morton_codes` buffer

# Examples
```julia
GetSortedMortonCodesWithIndecies(Vector{UInt32}([0, 9, 2, 8, 3, 7, 4, 6, 5])) # => PrimitiveIndexWithMortonCode{UInt32}[PrimitiveIndexWithMortonCode{UInt32}(0, 0), PrimitiveIndexWithMortonCode{UInt32}(2, 2), PrimitiveIndexWithMortonCode{UInt32}(4, 3), PrimitiveIndexWithMortonCode{UInt32}(6, 4), PrimitiveIndexWithMortonCode{UInt32}(8, 5), PrimitiveIndexWithMortonCode{UInt32}(7, 6), PrimitiveIndexWithMortonCode{UInt32}(5, 7), PrimitiveIndexWithMortonCode{UInt32}(3, 8), PrimitiveIndexWithMortonCode{UInt32}(1, 9)]
```
"""
function GetSortedMortonCodesWithIndecies(morton_codes::Vector{MortonCodeT})::Vector{PrimitiveIndexWithMortonCode{MortonCodeT}} where {MortonCodeT<:AbstractMortonCodeType}
    indecies_with_codes::Vector{PrimitiveIndexWithMortonCode{MortonCodeT}} = [PrimitiveIndexWithMortonCode(UInt32(index - 1), morton_code) for (index, morton_code) in enumerate(morton_codes)]
    return sort(indecies_with_codes, by = x -> x.morton_code)
end
