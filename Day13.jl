include("./AoC.jl")
using .AoC: getDayInputBlocks

function toMatrix(block)
    lines = split(block, '\n')
    height = length(lines)
    width = length(first(lines))
    matrix = Matrix{Char}(undef, height, width)
    for (y, line) in enumerate(lines)
        for (x, value) in enumerate(line)
            matrix[y, x] = value
        end
    end
    matrix
end

row(matrix, index) = matrix[index,:]
column(matrix, index) = matrix[:,index]
numRows(matrix) = size(matrix)[1]
numColumns(matrix) = size(matrix)[2]

function isMirrorAfterRow(matrix, index)
    lastRowIndex = numRows(matrix)
    upper = index
    lower = index + 1
    while upper >= 1 && lower <= lastRowIndex
        if row(matrix, upper) != row(matrix, lower)
            return false
        end
        upper -= 1
        lower += 1
    end
    return true
end

function findMirrorInRow(matrix, startRow=1)
    for row in startRow:numRows(matrix)-1
        if isMirrorAfterRow(matrix, row)
            return row
        end
    end
    return 0
end

function isMirrorAfterColumn(matrix, index)
    lastColumnIndex = numColumns(matrix)
    left = index
    right = index + 1
    while left >= 1 && right <= lastColumnIndex
        if column(matrix, left) != column(matrix, right)
            return false
        end
        left -= 1
        right += 1
    end
    return true
end

function findMirrorInColumn(matrix, startColumn=1)
    for column in startColumn:numColumns(matrix)-1
        if isMirrorAfterColumn(matrix, column)
            return column
        end
    end
    return 0
end

function findAllMirrorInRow(matrix)
    result = []
    row = findMirrorInRow(matrix)
    while row != 0
        push!(result, row)
        row = findMirrorInRow(matrix, row+1)
    end
    result
end

function findMirrorInRowWithSmudge(matrix)
    (h, w) = size(matrix)
    for n in 1:w
        for m in 1:h
            oldValue = matrix[m, n]
            matrix[m, n] = oldValue == '.' ? '#' : '.'
            mirrorsAfterRow = findAllMirrorInRow(matrix)
            matrix[m, n] = oldValue

            mid = h / 2
            isSmudgeInMirroredArea(mirrorAfterRow) = mirrorAfterRow == mid || (mirrorAfterRow < mid && mirrorAfterRow * 2 > m) || (mirrorAfterRow > mid && (h - 2 * (h - mirrorAfterRow)) < m)
            isMirror(mirrorAfterRow) = mirrorAfterRow > 0 && isSmudgeInMirroredArea(mirrorAfterRow)
            mirror = filter(isMirror, mirrorsAfterRow)
            if length(mirror) > 0
                return first(mirror)
            end
        end
    end
    return 0
end

function findAllMirrorInColumn(matrix)
    result = []
    col = findMirrorInColumn(matrix)
    while col != 0
        push!(result, col)
        col = findMirrorInColumn(matrix, col+1)
    end
    result
end

function findMirrorInColumnWithSmudge(matrix)
    (h, w) = size(matrix)
    for n in 1:w
        for m in 1:h
            oldValue = matrix[m, n]
            matrix[m, n] = oldValue == '.' ? '#' : '.'
            mirrorsAfterColumn = findAllMirrorInColumn(matrix)
            matrix[m, n] = oldValue

            mid = w / 2
            isSmudgeInMirroredArea(mirrorAfterColumn) = mirrorAfterColumn == mid || (mirrorAfterColumn < mid && mirrorAfterColumn * 2 > n) || (mirrorAfterColumn > mid && (w - 2 * (w - mirrorAfterColumn)) < n)
            isMirror(mirrorAfterColumn) = mirrorAfterColumn > 0 && isSmudgeInMirroredArea(mirrorAfterColumn)
            mirror = filter(isMirror, mirrorsAfterColumn)
            if length(mirror) > 0
                return first(mirror)
            end
        end
    end
    return 0
end

function main()
    matrices = map(toMatrix, getDayInputBlocks(13))

    rowSum = mapreduce(findMirrorInRow, +, matrices)
    columnSum = mapreduce(findMirrorInColumn, +, matrices)
    println(rowSum * 100 + columnSum)

    rowSum = mapreduce(findMirrorInRowWithSmudge, +, matrices)
    columnSum = mapreduce(findMirrorInColumnWithSmudge, +, matrices)
    println(rowSum * 100 + columnSum)
end

main()
