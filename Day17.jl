include("./AoC.jl")
using .AoC: getDayInputLines

@enum Direction up down left right

struct Grid
    data
    width
    height
end

function createGrid(lines)
    height = length(lines)
    width = length(first(lines))
    data = zeros(Int8, (height, width))
    for (y, line) in enumerate(lines)
        for (x, value) in enumerate(line)
            data[y, x] = parse(Int8, value)
        end
    end
    Grid(data, width, height)
end

isInBounds(position::Tuple{Int, Int}, grid::Grid) = let (x, y) = position
    x >= 1 && y >= 1 && y <= grid.height && x <= grid.width
end

getCost(position::Tuple{Int, Int}, grid::Grid) = let(x, y) = position
    grid.data[y, x]
end

function next(grid::Grid, position::Tuple{Int, Int}, lastDirection::Direction, sameDirectionCount::Int, lastCost::Int)
    posUp = (position[1], position[2] - 1)
    posDown = (position[1], position[2] + 1)
    posLeft = (position[1] - 1, position[2])
    posRight = (position[1] + 1, position[2])
    calcCost(pos) = getCost(pos, grid) + lastCost

    result = []
    if lastDirection == up
        if isInBounds(posUp, grid) && sameDirectionCount < 3
            push!(result, (calcCost(posUp), posUp, right, sameDirectionCount + 1))
        end
        if isInBounds(posLeft, grid)
            push!(result, (calcCost(posLeft), posLeft, left, 1))
        end
        if isInBounds(posRight, grid)
            push!(result, (calcCost(posRight), posRight, right, 1))
        end
    elseif lastDirection == down
        if isInBounds(posDown, grid) && sameDirectionCount < 3
            push!(result, (calcCost(posDown), posDown, down, sameDirectionCount + 1))
        end
        if isInBounds(posLeft, grid)
            push!(result, (calcCost(posLeft), posLeft, left, 1))
        end
        if isInBounds(posRight, grid)
            push!(result, (calcCost(posRight), posRight, right, 1))
        end
    elseif lastDirection == left
        if isInBounds(posLeft, grid) && sameDirectionCount < 3
            push!(result, (calcCost(posLeft), posLeft, left, sameDirectionCount + 1))
        end
        if isInBounds(posUp, grid)
            push!(result, (calcCost(posUp), posUp, up, 1))
        end
        if isInBounds(posDown, grid)
            push!(result, (calcCost(posDown), posDown, down, 1))
        end
    elseif lastDirection == right
        if isInBounds(posRight, grid) && sameDirectionCount < 3
            push!(result, (calcCost(posRight), posRight, right, sameDirectionCount + 1))
        end
        if isInBounds(posUp, grid)
            push!(result, (calcCost(posUp), posUp, up, 1))
        end
        if isInBounds(posDown, grid)
            push!(result, (calcCost(posDown), posDown, down, 1))
        end
    end
    result
end

function find(grid::Grid, start::Tuple{Int, Int}, target::Tuple{Int, Int})
    currentPosition = (start[1], start[2])
    currentDirection = right
    currentCost = 0
    sameDirectionCount = 0
    manhattanDistance(pos::Tuple{Int, Int}) = abs(target[1] - pos[1]) + abs(target[2] - pos[2])

    states = [(currentCost, currentPosition, currentDirection, sameDirectionCount)]
    visited = Dict()
    while currentPosition != target
        (currentCost, currentPosition, currentDirection, sameDirectionCount) = pop!(sort!(states, by=x -> x[1], rev=true))# + manhattanDistance(x[2])))
        #println(currentPosition)
        if haskey(visited, (currentPosition, currentDirection, sameDirectionCount)) && visited[(currentPosition, currentDirection, sameDirectionCount)] <= currentCost
            continue
        end
        visited[(currentPosition, currentDirection, sameDirectionCount)] = currentCost

        for state in next(grid, currentPosition, currentDirection, sameDirectionCount, currentCost)
            #key = (state[2], state[3])
            #if haskey(visited, key) && visited[key] <= state[1]
            #    continue
            #end
            push!(states, state)
        end
    end
    currentCost
end

function main()
    lines = getDayInputLines(17)
    grid = createGrid(lines)
    println(find(grid, (1, 1), (grid.width, grid.height)))
end

main()
