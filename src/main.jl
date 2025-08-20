include("lbvh.jl")
include("line_segment.jl")
include("sphere.jl")
include("circle.jl")
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

circles = [
    Circle(SVector(1.0f0, 1.0f0), 0.1f0),
    Circle(SVector(2.0f0, 1.0f0), 0.1f0),
    Circle(SVector(3.0f0, 1.0f0), 0.1f0),
    Circle(SVector(4.0f0, 1.0f0), 0.1f0),
    Circle(SVector(1.0f0, 2.0f0), 0.1f0),
    Circle(SVector(2.0f0, 2.0f0), 0.1f0),
    Circle(SVector(3.0f0, 2.0f0), 0.1f0),
    Circle(SVector(4.0f0, 2.0f0), 0.1f0),
    Circle(SVector(1.0f0, 3.0f0), 0.1f0),
    Circle(SVector(2.0f0, 3.0f0), 0.1f0),
    Circle(SVector(3.0f0, 3.0f0), 0.1f0),
    Circle(SVector(4.0f0, 3.0f0), 0.1f0),
    Circle(SVector(1.0f0, 4.0f0), 0.1f0),
    Circle(SVector(2.0f0, 4.0f0), 0.1f0),
    Circle(SVector(3.0f0, 4.0f0), 0.1f0),
    Circle(SVector(4.0f0, 4.0f0), 0.1f0),

    Circle(SVector(1.1f0, 1.1f0), 0.1f0),
    Circle(SVector(2.1f0, 1.1f0), 0.1f0),
    Circle(SVector(3.1f0, 1.1f0), 0.1f0),
    Circle(SVector(4.1f0, 1.1f0), 0.1f0),
    Circle(SVector(1.1f0, 2.1f0), 0.1f0),
    Circle(SVector(2.1f0, 2.1f0), 0.1f0),
    Circle(SVector(3.1f0, 2.1f0), 0.1f0),
    Circle(SVector(4.1f0, 2.1f0), 0.1f0),
    Circle(SVector(1.1f0, 3.1f0), 0.1f0),
    Circle(SVector(2.1f0, 3.1f0), 0.1f0),
    Circle(SVector(3.1f0, 3.1f0), 0.1f0),
    Circle(SVector(4.1f0, 3.1f0), 0.1f0),
    Circle(SVector(1.1f0, 4.1f0), 0.1f0),
    Circle(SVector(2.1f0, 4.1f0), 0.1f0),
    Circle(SVector(3.1f0, 4.1f0), 0.1f0),
    Circle(SVector(4.1f0, 4.1f0), 0.1f0),
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
primitives = circles

println("start")

lbvh_nodes, number_of_leafs, number_of_internal_nodes = BuildLBVH(GetAABB.(primitives), UInt32)

function onIntersection(p1::SVector{2, Float32}, p2::SVector{2, Float32})
    println("Yay intersection", p1, p2)
end

function LineSegment2DToCircleIntersection(line_segment::LineSegment2D, circle::Circle)::Union{Bool, Tuple{Bool, SVector{2, Float32}, SVector{2, Float32}}}
    v::SVector{2, Float32} = line_segment.p2 .- line_segment.p1

    a = (v[1] * v[1] + v[2] * v[2])
    b = (2 * v[1] * v[2] * (line_segment.p1[1] + line_segment.p1[2] - circle.o[1] - circle.o[2]))
    c = (line_segment.p1[1] - circle.o[1])^2 + (line_segment.p1[2] - circle.o[2])^2 - circle.r * circle.r

    d = (b * b - 4 * a * c)

    if (d < 0)
        return false
    end

    t1 = (-b + sqrt(d))/(2 * a)
    t2 = (-b - sqrt(d))/(2 * a)

    return true, (line_segment.p1 .+ t1 .* v), (line_segment.p1 .+ t2 .* v)
end

for i in 0:(length(segments))
    LBVHToPrimitiveIntersection(
        lbvh_nodes,
        primitives,
        number_of_internal_nodes, 
        number_of_leafs,
        segments[i + 1],
        GetAABB(segments[i + 1]),
        LineSegment2DToCircleIntersection,
        onIntersection
    )
end


println("end")
