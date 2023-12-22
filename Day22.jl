include("./AoC.jl")
using .AoC: getDayInputLines, getInts

function settleBricks(bricks)
    world = Set() # Set of all occupied cells after bricks fell down
    occupiedBy = Dict() # cell -> brickId
    supports = Dict() # brickId -> brickId
    supportedBy = Dict() # brickId -> brickId

    for (index, brick) in enumerate(bricks)
        (x1, y1, z1, x2, y2, z2) = brick

        if x1 != x2 # line on x
            deltaZ = 1
            below = Set()
            for z in z2:-1:1
                for x in x1:x2
                    miniBrick = (x, y2, z)
                    if miniBrick in world
                        push!(below, occupiedBy[miniBrick])
                    end
                end
                if !isempty(below)
                    break
                end
                deltaZ -= 1
            end
            for x in x1:x2
                miniBrick = (x, y2, z2+deltaZ)
                push!(world, miniBrick)
                occupiedBy[miniBrick] = index
                if !isempty(below)
                    for b in below
                        if !haskey(supports, b)
                            supports[b] = Set()
                        end
                        push!(supports[b], index)
                    end
                    supportedBy[index] = below
                end
            end
        elseif y1 != y2 # line on y
            deltaZ = 1
            below = Set()
            for z in z2:-1:1
                for y in y1:y2
                    miniBrick = (x2, y, z)
                    if miniBrick in world
                        push!(below, occupiedBy[miniBrick])
                    end
                end
                if !isempty(below)
                    break
                end
                deltaZ -= 1
            end
            for y in y1:y2
                miniBrick = (x2, y, z2+deltaZ)
                push!(world, miniBrick)
                occupiedBy[miniBrick] = index
                if !isempty(below)
                    for b in below
                        if !haskey(supports, b)
                            supports[b] = Set()
                        end
                        push!(supports[b], index)
                    end
                    supportedBy[index] = below
                end
            end
        else #if z1 != z2 # line on z
            deltaZ = 1
            below = nothing
            # find deltaZ
            for z in z1:-1:1 # from lower z to floor
                miniBrick = (x2, y2, z)
                if miniBrick in world # found occupied cell
                    below = occupiedBy[miniBrick]
                    break
                end
                deltaZ -= 1
            end
            for z in (z1+deltaZ):(z2+deltaZ)
                miniBrick = (x1, y2, z)
                push!(world, miniBrick)
                occupiedBy[miniBrick] = index
                if !isnothing(below)
                    if !haskey(supports, below)
                        supports[below] = Set()
                    end
                    push!(supports[below], index)
                    supportedBy[index] = Set(below)
                end
            end
        end
    end

    #printWorld(world, occupiedBy)
    return (supports, supportedBy)
end

function canRemove(brickId, supports, supportedBy)
    if haskey(supports, brickId)
        supportedBricks = supports[brickId]
        for supportedBrick in supportedBricks
            if length(supportedBy[supportedBrick]) == 1
                return false
            end
        end
    end
    return true
end

function part1(bricks, supports, supportedBy)
    possibleRemoves = 0
    for (brickId, brick) in enumerate(bricks)
        if canRemove(brickId, supports, supportedBy)
            possibleRemoves += 1
        end
    end
    println("Part 1: ", possibleRemoves)
end

function checkBrickCoordinateOrder(bricks)
    for brick in bricks
        if brick[1] > brick[4]
            throw("X")
        end
        if brick[2] > brick[5]
            throw("Y")
        end
        if brick[3] > brick[6]
            throw("Z")
        end
        #if brick[1] == brick[4] && brick[2] == brick[5] && brick[3] == brick[6]
        #    throw("XYZ")
        #end
    end
end

function printXZ(world, occupiedBy)
    miniBricks = collect(world)
    minX = minimum(map(miniBrick -> miniBrick[1], miniBricks))
    maxX = maximum(map(miniBrick -> miniBrick[1], miniBricks))
    minY = minimum(map(miniBrick -> miniBrick[2], miniBricks))
    maxY = maximum(map(miniBrick -> miniBrick[2], miniBricks))
    minZ = minimum(map(miniBrick -> miniBrick[3], miniBricks))
    maxZ = maximum(map(miniBrick -> miniBrick[3], miniBricks))
    for z in maxZ:-1:minZ
        for x in minX:maxX
            bricks = Set()
            for y in minY:maxY
                miniBrick = (x, y, z)
                if miniBrick in world
                    push!(bricks, occupiedBy[miniBrick])
                end
            end
            l = length(bricks)
            if l == 0
                print('.')
            elseif l == 1
                print(first(bricks))
            else
                print('?')
            end
        end
        println(" ", z)
    end
end

function printYZ(world, occupiedBy)
    miniBricks = collect(world)
    minX = minimum(map(miniBrick -> miniBrick[1], miniBricks))
    maxX = maximum(map(miniBrick -> miniBrick[1], miniBricks))
    minY = minimum(map(miniBrick -> miniBrick[2], miniBricks))
    maxY = maximum(map(miniBrick -> miniBrick[2], miniBricks))
    minZ = minimum(map(miniBrick -> miniBrick[3], miniBricks))
    maxZ = maximum(map(miniBrick -> miniBrick[3], miniBricks))
    for z in maxZ:-1:minZ
        for y in minY:maxY
            bricks = Set()
            for x in minX:maxX
                miniBrick = (x, y, z)
                if miniBrick in world
                    push!(bricks, occupiedBy[miniBrick])
                end
            end
            l = length(bricks)
            if l == 0
                print('.')
            elseif l == 1
                print(first(bricks))
            else
                print('?')
            end
        end
        println(" ", z)
    end
end

function printWorld(world, occupiedBy)
    printXZ(world, occupiedBy)
    println()
    printYZ(world, occupiedBy)
end

function bringsToFall(brickId, supports, supportedBy)
    if !haskey(supports, brickId)
        return 0
    end
    result = 0

    affected = supports[brickId]
    for b in affected
        delete!(supportedBy[b], brickId)
    end
    for b in affected
        if isempty(supportedBy[b])
            result += 1 + bringsToFall(b, supports, supportedBy)
        end
    end
    result
end

function part2(bricks, supports, supportedBy)
    numberOfFalling = 0
    for (brickId, brick) in enumerate(bricks)
        if !canRemove(brickId, supports, supportedBy)
            affects = bringsToFall(brickId, deepcopy(supports), deepcopy(supportedBy))
            numberOfFalling += affects
        end
    end
    println("Part 2: ", numberOfFalling)
end

function solve(bricks)
    (supports, supportedBy) = settleBricks(bricks)
    part1(bricks, supports, supportedBy)
    part2(bricks, supports, supportedBy)
end


function main()
    lines = getDayInputLines(22)
    bricks = map(getInts, lines)
    checkBrickCoordinateOrder(bricks)
    solve(sort(bricks, by = brick -> brick[6]))
end

main()
