include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

function pq(distance, raceTime)
    p = - raceTime
    q = distance
    p_2 = p / 2
    prefix = -(p_2)
    postfix = sqrt(p_2 * p_2 - q)
    a = prefix - postfix
    b = prefix + postfix
    return (a, b)
end

function numberOfBetterResults(distance::Int64, raceTime::Int64)::Int64
    (a, b) = pq(distance, raceTime)
    r = abs(floor(b) - floor(a))
    if abs(b-a) == r
        return r - 1
    else
        return r
    end
end

numberOfBetterResults(timeAndDistance::Tuple{Int64, Int64})::Int64 = numberOfBetterResults(timeAndDistance[2], timeAndDistance[1])

function intsFromLine(line)
    matches = eachmatch(r"\d+", line)
    words = getfield.(matches, :match)
    parse.(Int64, words)
end

function main()
    lines = getDayInputLines(6)
    timesAndDistances = zip(intsFromLine(lines[1]), intsFromLine(lines[2]))
    println(reduce(*, map(numberOfBetterResults, timesAndDistances)))

    lines = map(line -> replace(line, " " => ""), lines)
    timesAndDistances = zip(intsFromLine(lines[1]), intsFromLine(lines[2]))
    println(reduce(*, map(numberOfBetterResults, timesAndDistances)))
end

main()
