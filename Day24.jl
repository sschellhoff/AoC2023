include("./AoC.jl")
using .AoC: getDayInputLines, getInts

const IoF = Union{Int64, Float64, BigFloat}
const Point2d = Tuple{IoF, IoF}
const Line2d = Tuple{Point2d, Point2d}

function add(p1::Point2d, p2::Point2d)
    (x1, y1) = p1
    (x2, y2) = p2
    (x1+x2, y1+y2)
end

function sub(p1::Point2d, p2::Point2d)
    (x1, y1) = p1
    (x2, y2) = p2
    (x1-x2, y1-y2)
end

function signP(p::Point2d)
    (x, y) = p
    (sign(x), sign(y))
end

isInfinite(p::Point2d) = p[1] == Inf || p[1] == -Inf
isNaN(p::Point2d) = isnan(p[1]) || isnan(p[2])

function intersect(a::Line2d, b::Line2d)
    (p1, p2) = a
    (p3, p4) = b
    (x1, y1) = p1
    (x2, y2) = p2
    (x3, y3) = p3
    (x4, y4) = p4
    tx = BigInt(x1*y2 - y1*x2) * BigInt(x3-x4) - BigInt(x1-x2) * BigInt(x3*y4 - y3*x4)
    ty = BigInt(x1*y2 - y1*x2) * BigInt(y3-y4) - BigInt(y1-y2) * BigInt(x3*y4 - y3*x4)
    b = BigInt(x1-x2)*BigInt(y3-y4) - BigInt(y1-y2) * BigInt(x3-x4)
    x = float(tx//b)
    y = float(ty//b)
    (x, y)
end

function intersectBetween(l1::Line2d, l2::Line2d, minValue::Int, maxValue::Int)
    (px, py) = intersect(l1, l2)
end

function willIntersectBetween(l1::Line2d, l2::Line2d, minValue::Int, maxValue::Int)
    i = intersect(l1, l2)
    #println(i)
    (px, py) = i
    #println(i)
    if isNaN(i)
        #println("NaN")
        return false
    end
    isBetween = px >= minValue && px <= maxValue && py >= minValue && py <= maxValue
    #println(isBetween)
    (s1, e1) = l1
    (s2, e2) = l2
    isBetween && signP(sub(e1, s1)) == signP(sub(i, s1)) && signP(sub(e2, s2)) == signP(sub(i, s2))
end

function parseLine2d(line)::Line2d
    (x, y, z, dx, dy, dz) = getInts(line)
    p = (x, y)
    d = (dx, dy)
    (p, add(p, d))
end

function main()
    lines = map(parseLine2d, getDayInputLines(24))
    minValue = 200000000000000
    maxValue = 400000000000000
    s = 0
    for a in eachindex(lines)
        for b in (a+1):length(lines)
            if willIntersectBetween(lines[a], lines[b], minValue, maxValue)
                s+=1
            end
        end
    end
    println(s)
end

main()
