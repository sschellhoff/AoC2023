include("./AoC.jl")
using .AoC: getDayInputLines, getInts
using Memoization

function findPermutations(springs, damaged, cache)
    newSprings = drop(springs, '.')
    if length(damaged) == 0 && !isnothing(findfirst('#', newSprings))
        return 0
    end
    if length(damaged) == 0 && isnothing(findfirst('#', newSprings))
        return 1
    end
    if length(newSprings) == 0 && length(damaged) > 0
        return 0
    end
    if newSprings == '.' && length(damaged) > 0
        return 0
    end
    (numberOfDamaged, newDamaged) = dropfirst(damaged)
    if first(newSprings) == '#'
        if canPlace(newSprings, numberOfDamaged)
            rhs = findPermutationsCached(newSprings[(numberOfDamaged+2):end], newDamaged, cache)
            if isnothing(rhs)
                return 0
            end
            return rhs
        else
            return 0
        end
    elseif first(newSprings) == '?'
        v1 = "#$(newSprings[2:end])"
        v2 = newSprings[2:end]
        _v1 = findPermutationsCached(v1, damaged, cache)
        _v2 = findPermutationsCached(v2, damaged, cache)
        return _v1 + _v2
    end
    0
end

function findPermutationsCached(springs, damaged, cache)
    key = (springs, damaged)
    if !haskey(cache, key)
        cache[key] = findPermutations(springs, damaged, cache)
    end
    cache[key]
end

function expect(actual, expected)
    if actual != expected
        error("expected '$expected' but got '$actual'")
    end
end

function drop(string, value)
    for (index, c) in enumerate(string)
        if c != value
            return string[index:end]
        end
    end
    string
end

dropfirst(array) = (first(array), array[2:end])

function canPlace(string, len)
    if len > length(string)
        return false
    end
    for index in 1:len
        if string[index] == '.'
            return false
        end
    end
    len == length(string) || string[len + 1] != '#'
end

function parseInput(lines)
    mapParsedLine(splitLine) = (splitLine[1], getInts(splitLine[2]))
    parseLine(line) = mapParsedLine(split(line, ' '))
    map(parseLine, lines)
end

function findPermutationsForInput(inputs)
    for input in inputs
        println(input)
        findPermutations(input[1], input[2], Dict())
    end
end

function unfoldSprings(springs)
    return "$springs?$springs?$springs?$springs?$springs"
end

function unfoldDamaged(damaged)
    vcat(damaged, damaged, damaged, damaged, damaged)
end

function main()
    input = parseInput(getDayInputLines(12))
    #expect(findPermutations("?", []), 1)
    #expect(findPermutations(".", []), 1)
    #expect(findPermutations("#", []), nothing)
    #expect(canPlace("#", 1), true)
    #expect(canPlace("", 1), false)
    #expect(canPlace("", 0), true)
    #expect(canPlace("?", 1), true)
    #expect(canPlace("#", 1), true)
    #expect(canPlace("#", 2), false)
    #expect(canPlace("#.", 2), false)
    #expect(canPlace("#?", 2), true)
    #expect(findPermutations("#", [1]), 1)
    #expect(findPermutations("##", [2]), 1)
    #expect(findPermutations("##.#..###.#", [2, 1, 3, 1]), 1)
    #expect(findPermutations("??", [1]), 2)
    #expect(findPermutations("???.###", [1, 1, 3]), 1)
    #expect(findPermutations("?###????????", [3,2,1]), 10)
    println(reduce(+, map(inp -> findPermutations(inp[1], inp[2], Dict()), input)))
    println(reduce(+, map(inp -> findPermutations(unfoldSprings(inp[1]), unfoldDamaged(inp[2]), Dict()), input)))
end

main()
