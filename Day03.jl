include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

isSymbol(c::Char)::Bool = !isdigit(c) && c != '.'

function parseContent(line)
    readingNumber = false
    currentNumber = 0
    startPosition = 0
    endPosition = 0
    entries = []
    for (index, c) in enumerate(line)
        if readingNumber && isdigit(c)
            currentNumber = currentNumber * 10 + parse(Int64, c)
        elseif isdigit(c)
            readingNumber = true
            currentNumber = parse(Int64, c)
            startPosition = index
        elseif readingNumber
            endPosition = index - 1
            readingNumber = false
            numberInfo = (start = startPosition, stop = endPosition, number = currentNumber)
            push!(entries, numberInfo)
        end
        if index == length(line) && readingNumber
            endPosition = index
            readingNumber = false
            numberInfo = (start = startPosition, stop = endPosition, number = currentNumber)
            push!(entries, numberInfo)
        end
    end
    entries
end

function surroundedBy(predicate, content, numberInfo, y)
    start = numberInfo.start - 1
    stop = numberInfo.stop + 1
    if start > 0 && predicate(content[y][start])
        return true
    end
    if stop <= length(content[y]) && predicate(content[y][stop])
        return true
    end
    prev_y = y - 1
    next_y = y + 1
    for x in start:stop
        if prev_y > 0 && x > 0 && x <= length(content[prev_y]) && predicate(content[prev_y][x])
            return true
        end
        if next_y <= length(content) && x > 0 && x <= length(content[next_y]) && predicate(content[next_y][x])
            return true
        end
    end
    return false
end

function countNumbersWithAdjaventSymbols(content, numberInfos)
    result = 0
    for (y, numberInfo) in enumerate(numberInfos)
        surroundedNumberInfo = filter(ni -> surroundedBy(isSymbol, content, ni, y), numberInfo)
        if length(surroundedNumberInfo) > 0
            result = result + mapreduce(ni -> ni.number, +, surroundedNumberInfo)
        end
    end
    result
end

function findGears(content)
    result = []
    for y in eachindex(content)
        for x in eachindex(content[y])
            if content[y][x] == '*'
                push!(result, (x, y))
            end
        end
    end
    result
end

function overlap(gearX, numberInfos)
    result = []
    for numberInfo in numberInfos
        if (numberInfo.start - 1) <= gearX && (numberInfo.stop + 1) >= gearX
            push!(result, numberInfo)
        end
    end
    result
end

function getGearRatios(content, numberInfos)
    gears = findGears(content)
    ratios = []
    for gear in gears
        gearX = gear[1]
        gearY = gear[2]
        foundNumbers = overlap(gearX, numberInfos[gearY])
        if gearY > 1
            foundNumbers = vcat(foundNumbers, overlap(gearX, numberInfos[gearY - 1]))
        end
        if gearY < length(content)
            foundNumbers = vcat(foundNumbers, overlap(gearX, numberInfos[gearY + 1]))
        end
        if length(foundNumbers) == 2
            push!(ratios, mapreduce(value -> value.number, *, foundNumbers))
        end
    end
    ratios
end

function countGearRatios(content, numberInfos)
    gearRatios = getGearRatios(content, numberInfos)
    reduce(+, gearRatios)
end

function main()
    #content = getDayInputLines(3, "_test")
    content = getDayInputLines(3)
    numberInfos = map(parseContent, content)
    println(countNumbersWithAdjaventSymbols(content, numberInfos))
    println(countGearRatios(content, numberInfos))
end

main()
