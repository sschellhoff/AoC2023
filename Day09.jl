include("./AoC.jl")
using .AoC: getDayInputLines, getInts

slidingWindow(collection, stepSize::Int64, windowSize::Int64) = ((@view collection[i:i+windowSize-1]) for i in 1:stepSize:length(collection)-windowSize+1)

function extrapolateEnd(numbers::Vector{Int64})::Int64
    differences = map(e -> e[2] -  e[1], slidingWindow(numbers, 1, 2))
    if length(filter(e -> e != 0, differences)) == 0
        last(numbers)
    else
        last(numbers) + extrapolateEnd(differences)
    end
end

function extrapolateStart(numbers::Vector{Int64})::Int64
    differences = map(e -> e[2] -  e[1], slidingWindow(numbers, 1, 2))
    if length(filter(e -> e != 0, differences)) == 0
        first(numbers)
    else
        first(numbers) - extrapolateStart(differences)
    end
end

function main()
    rows = map(getInts, getDayInputLines(9))
    println(reduce(+, map(extrapolateEnd, rows)))
    println(reduce(+, map(extrapolateStart, rows)))
end

main()
