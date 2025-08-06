include("aabb.jl")
include("abstract_primitive.jl")
include("lbvh.jl")



function FindIntersections(
    lbvh_nodes::Vector{LBVHNode{N}},
    primitives::Vector{PrimitiveT},
    number_of_internal_nodes::UInt32,
    number_of_leafs::UInt32
) where {N, PrimitiveT <: AbstractPrimitive}
    @assert (number_of_leafs > 0) "Error, can't construct any empty lbvh"
    @assert ((number_of_internal_nodes + 1) == number_of_leafs) "Error, number of internal nodes is incorrect"
    @assert (length(lbvh_nodes) == (number_of_internal_nodes + number_of_leafs)) "Error, invalid lbvh buffer provided"
    @assert (length(primitives) == number_of_leafs) "Error, invalid primitives buffer provided"
    for i in 0:(number_of_leafs - 1)
        leaf_index::UInt32 = (number_of_internal_nodes + i)
        leaf_node::LBVHNode{N} = lbvh_nodes[leaf_index + 1]

        stack::MVector{100, UInt32} = MVector{100, UInt32}(undef)
        stack_size::Int32 = 0

        current_node_index::UInt32 = 0
        current_node::LBVHNode{N} = lbvh_nodes[current_node_index + 1]

        while (true)
            is_node_internal::Bool = (current_node.left_child_index != INVALID_CHILD_POINTER)

            intersect_left_child::Bool = (is_node_internal && AABB2AABBIntersection(leaf_node.aabb, lbvh_nodes[current_node.left_child_index + 1].aabb))
            intersect_right_child::Bool = (is_node_internal && AABB2AABBIntersection(leaf_node.aabb, lbvh_nodes[current_node.right_child_index_or_primitive_index + 1].aabb))

            if (intersect_left_child)
                if (intersect_right_child)
                    if (stack_size < length(stack))
                        stack[stack_size + 1] = current_node.right_child_index_or_primitive_index
                        stack_size += 1
                    else
                        println("Warning, dropped node because stack is too small")
                    end
                end
                current_node_index = current_node.left_child_index
                current_node = lbvh_nodes[current_node.left_child_index + 1]
            elseif (intersect_right_child)
                current_node_index = current_node.right_child_index_or_primitive_index
                current_node = lbvh_nodes[current_node.right_child_index_or_primitive_index + 1]
            else
                if (Intersection(primitives[current_node.right_child_index_or_primitive_index + 1], primitives[leaf_node.right_child_index_or_primitive_index + 1]))
                    println("Intersection between, leaf: ", leaf_node.right_child_index_or_primitive_index, " current: ", current_node.right_child_index_or_primitive_index)
                end

                if (stack_size == 0)
                    break
                end

                current_node_index = stack[(stack_size - 1) + 1]
                stack_size -= 1

                current_node = lbvh_nodes[current_node_index + 1]
            end
        end
    end
end
