include("./AoC.jl")
using .AoC: getDayInputLines
using Plots

@enum Direction North South East West

const Point = Tuple{Int, Int}

function goNorth(point::Point)::Point
    (x, y) = point
    (x, y-1)
end

function goSouth(point::Point)::Point
    (x, y) = point
    (x, y+1)
end

function goEast(point::Point)::Point
    (x, y) = point
    (x+1, y)
end

function goWest(point::Point)::Point
    (x, y) = point
    (x-1, y)
end

function goTo(point::Point, direction::Direction)::Point
    if direction == North
        goNorth(point)
    elseif direction == South
        goSouth(point)
    elseif direction == East
        goEast(point)
    elseif direction == West
        goWest(point)
    else
        throw("Unknown direction '$(directino)'")
    end
end

goInAllDirections(point::Point)::Vector{Point} = collect(map(direction -> goTo(point, direction), instances(Direction)))


struct Grid
    collisions::Set{Point}
    width::Int
    height::Int
end

function isInGrid(point::Point, grid::Grid)::Bool
    (x, y) = point
    x >= 1 && x <= grid.width && y >= 1 && y <= grid.height
end

function isFree(point::Point, grid::Grid, infinityGrid::Bool)::Bool
    if infinityGrid
        (x, y) = point
        x = mod((x-1), grid.width) + 1
        y = mod((y-1), grid.height) + 1
        return isFree((x, y), grid, false)
    end
    isInGrid(point, grid) && point ∉ grid.collisions
end

doStep(point::Point, grid::Grid, infinityGrid::Bool)::Vector{Point} = filter(newPoint -> isFree(newPoint, grid, infinityGrid), goInAllDirections(point))

doTwoSteps(point::Point, grid::Grid, infinityGrid::Bool)::Set{Point} = Set(Iterators.flatten(map(p -> doStep(p, grid, infinityGrid), doStep(point, grid, infinityGrid))))

function doTwoSteps(points::Set{Point}, grid::Grid, infinityGrid::Bool)::Set{Point}
    result = Set()
    for point in points
        union!(result, doTwoSteps(point, grid, infinityGrid))
    end
    result
end

function parseGrid(lines)::Tuple{Grid, Point}
    collisions = Set()
    height = length(lines)
    width = length(first(lines))
    start = nothing
    for (y, line) in enumerate(lines)
        for (x, tile) in enumerate(line)
            if tile == '#'
                push!(collisions, (x, y))
            elseif tile == 'S'
                start = (x, y)
            end
        end
    end
    if isnothing(start)
        throw("start not found")
    end
    (Grid(collisions, width, height), start)
end

function goSteps(start::Point, grid::Grid, numberOfSteps::Int, infinityGrid::Bool)::Set{Point}
    (seenPoints, openList) = if numberOfSteps % 2 != 0
        numberOfSteps -= 1
        (Set(doStep(start, grid, infinityGrid)), Set(doStep(start, grid, infinityGrid)))
    else
        Set([start]), Set([start])
    end
    #seenPoints = Set([start])
    #openList = Set([start])

    while numberOfSteps > 0
        # mark openlist as seen
        union!(seenPoints, openList)

        # get new points
        openList = setdiff(doTwoSteps(openList, grid, infinityGrid), seenPoints)
        numberOfSteps -= 2
    end
    union!(seenPoints, openList)
    seenPoints
end

function printSolution(points::Set{Point}, grid::Grid, infinityGrid)
    (x0, x1, y0, y1) = if infinityGrid
        ps = collect(points)
        (minimum(map(p -> p[1], ps)), maximum(map(p -> p[1], ps)), minimum(map(p -> p[2], ps)), maximum(map(p -> p[2], ps)))
    else
        (1, grid.width, 1, grid.height)
    end

    println(x0, x1, y0, y1)
    for y in y0:y1
        for x in x0:x1
            if !isFree((x, y), grid, infinityGrid)
                print('#')
            elseif (x, y) in points
                print('O')
            else
                print('.')
            end
        end
        println()
    end
end

function plotGraph(start, grid)
    function getY(x)
        if x == 1
            length(doStep(start, grid, true))
        else
            length(goSteps(start, grid, x, true))
        end
    end
    x = 1:50
    y = getY.(x)
    savefig(plot(x, y), "plot.png")
    for (_x, _y) in zip(x, y)
        println(_x, " ", _y)
    end
end

function part2(start::Point, grid::Grid, numberOfSteps::Int)
    completeRuns = trunc(Int, numberOfSteps / grid.height)
    remainder = numberOfSteps % grid.height
    println(completeRuns, " ", remainder)
    c = length(goSteps(start, grid, remainder, true))
    a_b_c = length(goSteps(start, grid, grid.height + remainder, true))
    _4a_2b_c = length(goSteps(start, grid, 2 * grid.height + remainder, true))

    a_b = a_b_c - c
    a = trunc(Int, (_4a_2b_c - 2 * a_b - c) / 2)
    b = a_b - a
    println(a, " ", b, " ", c)

    println(a * (completeRuns ^ 2) + b * (completeRuns) + c)
end

function main()
    lines = getDayInputLines(21)
    (grid, start) = parseGrid(lines)
    #for s in 2:50
    #    println(s, ": ", length(goSteps(start, grid, s, true)))
    #end
    #solution = goSteps(start, grid, 26501365, true)
    #println(length(solution))
    #printSolution(solution, grid, true)

    part2(start, grid, 26501365)
    #res = goSteps(start, grid, 5, true)
    #res2 = goSteps(start, grid, 10, true)
    #res3 = goSteps(start, grid, 15, true)
    #res4 = goSteps(start, grid, 20, true)
    #printSolution(res, grid, true)
    #println(length(res), " ", length(res2), " ", length(res3), " ", length(res4))
end

main()
