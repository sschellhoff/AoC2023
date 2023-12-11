include("./AoC.jl")
using .AoC: getDayInputLines

function getEmptyRows(lines)
    emptyRows = []
    for (index, line) in enumerate(lines)
        if '#' ∉ line
            push!(emptyRows, index)
        end
    end
    emptyRows
end

function getEmptyColumns(lines)
    emptyColumns = []
    width = length(lines[1])
    for x in 1:width
        if !columnContaines('#', lines, x)
            push!(emptyColumns, x)
        end
    end
    emptyColumns
end

function columnContaines(value, lines, columnIndex)
    for y in eachindex(lines)
        if lines[y][columnIndex] == value
            return true
        end
    end
    false
end

function getGalaxies(scaleBy::Int64, lines)
    emptyRows = getEmptyRows(lines)
    emptyColumns = getEmptyColumns(lines)
    galaxies = []
    for y in eachindex(lines)
        for x in eachindex(lines[y])
            if lines[y][x] == '#'
                dx = length(filter(column -> column < x, emptyColumns)) * (scaleBy - 1)
                dy = length(filter(row -> row < y, emptyRows)) * (scaleBy - 1)
                push!(galaxies, (x + dx, y + dy))
            end
        end
    end
    galaxies
end

function manhattanDistance(a, b)
    (x1, y1) = a
    (x2, y2) = b
    abs(x1 - x2) + abs(y1 - y2)
end

function shortestDistancesBetweenAllGalaxies(galaxies)
    distances = []
    for (index, g1) in enumerate(galaxies)
        for index2 in index:length(galaxies)
            g2 = galaxies[index2]
            push!(distances, manhattanDistance(g1, g2))
        end
    end
    distances
end

function main()
    lines = getDayInputLines(11)
    galaxies = getGalaxies(2, lines)
    println(reduce(+, shortestDistancesBetweenAllGalaxies(galaxies)))
    galaxies = getGalaxies(1000000, lines)
    println(reduce(+, shortestDistancesBetweenAllGalaxies(galaxies)))
end

main()
