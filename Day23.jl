include("./AoC.jl")
using .AoC: getDayInputLines, getInts

const Point = Tuple{Int, Int}
const Vertices = Vector{Point}
const EdgeList = Dict{Point, Vertices}
const Edge = Tuple{Point, Point}
const DistanceMap = Dict{Edge, Int}

function isNeighbour(point1::Point, point2::Point)
    dx = abs(point1[1] - point2[1])
    dy = abs(point1[2] - point2[2])
    (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
end

Base.delete!(vertices::Vertices, vertex::Point) = deleteat!(vertices, findall(v -> v == vertex, vertices))

function reachableFrom(point::Point, edgeList::EdgeList)
    targets = []
    for vertex in keys(edgeList)
        for target in edgeList[vertex]
            if target == point
                push!(targets, vertex)
                break
            end
        end
    end
    targets
end

function printEdges(edges::EdgeList)
    vertices = collect(keys(edges))
    sort!(vertices)
    for vertex in vertices
        println(vertex, " -> ", edges[vertex])
    end
end

function pushDirectedEdge!(edges::EdgeList, from::Point, to::Point)
    if !haskey(edges, from)
        edges[from] = []
    end
    push!(edges[from], to)
end

function pushUndirectedEdge!(edges::EdgeList, from::Point, to::Point)
    pushDirectedEdge!(edges, from, to)
    pushDirectedEdge!(edges, to, from)
end

function buildGraph(lines, isPart2)
    isInBounds(x, y) = x > 1 && y > 1 && y <= length(lines) && x <= length(first(lines))
    isValidTarget(x, y) = isInBounds(x, y) && lines[y][x] != '#'

    start = (2, 1)
    finish = (length(first(lines)), length(lines))
    edges::EdgeList = Dict()

    for (y, line) in enumerate(lines)
        for (x, cell) in enumerate(line)
            if cell == '.' || (isPart2 && cell in ['<', '>', '^', 'v'])
                if isValidTarget(x-1, y)
                    pushDirectedEdge!(edges, (x, y), (x-1, y))
                end
                if isValidTarget(x+1, y)
                    pushDirectedEdge!(edges, (x, y), (x+1, y))
                end
                if isValidTarget(x, y-1)
                    pushDirectedEdge!(edges, (x, y), (x, y-1))
                end
                if isValidTarget(x, y+1)
                    pushDirectedEdge!(edges, (x, y), (x, y+1))
                end
            elseif cell == '<'
                if isValidTarget(x-1, y)
                    pushDirectedEdge!(edges, (x, y), (x-1, y))
                end
            elseif cell == '>'
                if isValidTarget(x+1, y)
                    pushDirectedEdge!(edges, (x, y), (x+1, y))
                end
            elseif cell == '^'
                if isValidTarget(x, y-1)
                    pushDirectedEdge!(edges, (x, y), (x, y-1))
                end
            elseif cell == 'v'
                if isValidTarget(x, y+1)
                    pushDirectedEdge!(edges, (x, y), (x, y+1))
                end
            end
        end
    end
    (edges, start, finish)
end

function reduceGraph!(edgeList::EdgeList)
    removableVertices = []
    distances = Dict()

    for vertex in keys(edgeList)
        edges = edgeList[vertex]
        if length(edges) == 2
            reachable = reachableFrom(vertex, edgeList)
            if length(reachable) == 2
                push!(removableVertices, vertex)
            end
        end
        for e in edges
            distances[(vertex, e)] = 1
        end
    end
    for vertex in removableVertices
        (p1, p2) = edgeList[vertex]
        delete!(edgeList[p1], vertex)
        delete!(edgeList[p2], vertex)
        push!(edgeList[p1], p2)
        push!(edgeList[p2], p1)
        delete!(edgeList, vertex)
        distances[(p1, p2)] = distances[(p1, vertex)] + distances[(vertex, p2)]
        delete!(distances, (p1, vertex))
        delete!(distances, (vertex, p2))
        distances[(p2, p1)] = distances[(p2, vertex)] + distances[(vertex, p1)]
        delete!(distances, (p2, vertex))
        delete!(distances, (vertex, p1))
    end
    distances
end

function printReducedGraph(edgeList::EdgeList, lines)
    for (y, line) in enumerate(lines)
        for (x, cell) in enumerate(line)
            if cell == '#'
                print('#')
            elseif haskey(edgeList, (x, y))
                print(cell)
            else
                print(' ')
            end
        end
        println()
    end
end

function longestPath(edgeList::EdgeList, from::Point, to::Point, distances::DistanceMap, visited::Set{Point})
    if from == to
        return 0
    end
    targets = edgeList[from]
    distance = 0
    visitedPlusFrom = deepcopy(visited)
    push!(visitedPlusFrom, from)
    for target in targets
        if target in visited
            continue
        end
        distance = max(distance, longestPath(edgeList, target, to, distances, visitedPlusFrom) + distances[(from, target)])
    end
    distance 
end

function longestPath(edgeList::EdgeList, from::Point, to::Point, distances::DistanceMap)
    visited::Set{Point} = Set()
    longestPath(edgeList, from, to, distances, visited)
end

function part1(lines)
    (graph, start, finish) = buildGraph(lines, false)
    distances::DistanceMap = reduceGraph!(graph)
    println("Part 1: ", longestPath(graph, start, finish, distances))
end

function part2(lines)
    (graph, start, finish) = buildGraph(lines, true)
    distances::DistanceMap = reduceGraph!(graph)
    println("Part 2: ", longestPath(graph, start, finish, distances))
end

function main()
    lines = getDayInputLines(23)
    part1(lines)
    part2(lines)
end

main()
