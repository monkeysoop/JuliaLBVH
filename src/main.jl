include("aabb.jl")
include("hierarchy.jl")
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

sorted_morton_codes_with_primitive_indecies::Vector{PrimitiveIndexWithMortonCode{UInt32}} = GetSortedMortonCodesWithIndecies(CalculateMortonCodesLineSegment2D(segments))

number_of_leafs::UInt32 = UInt32(length(sorted_morton_codes_with_primitive_indecies))
number_of_internal_nodes::UInt32 = (number_of_leafs - 1)

lbvh_nodes::Vector{LBVHNode2D} = Vector{LBVHNode2D}(undef, (number_of_internal_nodes + number_of_leafs))
parent_information::Vector{UInt32} = Vector{UInt32}(undef, (number_of_internal_nodes + number_of_leafs))
visitation_information::Vector{UInt32} = Vector{UInt32}(undef, (number_of_internal_nodes + number_of_leafs))

for i in 0:(length(visitation_information) - 1)
    visitation_information[i + 1] = 0
end


primitive_aabbs = Vector{AABB2D}(GetAABBLineSegment2D.(segments))
sorted_morton_codes::Vector{UInt32} = getfield.(sorted_morton_codes_with_primitive_indecies, :morton_code)

InitLeafs(
    lbvh_nodes, 
    sorted_morton_codes_with_primitive_indecies, 
    primitive_aabbs, 
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

for i in 0:(number_of_leafs - 1)
    leaf_index::UInt32 = (number_of_internal_nodes + i)
    leaf_node::LBVHNode2D = lbvh_nodes[leaf_index + 1]
    
    stack::MVector{100, UInt32} = MVector{100, UInt32}(undef)
    stack_index::Int32 = 0

    current_node_index::UInt32 = 0
    current_node::LBVHNode2D = lbvh_nodes[current_node_index + 1]

    while (true)
        left_child_node::LBVHNode2D = lbvh_nodes[current_node.left_child_index + 1] # because of theinvalid index being 0 these might be the root
        right_child_node::LBVHNode2D = lbvh_nodes[current_node.right_child_index + 1] # because of theinvalid index being 0 these might be the root

        intersects_left_child::Bool = ((current_node.left_child_index != INVALID_LEAF_CHILD_POINTER) && AABB2AABBIntersection(leaf_node.aabb, left_child_node.aabb))
        intersects_right_child::Bool = ((current_node.right_child_index != INVALID_LEAF_CHILD_POINTER) && AABB2AABBIntersection(leaf_node.aabb, right_child_node.aabb))
        
        if (intersects_left_child)
            if (intersects_right_child)
                if (stack_index < length(stack))
                    stack[stack_index + 1] = current_node.right_child_index
                else
                    println("dropped node")
                end
            end

            current_node_index = current_node.left_child_index
            current_node = left_child_node
        elseif (intersects_right_child)
            current_node_index = current_node.right_child_index
            current_node = right_child_node
        else
            if (Segment2SegmentIntersection2D(segments[current_node.primitive_index + 1], segments[leaf_node.primitive_index + 1]))
                println("intersection, leaf: ", leaf_node.primitive_index, " current: ", current_node.primitive_index)
            end

            if (stack_index == -1)
                break
            end

            current_node_index = stack[stack_index + 1]
            current_node = lbvh_nodes[current_node_index + 1]
            stack_index -= 1
        end
    end
end

println("end")
