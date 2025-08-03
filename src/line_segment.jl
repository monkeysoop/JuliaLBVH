include("aabb.jl")
include("morton_codes.jl")

using StaticArrays



struct LineSegment2D
    p1::SVector{2, Float32}
    p2::SVector{2, Float32}
end



function GetAABBLineSegment2D(segment::LineSegment2D)::AABB2D
    return AABB2D(min.(segment.p1, segment.p2), max.(segment.p1, segment.p2))
end

function MortonCodeLineSegment2D32(segment_aabb::AABB2D, container_aabb::AABB2D)::UInt32
    scaled_center::SVector{2, Float32} = GetScaledAABBCenter(segment_aabb, container_aabb)
    return MortonCode2D32(UInt16(round(65535.0 * scaled_center[1])), UInt16(round(65535.0 * scaled_center[2])))
end

function CalculateMortonCodesLineSegment2D(segment::Vector{LineSegment2D})::Vector{UInt32}
    segment_aabbs::Vector{AABB2D} = GetAABBLineSegment2D.(segment)
    container_aabb::AABB2D = GetContainerAABB(segment_aabbs)
    return MortonCodeLineSegment2D32.(segment_aabbs, Ref(container_aabb))
end

function CrossProduct2D(a::SVector{2, Float32}, b::SVector{2, Float32})::Float32
    return ((a[1] * b[2]) - (a[2] * b[1]))
end

function Segment2SegmentIntersection2D(a::LineSegment2D, b::LineSegment2D)::Bool
    va::SVector{2, Float32} = a.p2 .- a.p1
    vb::SVector{2, Float32} = b.p2 .- b.p1

    vba::SVector{2, Float32} = a.p1 .- b.p1

    denom::Float32 = CrossProduct2D(va, vb)

    s::Float32 = (va[1] * vba[2] - va[1] * vba[1]) / denom
    t::Float32 = (vb[2] * vba[2] - vb[2] * vba[1]) / denom

    #p::SVector{2, Float32} = a.p1 .+ t * va

    return (s >= 0.0 && s <= 1.0 && t >= 0.0 && t <= 1.0)
end
