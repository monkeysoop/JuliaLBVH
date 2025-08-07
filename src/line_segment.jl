include("aabb.jl")
include("abstract_primitive.jl")

using StaticArrays



struct LineSegment2D <: AbstractPrimitive
    p1::SVector{2, Float32}
    p2::SVector{2, Float32}
end



function GetAABB(line_segment::LineSegment2D)::AABB2D
    return AABB2D(min.(line_segment.p1, line_segment.p2), max.(line_segment.p1, line_segment.p2))
end

function CrossProduct2D(a::SVector{2, Float32}, b::SVector{2, Float32})::Float32
    return ((a[1] * b[2]) - (a[2] * b[1]))
end

function Intersection(line_segment_a::LineSegment2D, line_segment_b::LineSegment2D)::Bool
    va::SVector{2, Float32} = line_segment_a.p2 .- line_segment_a.p1
    vb::SVector{2, Float32} = line_segment_b.p2 .- line_segment_b.p1

    vba::SVector{2, Float32} = line_segment_a.p1 .- line_segment_b.p1

    denom::Float32 = CrossProduct2D(va, vb)

    s::Float32 = CrossProduct2D(va, vba) / denom
    t::Float32 = CrossProduct2D(vb, vba) / denom

    #p::SVector{2, Float32} = a.p1 .+ t * va

    return (s >= 0.0 && s <= 1.0 && t >= 0.0 && t <= 1.0)
end
