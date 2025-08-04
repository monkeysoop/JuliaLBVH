include("aabb.jl")
include("abstract_primitive.jl")
include("lbvh.jl")



function FindIntersections(
    lbvh_nodes::Vector{LBVHNode{N}},
    primitives::Vector{PrimitiveT},
    number_of_internal_nodes::UInt32,
    number_of_leafs::UInt32
) where {N, PrimitiveT <: AbstractPrimitive}
    for i in 0:(number_of_leafs - 1)
        leaf_index::UInt32 = (number_of_internal_nodes + i)
        leaf_node::LBVHNode{N} = lbvh_nodes[leaf_index + 1]

        stack::MVector{100, UInt32} = MVector{100, UInt32}(undef)
        stack_index::Int32 = 0

        current_node_index::UInt32 = 0
        current_node::LBVHNode{N} = lbvh_nodes[current_node_index + 1]

        while (true)
            left_child_node::LBVHNode{N} = lbvh_nodes[current_node.left_child_index + 1] # because of the invalid index being 0 these might be the root, so this will work
            right_child_node::LBVHNode{N} = lbvh_nodes[current_node.right_child_index + 1] # because of the invalid index being 0 these might be the root, so this will work

            intersects_left_child::Bool = ((current_node.left_child_index != INVALID_LEAF_CHILD_POINTER) && AABB2AABBIntersection(leaf_node.aabb, left_child_node.aabb))
            intersects_right_child::Bool = ((current_node.right_child_index != INVALID_LEAF_CHILD_POINTER) && AABB2AABBIntersection(leaf_node.aabb, right_child_node.aabb))
            
            if (intersects_left_child)
                if (intersects_right_child)
                    if (stack_index < length(stack))
                        stack[stack_index + 1] = current_node.right_child_index
                    else
                        println("Warning, dropped node because stack is too small")
                    end
                end

                current_node_index = current_node.left_child_index
                current_node = left_child_node
            elseif (intersects_right_child)
                current_node_index = current_node.right_child_index
                current_node = right_child_node
            else
                if (Intersection(primitives[current_node.primitive_index + 1], primitives[leaf_node.primitive_index + 1]))
                    println("Intersection between, leaf: ", leaf_node.primitive_index, " current: ", current_node.primitive_index)
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
end
