include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks
import StatsBase: countmap

function rankCard(card::Char, withReplacedJoker::Bool)::Int64
    if withReplacedJoker && card == 'J'
        return 1
    end
    cardRanks = Dict([
        ('2', 2),
        ('3', 3),
        ('4', 4),
        ('5', 5),
        ('6', 6),
        ('7', 7),
        ('8', 8),
        ('9', 9),
        ('T', 10),
        ('J', 11),
        ('Q', 12),
        ('K', 13),
        ('A', 14),
        ])
        cardRanks[card]
end

function rankCards(hand, withReplacedJoker::Bool)::Int64
    rank = 0
    for card in hand
        rank *= 100
        cardRank = rankCard(card, withReplacedJoker)
        rank += cardRank
    end
    rank
end

function rankHand(hand, shouldReplaceJoker::Bool)::Int64
    handToCound = if shouldReplaceJoker
        replaceJoker(hand)
    else
        hand
    end
    cardCounts = sort(collect(values(countmap(collect(handToCound)))))
    cardCountRanks = Dict([
        ([1, 1, 1, 1, 1], 1), # high card
        ([1, 1, 1, 2],    2), # one pair
        ([1, 2, 2],       3), # two pair
        ([1, 1, 3],       4), # three of a kind
        ([2, 3],          5), # full house
        ([1, 4],          6), # four of a kind
        ([5],             7), # five of a kind
    ])
    handRanked = cardCountRanks[cardCounts]
    cardsRanked = rankCards(hand, shouldReplaceJoker)
    handRanked *= 10000000000
    handRanked + cardsRanked
end

maxBy(elements, f) = last(sort(elements, by=f))

function replaceJoker(line)
    cards = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A']
    rank(element) = rankHand(split(element, ' ')[1], false)
    maxBy(map(card -> replace(line, 'J' => card), cards), rank)
end

function calculateWinnings(lines, shouldReplaceJoker=false)
    rankLine(line) = rankHand(split(line, ' ')[1], shouldReplaceJoker)
    handsSortedByRank = sort(lines, by=rankLine)
    result = 0
    for (index, line) in enumerate(handsSortedByRank)
        result += index * parse(Int64, split(line, ' ')[2])
    end
    result
end

function main()
    lines = getDayInputLines(7)
    println(calculateWinnings(lines))
    println(calculateWinnings(lines, true))
end

main()
