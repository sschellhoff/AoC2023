include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

struct Game
    game
    grabs
end

mutable struct GameMax
    game
    red
    green
    blue
end

function parseGrabForOneColor(line)
    number_color = split(line, ' ')
    numberValue = parse(Int64, number_color[1])
    colorValue = number_color[2]
    (number = numberValue, color = colorValue)
end

function parseGrab(line)
    grabsOfColor = map(grabOfColor -> parseGrabForOneColor(grabOfColor), split(line, ", "))
    red = 0
    green = 0
    blue = 0
    for grabOfColor in grabsOfColor
        if grabOfColor.color == "red"
            red = grabOfColor.number
        end
        if grabOfColor.color == "green"
            green = grabOfColor.number
        end
        if grabOfColor.color == "blue"
            blue = grabOfColor.number
        end
    end
    (red = red, green = green, blue = blue)
end

function parseGrabs(line)
    grabs = split(line, "; ")
    map(grab -> parseGrab(grab), grabs)
end

function parseGame(line)
    parts = split(line, ": ")
    gameInfo = split(parts[1], ' ')
    gameNumber = parse(Int64, gameInfo[2])
    grabs = parseGrabs(parts[2])
    (game = gameNumber, grabs = grabs)
end

function parseGames(lines)
    map(line -> parseGame(line), lines)
end

function maxKnownColorsForGame(game)
    maxColoredGame = GameMax(game.game, 0, 0, 0)
    for grab in game.grabs
        if grab.red > maxColoredGame.red
            maxColoredGame.red = grab.red
        end
        if grab.blue > maxColoredGame.blue
            maxColoredGame.blue = grab.blue
        end
        if grab.green > maxColoredGame.green
            maxColoredGame.green = grab.green
        end
    end
    maxColoredGame
end

function isPossibleGrab(gameMax::GameMax, grab)
    gameMax.red <= grab.red && gameMax.blue <= grab.blue && gameMax.green <= grab.green
end

function gamePower(game::GameMax)
    game.red * game.blue * game.green
end

function main()
    # content = getDayInputLines(2, "_test")
    content = getDayInputLines(2)
    games = parseGames(content)
    gameMax = map(maxKnownColorsForGame, games)
    possibleGames = filter(game -> isPossibleGrab(game, (red = 12, green = 13, blue = 14)), gameMax)
    println(mapreduce(possibleGame -> possibleGame.game, +, possibleGames))
    println(mapreduce(gamePower, +, gameMax))
end

main()
