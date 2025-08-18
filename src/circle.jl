include("aabb.jl")
include("abstract_primitive.jl")

using StaticArrays
using LinearAlgebra



struct Circle <: AbstractPrimitive
    o::SVector{2, Float32}
    r::Float32
end



function GetAABB(circle::Circle)::AABB2D
    return AABB2D((circle.o .- circle.r), (circle.o .+ circle.r))
end

function Intersection(circle_a::Circle, circle_b::Circle)::Union{Bool, Tuple{Bool, SVector{2, Float32}, SVector{2, Float32}}}
    diff::SVector{2, Float32} = circle_b.o .- circle_a.o

    dd::Float32 = dot(diff, diff)
    do_intersect::Bool = ((dd <= (circle_a.r + circle_b.r)^2) && (dd >= abs(circle_a.r - circle_b.r)^2) && dd > 0)
    if (do_intersect)
        d::Float32 = sqrt(dd)
        a::Float32 = (circle_a.r * circle_a.r - circle_b.r * circle_b.r + dd) / (2 * d)
        h::Float32 = sqrt(circle_a.r * circle_a.r - a * a)
        x2::Float32 = circle_a.o[1] + a * (circle_b.o[1] - circle_a.o[1]) / d
        y2::Float32 = circle_a.o[2] + a * (circle_b.o[2] - circle_a.o[2]) / d
        x3::Float32 = x2 + h * (circle_b.o[2] - circle_a.o[2]) / d
        y3::Float32 = y2 - h * (circle_b.o[1] - circle_a.o[1]) / d
        x4::Float32 = x2 - h * (circle_b.o[2] - circle_a.o[2]) / d
        y4::Float32 = y2 + h * (circle_b.o[1] - circle_a.o[1]) / d
        return true, SVector{2, Float32}(x3, y3), SVector{2, Float32}(x4, y4)
    else
        return false
    end
end
