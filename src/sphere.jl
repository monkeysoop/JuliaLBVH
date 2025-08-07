include("aabb.jl")
include("abstract_primitive.jl")

using StaticArrays
using LinearAlgebra



struct Sphere <: AbstractPrimitive
    o::SVector{3, Float32}
    r::Float32
end



function GetAABB(sphere::Sphere)::AABB3D
    return AABB3D((sphere.o .- sphere.r), (sphere.o .+ sphere.r))
end

function Intersection(sphere_a::Sphere, sphere_b::Sphere)::Bool
    diff::SVector{3, Float32} = sphere_b.o .- sphere_a.o
    return (dot(diff, diff) <= (sphere_a.r + sphere_b.r)^2)
end
