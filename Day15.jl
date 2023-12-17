include("./AoC.jl")
using .AoC: getDayInputLines

function calcHash(step)
    s = split(step, '=')
    if length(s) == 2
        return (calcSequence(s[1]), s[1])
    end
    s = s[1]
    (calcSequence(s[1:end-1]), s[1:end-1])
end

function getNumber(step)
    s = split(step, '=')
    if length(s) == 2
        return s[2]
    end
    nothing
end

function calc(sequences)
    mapreduce(calcSequence, +, collect(Iterators.flatten(sequences)))
end

function calcSequence(sequence)
    result = 0
    for c in sequence
        result += Int(c)
        result *= 17
        result %= 256
    end
    result
end

function indexOf(arr, value)
    for (i, val) in enumerate(arr)
        if val[1] == value
            return i
        end
    end
end

function part2(sequences)
    buckets = []
    for i in 1:256
        push!(buckets, [])
    end
    for sequence in Iterators.flatten(sequences)
        (h, str) = calcHash(sequence)
        num = getNumber(sequence)
        if isnothing(num)
            i = indexOf(buckets[h+1], str)
            if isnothing(i)
                continue
            end
            deleteat!(buckets[h+1], i)
        else
            i = indexOf(buckets[h+1], str)
            if isnothing(i)
                push!(buckets[h+1], (str, num))
            else
                buckets[h+1][i] = (str, num)
            end
        end
    end
    result = 0
    for (i1, bucket) in enumerate(buckets)
        for (i2, value) in enumerate(bucket)
            #println(value)
            result += i1 * i2 * parse(Int, value[2])
        end
    end
    result
end

function main()
    lines = getDayInputLines(15)
    sequences = map(line -> split(line, ','), lines)
    println(calc(sequences))
    println(part2(sequences))
end

main()
