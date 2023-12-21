include("./AoC.jl")
using .AoC: getDayInputLines

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

isFree(point::Point, grid::Grid)::Bool = isInGrid(point, grid) && point ∉ grid.collisions

doStep(point::Point, grid::Grid)::Vector{Point} = filter(newPoint -> isFree(newPoint, grid), goInAllDirections(point))

doTwoSteps(point::Point, grid::Grid)::Set{Point} = Set(Iterators.flatten(map(p -> doStep(p, grid), doStep(point, grid))))

function doTwoSteps(points::Set{Point}, grid::Grid)::Set{Point}
    result = Set()
    for point in points
        union!(result, doTwoSteps(point, grid))
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

function goSteps(start::Point, grid::Grid, numberOfSteps::Int)::Set{Point}
    if numberOfSteps % 2 != 0
        throw("only an even number of steps is supported")
    end
    seenPoints = Set([start])
    openList = Set([start])

    while numberOfSteps > 0
        # mark openlist as seen
        union!(seenPoints, openList)

        # get new points
        openList = setdiff(doTwoSteps(openList, grid), seenPoints)
        numberOfSteps -= 2
    end
    union!(seenPoints, openList)
    seenPoints
end

function printSolution(points::Set{Point}, grid::Grid)
    for y in 1:grid.height
        for x in 1:grid.width
            if !isFree((x, y), grid)
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

function main()
    lines = getDayInputLines(21)
    (grid, start) = parseGrid(lines)
    solution = goSteps(start, grid, 64)
    println(length(solution))
    #printSolution(solution, grid)
end

main()
