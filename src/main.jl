include("intersections.jl")
include("lbvh.jl")
include("line_segment.jl")
include("sphere.jl")
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

spheres = [
    Sphere(SVector(1.0f0, 1.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.0f0, 1.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.0f0, 1.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.0f0, 1.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.0f0, 2.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.0f0, 2.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.0f0, 2.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.0f0, 2.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.0f0, 3.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.0f0, 3.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.0f0, 3.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.0f0, 3.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.0f0, 4.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.0f0, 4.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.0f0, 4.0f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.0f0, 4.0f0, 1.0f0), 0.1f0),

    Sphere(SVector(1.1f0, 1.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.1f0, 1.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.1f0, 1.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.1f0, 1.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.1f0, 2.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.1f0, 2.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.1f0, 2.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.1f0, 2.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.1f0, 3.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.1f0, 3.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.1f0, 3.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.1f0, 3.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(1.1f0, 4.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(2.1f0, 4.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(3.1f0, 4.1f0, 1.0f0), 0.1f0),
    Sphere(SVector(4.1f0, 4.1f0, 1.0f0), 0.1f0),
]

#primitives = segments
primitives = spheres

println("start")

lbvh_nodes, number_of_leafs, number_of_internal_nodes = BuildLBVH(GetAABB.(primitives), UInt32)

function onIntersection()
    println("Yay intersection")
end

FindIntersections(
    lbvh_nodes,
    primitives,
    number_of_internal_nodes, 
    number_of_leafs,
    onIntersection
)

println("end")
