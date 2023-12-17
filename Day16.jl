include("./AoC.jl")
using .AoC: getDayInputLines
#
@enum Direction up down left right

struct Grid
    data
end

function moveFrom(grid::Grid, move::Tuple{Tuple{Int, Int}, Direction})
    (pos, direction) = move
    (x, y) = pos
    currentTile = grid.data[y][x]
    moveUp = ((x, y-1), up)
    moveDown = ((x, y+1), down)
    moveRight = ((x+1, y), right)
    moveLeft = ((x-1, y), left)
    nextMoves = Dict(
        (right, '/') => [moveUp],
        (right, '\\') => [moveDown],
        (right, '|') => [moveUp, moveDown],

        (left, '/') =>[moveDown],
        (left, '\\') => [moveUp],
        (left, '|') => [moveUp, moveDown],

        (up, '/') => [moveRight],
        (up, '\\') => [moveLeft],
        (up, '-') => [moveLeft, moveRight],

        (down, '/') => [moveLeft],
        (down, '\\') => [moveRight],
        (down, '-') => [moveLeft, moveRight]
    )
    goStraight = Dict(
        left => [moveLeft],
        right => [moveRight],
        up => [moveUp],
        down => [moveDown]
    )
    if haskey(nextMoves, (direction, currentTile))
        return nextMoves[(direction, currentTile)]
    end
    goStraight[direction]
end

function doIt(grid::Grid, startPosition::Tuple{Int, Int}, direction::Direction)
    configurations = Set()
    seenConfigurations = Set()
    push!(configurations, (startPosition, direction))
    push!(seenConfigurations, (startPosition, direction))

    while length(configurations) > 0
        for next in moveFrom(grid, pop!(configurations))
            if next in seenConfigurations || next[1][1] < 1 || next[1][2] < 1 || next[1][1]  > length(grid.data[1]) || next[1][2] > length(grid.data)
                continue
            end
            push!(seenConfigurations, next)
            push!(configurations, next)
        end
    end
    return length(collect(Set(map(value -> value[1], collect(seenConfigurations)))))
end

function part2(grid::Grid)
    currentMax = 0
    for y in 1:length(grid.data)
        v1 = doIt(grid, (1, y), right)
        v2 = doIt(grid, (length(grid.data[1]), y), left)
        if max(v1, v2) > currentMax
            currentMax = max(v1, v2)
        end
    end

    for x in 1:length(grid.data[1])
        v1 = doIt(grid, (x, 1), down)
        v2 = doIt(grid, (x, length(grid.data)), up)
        if max(v1, v2) > currentMax
            currentMax = max(v1, v2)
        end
    end
    return currentMax
end

function main()
    lines = getDayInputLines(16)
    println(doIt(Grid(lines), (1, 1), right))
    println(part2(Grid(lines)))
end

main()
