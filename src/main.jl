include("intersections.jl")
include("lbvh.jl")
include("line_segment.jl")
include("morton_codes.jl")

using StaticArrays



segments = [
    LineSegment2D(SVector(1.0f0, 1.0f0), SVector(1.1f0, 1.1f0)),
    LineSegment2D(SVector(2.0f0, 1.0f0), SVector(2.1f0, 1.1f0)),
    LineSegment2D(SVector(3.0f0, 1.0f0), SVector(3.1f0, 1.1f0)),
    LineSegment2D(SVector(4.0f0, 1.0f0), SVector(4.1f0, 1.1f0)),
    LineSegment2D(SVector(1.0f0, 2.0f0), SVector(1.1f0, 2.1f0)),
    LineSegment2D(SVector(2.0f0, 2.0f0), SVector(2.1f0, 2.1f0)),
    LineSegment2D(SVector(3.0f0, 2.0f0), SVector(3.1f0, 2.1f0)),
    LineSegment2D(SVector(4.0f0, 2.0f0), SVector(4.1f0, 2.1f0)),
    LineSegment2D(SVector(1.0f0, 3.0f0), SVector(1.1f0, 3.1f0)),
    LineSegment2D(SVector(2.0f0, 3.0f0), SVector(2.1f0, 3.1f0)),
    LineSegment2D(SVector(3.0f0, 3.0f0), SVector(3.1f0, 3.1f0)),
    LineSegment2D(SVector(4.0f0, 3.0f0), SVector(4.1f0, 3.1f0)),
    LineSegment2D(SVector(1.0f0, 4.0f0), SVector(1.1f0, 4.1f0)),
    LineSegment2D(SVector(2.0f0, 4.0f0), SVector(2.1f0, 4.1f0)),
    LineSegment2D(SVector(3.0f0, 4.0f0), SVector(3.1f0, 4.1f0)),
    LineSegment2D(SVector(4.0f0, 4.0f0), SVector(4.1f0, 4.1f0)),

    LineSegment2D(SVector(1.1f0, 1.0f0), SVector(1.0f0, 1.1f0)),
    LineSegment2D(SVector(2.1f0, 1.0f0), SVector(2.0f0, 1.1f0)),
    LineSegment2D(SVector(3.1f0, 1.0f0), SVector(3.0f0, 1.1f0)),
    LineSegment2D(SVector(4.1f0, 1.0f0), SVector(4.0f0, 1.1f0)),
    LineSegment2D(SVector(1.1f0, 2.0f0), SVector(1.0f0, 2.1f0)),
    LineSegment2D(SVector(2.1f0, 2.0f0), SVector(2.0f0, 2.1f0)),
    LineSegment2D(SVector(3.1f0, 2.0f0), SVector(3.0f0, 2.1f0)),
    LineSegment2D(SVector(4.1f0, 2.0f0), SVector(4.0f0, 2.1f0)),
    LineSegment2D(SVector(1.1f0, 3.0f0), SVector(1.0f0, 3.1f0)),
    LineSegment2D(SVector(2.1f0, 3.0f0), SVector(2.0f0, 3.1f0)),
    LineSegment2D(SVector(3.1f0, 3.0f0), SVector(3.0f0, 3.1f0)),
    LineSegment2D(SVector(4.1f0, 3.0f0), SVector(4.0f0, 3.1f0)),
    LineSegment2D(SVector(1.1f0, 4.0f0), SVector(1.0f0, 4.1f0)),
    LineSegment2D(SVector(2.1f0, 4.0f0), SVector(2.0f0, 4.1f0)),
    LineSegment2D(SVector(3.1f0, 4.0f0), SVector(3.0f0, 4.1f0)),
    LineSegment2D(SVector(4.1f0, 4.0f0), SVector(4.0f0, 4.1f0)),
]

@assert (length(segments) > 0) "error, no primitives provided"

println("start")

sorted_morton_codes_with_primitive_indecies::Vector{PrimitiveIndexWithMortonCode{UInt32}} = GetSortedMortonCodesWithIndecies(CalculateMortonCodesForPrimitiveAABBs32(GetAABB.(segments)))

number_of_leafs::UInt32 = UInt32(length(sorted_morton_codes_with_primitive_indecies))
number_of_internal_nodes::UInt32 = (number_of_leafs - 1)

lbvh_nodes::Vector{LBVHNode2D} = Vector{LBVHNode2D}(undef, (number_of_internal_nodes + number_of_leafs))
parent_information::Vector{UInt32} = Vector{UInt32}(undef, (number_of_internal_nodes + number_of_leafs))
visitation_information::Vector{UInt32} = Vector{UInt32}(undef, number_of_internal_nodes)

for i in 0:(length(visitation_information) - 1)
    visitation_information[i + 1] = 0
end

primitive_indecies::Vector{UInt32} = getfield.(sorted_morton_codes_with_primitive_indecies, :primitive_index)
sorted_morton_codes::Vector{UInt32} = getfield.(sorted_morton_codes_with_primitive_indecies, :morton_code)

InitLeafs(
    lbvh_nodes, 
    primitive_indecies, 
    segments, 
    number_of_internal_nodes, 
    number_of_leafs
)
BuildHierarchy(
    lbvh_nodes, 
    sorted_morton_codes, 
    parent_information, 
    number_of_internal_nodes
)
CalculateBoundingBoxesBottomUp(
    lbvh_nodes, 
    parent_information, 
    visitation_information, 
    number_of_internal_nodes, 
    number_of_leafs
)

FindIntersections(
    lbvh_nodes,
    segments,
    number_of_internal_nodes, 
    number_of_leafs
)

println("end")
