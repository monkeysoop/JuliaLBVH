using StaticArrays



struct AABB{N}
    min::SVector{N, Float32}
    max::SVector{N, Float32}
end

const AABB2D = AABB{2}
const AABB3D = AABB{3}



"""
    function AABBUnion(aabb_1::AABB{N}, aabb_2::AABB{N})::AABB{N} where {N}

Returns the union of 2 given AABB (Axis Aligned Bounding Box) basically the min of the mins and the max of the maxs.

# Arguments
- `aabb_1`: the first AABB
- `aabb_2`: the second AABB

# Returns
- `AABB{N}`: the union of the 2 arguments

# Examples
```julia
```
"""
function AABBUnion(aabb_1::AABB{N}, aabb_2::AABB{N})::AABB{N} where {N}
    return AABB{N}(min.(aabb_1.min, aabb_2.min), max.(aabb_1.max, aabb_2.max))
end

"""
    function GetScaledAABBCenter(aabb::AABB{N}, container_aabb::AABB{N})::SVector{N, Float32} where {N}

Computes the center of an AABB (Axis Aligned Bounding Box) and scales it by a containing AABB, thus if the center of the AABB lies inside the containing AABB than the returned vector will have values between 0.0 and 1.0 (both inclusive [0.0, 1.0])

# Arguments
- `aabb`: the AABB of which this function is taking the center and scaling
- `container_aabb`: the AABB which hopefully contains the `aabb`

# Returns
- `SVector{N, Float32}`: the scaled vector where each value is the scaled (by the size of the `container_aabb` alongst the corresponding axis) and offset (by the corresponding min of `container_aabb`) value of the `aabb`'s center

# Examples
```julia
```

# Notes
- if the `aabb` isn't a point and the `container_aabb` is computed as the min of mins and max of maxes than this might be a tiny bit wasteful  

"""
function GetScaledAABBCenter(aabb::AABB{N}, container_aabb::AABB{N})::SVector{N, Float32} where {N}
    return ((aabb.min .+ 0.5 .* (aabb.max .- aabb.min) .- container_aabb.min) ./ (container_aabb.max .- container_aabb.min))
end

"""
    function GetContainerAABB(aabbs::Vector{AABB{N}})::AABB{N} where {N}

Calculates a bounding AABB (Axis Aligned Bounding Box) around a vector of AABBs (basically takes the min of mins and max of maxes)

# Arguments
- `aabbs`: the vector of AABBs 

# Returns
- `AABB{N}`: an AABB which contains all of the `aabbs` (inclusive)

# Examples
```julia
```
"""
function GetContainerAABB(aabbs::Vector{AABB{N}})::AABB{N} where {N}
    return AABB{N}(reduce((a, b) -> min.(a, b), getfield.(aabbs, :min)), reduce((a, b) -> max.(a, b), getfield.(aabbs, :max)))
end

"""
    function AABB2AABBIntersection(aabb_1::AABB{N}, aabb_2::AABB{N})::Bool where {N}

This function decides if 2 AABB (Axis Aligned Bounding Box) intersect

# Arguments
- `aabb_1`: the first AABB (order doesn't matter)
- `aabb_2`: the second AABB

# Returns
- `Bool`: true if `aabb_1` and `aabb_2` intersect otherwise false (if only their edges or their corners touch or one is fully inside the other it is still considered an intersection same when they are 2 points with the same coordinates)

# Examples
```julia
```
"""
function AABB2AABBIntersection(aabb_1::AABB{N}, aabb_2::AABB{N})::Bool where {N}
    overlaps = (aabb_2.min .<= aabb_1.max) .& (aabb_1.min .<= aabb_2.max)
    return all(overlaps)
end
