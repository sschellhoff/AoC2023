include("./AoC.jl")
using .AoC: getDayInputLines

@enum Direction North East South West

opposite(direction::Direction)::Direction = Dict([
    (North, South),
    (South, North),
    (East, West),
    (West, East)
])[direction]

function getTile(grid, position)
    (x, y) = position
    if checkbounds(Bool, grid, y) && checkbounds(Bool, grid[y], x)
        grid[y][x]
    else
        '.'
    end
end

function canAccess(grid, from, to, direction)
    fromTile = getTile(grid, from)
    toTile = getTile(grid, to)
    fromDirections = getDirections(fromTile)
    if direction ∉ fromDirections
        return false
    end
    toDirections = getDirections(toTile)
    opposite(direction) in toDirections
end

getDirections(c::Char)::Vector{Direction} = Dict([
    ('|', [North, South]),
    ('-', [West, East]),
    ('L', [North, East]),
    ('J', [North, West]),
    ('7', [South, West]),
    ('F', [South, East]),
    ('.', []),
    ('S', [North, East, South, West])
])[c]

function findStart(grid)
    for (y, row) in enumerate(grid)
        xs = findall(x -> row[x] == 'S', 1:length(row))
         if length(xs) > 0
            return (xs[1], y)
         end
    end
end

function move(position, direction::Direction)
    (x, y) = position
    if direction == North
        (x, y-1)
    elseif direction == South
        (x, y+1)
    elseif direction == East
        (x+1, y)
    elseif direction == West
        (x-1, y)
    end
end

function getNext(grid, currentPosition)
    currentTile = getTile(grid, currentPosition)
    currentDirections = getDirections(currentTile)
    nextTiles = []
    for direction in currentDirections
        nextTile = move(currentPosition, direction)
        if canAccess(grid, currentPosition, nextTile, direction)
            push!(nextTiles, nextTile)
        end
    end
    nextTiles
end

function bfs(grid, start)
    visited = []
    nodes = [start]
    while true
        node = popfirst!(nodes)
        if node in visited
            return visited
        end
        push!(visited, node)
        next = filter(nextNode -> nextNode ∉ visited, getNext(grid, node))
        for nextNode in next
            push!(nodes, nextNode)
        end
    end
end

function scale(graph, path)
    originalWidth = length(graph[1])
    originalHeight = length(graph)
    newWidth = originalWidth * 3
    newHeight = originalHeight * 3
    scaledGraph = zeros(Int8, (newHeight, newWidth))
    for position in path
        copyTile(graph, scaledGraph, position)
    end
    scaledGraph
end

function isFree(graph, position)
    (startX, startY) = position
    for dy in 1:3
        for dx in 1:3
            value = getTileInScaled(graph, (startX + dx, startY + dy))
            if value != 0
                return false
            end
        end
    end
    return true
end

function scaleDown(graph)
    (height, width) = size(graph)
    scaledGraph = zeros(Int8, (floor(Int, height/3), floor(Int, width/3)))
    for y in 1:3:height
        for x in 1:3:width
            newX = floor(Int, ((x-1) / 3) + 1)
            newY = floor(Int, ((y-1) / 3) + 1)
            if isFree(graph, (x, y))
                setTileInScaled(scaledGraph, (newX, newY), 0)
            else
                setTileInScaled(scaledGraph, (newX, newY), 1)
            end
        end
    end
    scaledGraph
end

function getTileInScaled(grid, position)
    (x, y) = position
    if checkbounds(Bool, grid, y, x)
        grid[y, x]
    else
        1
    end
end

function setTileInScaled(grid, position, value)
    (x, y) = position
    if checkbounds(Bool, grid, y, x)
        grid[y, x] = value
    end
end

function copyTile(graph, scaledGraph, position)
    (startX, startY) = position
    if !checkbounds(Bool, graph, startY) || !checkbounds(Bool, graph[startY], startX)
        return
    end
    tile = getTile(graph, position)
    directions = getDirections(tile)
    midX = 3 * (startX - 1) + 2
    midY = 3 * (startY - 1) + 2
    for pos in map(direction -> move((midX, midY), direction), directions)
        (x, y) = pos
        scaledGraph[y, x] = 1
    end
    scaledGraph[midY, midX] = 1
end

function printGraph(graph)
    (height, width) = size(graph)
    for y in 1:height
        for x in 1:width
            print(graph[y, x])
        end
        println()
    end
end

function floodFill(graph, start)
    positions = [start]
    while length(positions) > 0
        position = pop!(positions)
        if getTileInScaled(graph, position) == 0
            setTileInScaled(graph, position, 1)
            push!(positions, move(position, North))
            push!(positions, move(position, South))
            push!(positions, move(position, East))
            push!(positions, move(position, West))
        end
    end
end

function countFreeTiles(graph)
    length(findall(value -> value == 0, graph))
end

function main()
    rows = getDayInputLines(10)
    start = findStart(rows)
    path = bfs(rows, start)
    println("Part 1: ", floor(Int64, length(path)/ 2))
    scaledGraph = scale(rows, path)
    floodFill(scaledGraph, (1, 1))
    println("Part 2: ", countFreeTiles(scaleDown(scaledGraph)))
end

main()
