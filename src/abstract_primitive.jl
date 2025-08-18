abstract type AbstractPrimitive end



function GetAABB(primitive::AbstractPrimitive)::AABB{N}
    @assert (false) "Error, AABB calculation for this type of primitive has not been implemented"
end

function Intersection(primitive_a::AbstractPrimitive, primitive_b::AbstractPrimitive)::Union{Bool, Tuple{Bool, Vararg{Any}}}
    @assert (false) "Error, intersection calculation for these types of primitives have not been implemented"
end
