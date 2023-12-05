include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

struct MapEntry
    destination::Int64
    source::Int64
    size::Int64
end

function elementInEntry(element::Int64, entry::MapEntry)
    element >= entry.source && element <= entry.source + entry.size
end

function mapElementWithEntry(element::Int64, entry::MapEntry)
    delta = element - entry.source
    return entry.destination + delta
end

function canCut(range, entry::MapEntry)
    range[2] >= entry.source && range[1] <= entry.source + entry.size
end

function cutEntry(range, entry::MapEntry)
    rest = []
    intersection = intersect(range[1]:range[2], entry.source:(entry.source + entry.size))
    intersectionStart = first(intersection)
    intersectionStop = last(intersection)

    if intersectionStart > range[1]
        restStart = range[1]
        restStop = intersectionStart - 1
        push!(rest, (restStart, restStop))
    end
    if intersectionStop < range[2]
        restStart = intersectionStop + 1
        restStop = range[2]
        push!(rest, (restStart, restStop))
    end

    ((intersectionStart, intersectionStop), rest)
end

function parseRange(line)
    numbers = map(number -> parse(Int64, number), split(line, ' '))
    MapEntry(numbers[1], numbers[2], numbers[3])
end

function parseMap(content)
    data = popfirst!(content)
    lines = split(data, '\n')
    popfirst!(lines) # remove header
    map(parseRange, lines)
end

function parseTransformation(content)
    seed2soil = parseMap(content)
    soil2fertilizer = parseMap(content)
    fertilizer2water = parseMap(content)
    water2light = parseMap(content)
    light2temperature = parseMap(content)
    temperature2humidity = parseMap(content)
    humidity2location = parseMap(content)
    [
        seed2soil,
        soil2fertilizer,
        fertilizer2water,
        water2light,
        light2temperature,
        temperature2humidity,
        humidity2location
    ]
end

function singleTransformation(element::Int64, transformation)
    for entry in transformation
        if elementInEntry(element, entry)
            return mapElementWithEntry(element, entry)
        end
    end
    element
end

function runTransformations(element, transformations)
    currentValue = element
    for transformation in transformations
        currentValue = singleTransformation(currentValue, transformation)
    end
    currentValue
end

function singleRangedTransformation(ranges, transformation)
    intersections = []
    result = []
    
    while length(ranges) > 0
        range = pop!(ranges)
        usedRange = false
        for entry in transformation
            if canCut(range, entry)
                (intersection, rest) = cutEntry(range, entry)
                intersectionDestinationStart = singleTransformation(intersection[1], [entry])
                intersectionDestinationStop = singleTransformation(intersection[2], [entry])
                push!(intersections, (intersectionDestinationStart, intersectionDestinationStop))
                append!(ranges, rest)
                usedRange = true
                break
            end
        end
        if !usedRange
            push!(result, range)
        end
    end
    append!(result, intersections)
    append!(result, ranges)
    result
end

function runRangedTransformations(ranges, transformations)
    currentRanges = ranges
    for transformation in transformations
        currentRanges = singleRangedTransformation(currentRanges, transformation)
    end
    currentRanges
end

parseSeeds(content) = map(seed -> parse(Int64, seed), split(replace(popfirst!(content), "seeds: " => ""), ' '))

function parseSeedRanges(content)
    numbers = parseSeeds(content)
    seeds = []
    for i in 1:2:length(numbers)
        start = numbers[i]
        size = numbers[i + 1]
        push!(seeds, (start, start + size - 1))
    end
    seeds
end

function parseContentPart1(content)
    seeds = parseSeeds(content)
    transformation = parseTransformation(content)
    (seeds, transformation)
end

function part1()
    content = getDayInputBlocks(5)
    (seeds, transformations) = parseContentPart1(content)
    locations = map(seed -> runTransformations(seed, transformations), seeds)
    minimum(locations)
end

function parseContentPart2(content)
    seeds = parseSeedRanges(content)
    transformation = parseTransformation(content)
    (seeds, transformation)
end

function part2()
    content = getDayInputBlocks(5)
    (seedRanges, transformations) = parseContentPart2(content)
    locations = runRangedTransformations(seedRanges, transformations)
    minimum(map(location -> location[1], locations))
end

function main()   
    println(part1())
    println(part2())
end

main()
