
//  ConnectFourModel.swift
//  Model
//
//  Created by Helena on 01.03.22

import Foundation
import SwiftUI


// Coin object
enum Coin {
    case red
    case yellow
    case white
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .white:
            return .white
        }
    }
}


// All possible strategies in Strategy object
enum Strategy: String, CaseIterable {
    
    case complete4
    case complete3
    case complete2
    case block4
    case block3
    case block2
    
    var strategyString: String {
        switch self {
        case .complete4: return "complete4"
        case .complete3: return "complete3"
        case .complete2: return "complete2"
        case .block4: return "block4"
        case .block3: return "block3"
        case .block2: return "block2"
        }
    }
}


// Player object
enum Player: CaseIterable {
    case red, yellow, none

    // Switching players every round
    mutating func toggle() {
        switch self {
        case .red: self = .yellow
        case .yellow: self = .red
        case .none: self = .none
        }
    }
    
    // The coin that belongs to the player
    var player_item: Coin {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .none: return .white
        }
    }
    
    // Name of the player
    var name: String {
        switch self {
        case .red: return "red"
        case .yellow: return "yellow"
        case .none: return "no player"
        }
    }
    
    // Color of the player
    var color: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .none: return .white
        }
    }
    
    // Is true if the player is the model
    var isModel: Bool {
        switch self {
        case .red: return false
        case .yellow: return true
        case .none: return false
        }
    }
}


// Overarching model struct, this is immutable and the ground truth. Therefore, the ViewModel creates an instance of it and exposes it to the View
struct Connect4Model {
    
    // ACT-R model
    let model = Model()
    
    init() {
        model.loadModel(fileName: "connect4model")
        model.run()
        
        // Initial knowledge a human would have from reading the game manual
        makeInitialActivation(strategy: "complete4", initialActivation: 1.7)
        makeInitialActivation(strategy: "block4", initialActivation: 1.7)
        makeInitialActivation(strategy: "complete3", initialActivation: 1.0)
        makeInitialActivation(strategy: "block3", initialActivation: 1.0)
        makeInitialActivation(strategy: "complete2", initialActivation: 1.0)
        makeInitialActivation(strategy: "block2", initialActivation: 1.0)
      
        
        // create grid to locate coins
        let initCol = Array(repeating: Coin.white, count: cols)
        gameGrid = Array(repeating: initCol, count:rows)
    }
    
    private(set) var gameGrid = [[Coin]]()
    private(set) var player: Player = .red
    private(set) var winner: Player = .none
    
    private(set) var isFirstMove: Bool = true
    private(set) var firstPlayer: Player = .red
    private(set) var firstMove : Int = Int.random(in: 0..<7)
    private(set) var firstStrategyCol : Int = Int.random(in: 0..<7)
    
    private var modelStrategies : [Chunk] = []
    
    private let cols = 7
    private let rows = 6
    
    private(set) var YellowScore: Int = 0
    private(set) var RedScore: Int = 0
    
    var stalemateview : Bool = false
    
    // Returns color of coin in the grid
    func getColor(row:Int, column:Int) -> Color{
        let coinColor:Color = gameGrid[row][column].color
        return coinColor
    }
    
    // Returns the score of the current player
    func getScore(currentPlayer: Player) -> Int{
        var score: Int = 0
        
        if currentPlayer == .red {
            score = RedScore
        } else if currentPlayer == .yellow {
            score = YellowScore
        }
        return score
    }
     
    // Resets the score to 0 after the game
    mutating func resetScore() {
        winner = .none
        YellowScore = 0
        RedScore = 0
        model.reset()
    }
    
    // Empties the grid and resets the winner so that the other player can start
    mutating func resetGrid() {
        let resetCols = Array(repeating: Coin.white, count: cols)
        gameGrid = Array(repeating: resetCols, count:rows)
        winner = .none
        stalemateview = false
        isFirstMove = true
    }
    
    // Handles all actions the model wants to perform
    mutating func modelAction() {
        let column = Int.random(in: 0..<cols)
        var modelAction : (String, Int) = ("random",column)
        let possibleStrategies = getStrategies()
        let currentChunk : Chunk = model.generateNewChunk()
        
        model.modifyLastAction(slot: "ISA", value: "possibilities")
        currentChunk.setSlot(slot: "ISA", value: "scenario")
        for strategy in Strategy.allCases {
            model.modifyLastAction(slot:strategy.strategyString, value: "nil")
            currentChunk.setSlot(slot: strategy.strategyString, value: "nil")
        }
         for strategy in possibleStrategies{
            model.modifyLastAction(slot: strategy.0, value: "true")
            currentChunk.setSlot(slot: strategy.0, value: "true")
        }
        
        model.run()
        
        // Decay and latency are adjusted in order to improve the retrieval of the first move
        model.dm.baseLevelDecay = 0.1
        model.dm.latencyFactor = 0.1
        
        if isFirstMove {
            modelAction = ("firstMove", getFirstMoveStrategy())
        }
        else {
            var strategiesChoice : [(String,Int)] = []
            for strategy in possibleStrategies {
                if strategy.0 == model.lastAction(slot: "decision"){
                    strategiesChoice.append(strategy)
                }
            modelAction = strategiesChoice.randomElement() ?? ("randomColumn", Int.random(in: 0..<cols))
            currentChunk.setSlot(slot: "decision", value: modelAction.0)
            }
            if let dmchunk = model.dm.retrieve(chunk: currentChunk).1{
                modelStrategies.append(dmchunk)
            }
        }
        
        insertCoin(at: modelAction.1)
    }
    
    // Inserts a coin with ontapgesture if its the human player's turn and refers to modelAction() when it is the model's turn
    mutating func insertCoin(at selectedCol:Int) {
        // insert coin at lowest available location in column of grid
        let row = lowestLocation(selectedCol)
        guard row != 100 else { print("Can't insert coin here") ; return }
        gameGrid[row][selectedCol] = player.player_item
        
        if isFirstMove{
            firstMove = selectedCol
            firstPlayer = player
        }
        
        isFirstMove = false
        
        if checkWinning(row: row, column: selectedCol) {
            winner = player
            
            saveFirstMove(firstMove, firstPlayer, winner)
            
            if winner.color == .yellow { YellowScore += 1 }
            else if winner.color == .red { RedScore += 1 }
        }
            
        model.time += 0.5
        
        // Check full board -> stalemate
        var stalemate : Bool = true
        for col in 0..<cols{
            if lowestLocation(col) != 100 {
                stalemate = false
                break
            }
        }
        if stalemate {stalemateview = true}
        
        player.toggle()
    }
    
    //gets possible strategies with checkSequentials
    func getStrategies() -> [(String,Int)]{
        var strategies = [(String,Int)]()
        for column in 0..<cols{
            let row = lowestLocation(column)
            if row != 100 {
                let opponentsequentials = checkSequentials(row: lowestLocation(column), column: column, currentPlayerColor: .red)
                let sequentials = checkSequentials(row: lowestLocation(column), column: column, currentPlayerColor: player.color)
                
                if sequentials.contains(4) {strategies.append(("complete4",column))}
                if sequentials.contains(3) {strategies.append(("complete3",column))}
                if sequentials.contains(2) {strategies.append(("complete2",column))}
                
                if opponentsequentials.contains(4) {strategies.append(("block4",column))}
                if opponentsequentials.contains(3) {strategies.append(("block3",column))}
                if opponentsequentials.contains(2) {strategies.append(("block2",column))}
            }
        }
        return strategies
    }

    // Strategy for placement of first coin by the model
    mutating func getFirstMoveStrategy() -> Int {
        let startMoveChunk:Chunk = model.generateNewChunk()
        startMoveChunk.setSlot(slot:"ISA", value:"startMoveChunk")
        if let chunk = model.dm.retrieve(chunk: startMoveChunk).1{
            var firstStrategyColString : Double
            firstStrategyColString = chunk.slotValue(slot: "firstSelectedColumn")?.number() ?? Double(firstStrategyCol)
            firstStrategyCol = Int(firstStrategyColString)
        }
        return firstStrategyCol
    }

    
    // Save the first coin placement of a round
    func saveFirstMove (_ column: Int, _ firstPlayer: Player, _ winner: Player) {
        if firstPlayer == winner {
            let startMoveChunk : Chunk = model.generateNewChunk()
            startMoveChunk.setSlot(slot: "ISA", value: "startMoveChunk")
            startMoveChunk.setSlot(slot: "firstSelectedColumn", value: String(column))
            
            model.dm.addToDM(startMoveChunk)
        }
    }

    
    // Gets the lowest open hole where a new coin can be placed
    func lowestLocation(_ col:Int) -> Int {
        // find final position for coin played in a specific column
        for row in stride(from: rows-1, to: -1, by:-1){
            let coin = gameGrid[row][col]
            if coin == .white {
                return row
            }
        }
        return 100 // Prevents coin placement when column is full
    }
    
    // Make initial fixed activation for each strategy before the game begins
    func makeInitialActivation (strategy: String, initialActivation: Double) {
        
        let outcomeArray = ["true", "nil"]
        let strategyArray = ["complete2", "complete3", "complete4", "block2", "block3", "block4"]

        // Combination of all possible strategies, with all possible outcomes and decisions
        for outcome1 in outcomeArray{
            for outcome2 in outcomeArray{
                for outcome3 in outcomeArray{
                    for outcome4 in outcomeArray{
                        for outcome5 in outcomeArray{
                            
                            let filteredStrategyArray = strategyArray.filter { $0 != strategy }
                            let initialChunk : Chunk = model.generateNewChunk()
                            
                            initialChunk.setSlot(slot: "ISA", value: "scenario")
                            initialChunk.setSlot(slot: filteredStrategyArray[0], value: outcome1)
                            initialChunk.setSlot(slot: filteredStrategyArray[1], value: outcome2)
                            initialChunk.setSlot(slot: filteredStrategyArray[2], value: outcome3)
                            initialChunk.setSlot(slot: filteredStrategyArray[3], value: outcome4)
                            initialChunk.setSlot(slot: filteredStrategyArray[4], value: outcome5)
                            initialChunk.setSlot(slot: strategy, value: "true") // set one decision to true and take that as the strategy
                            initialChunk.setSlot(slot: "decision", value: strategy)
                            
                            initialChunk.fixedActivation = initialActivation
                            
                            model.dm.addToDM(initialChunk)
                        }
                    }
                }
            }
        }
    }
    
    // Checkwinning now uses checksequentials to see if there is 4 in a row anywhere
    mutating func checkWinning (row:Int, column:Int) -> Bool {
        let currentPlayerColor = gameGrid[row][column].color
        if checkSequentials(row: row, column:column, currentPlayerColor:currentPlayerColor).contains(4){
            if player.isModel{ updateActivation(win:true) }
            else {updateActivation(win:false)}
            return true
        }
        else { return false }
    }
    
    // Update the activation with each retrieval and change in the model. complete4, block4 and block3 will be reinforced more since they are more important decisions.
    mutating func updateActivation(win : Bool) {
        for (nr, dmchunk) in modelStrategies.enumerated() {
            var factor : Double
            let decision : String = dmchunk.slotValue(slot: "decision")!.text() ?? "empty"
            switch decision {
            case "complete4": factor = 2
            case "block4": factor = 2
            default: factor = 1
            }
            if dmchunk.fixedActivation == nil{
                dmchunk.fixedActivation = 1
            }
            if win{
                // Moves that occurred later in the game are reinforced more than moves in the early stages of the game
                dmchunk.fixedActivation! += 0.35 * factor * dmchunk.fixedActivation! * (1 + (Double(nr) / Double(modelStrategies.count)))
            }
            if !win{
                // Losing moves later in the game get an activation decrease
                dmchunk.fixedActivation! -= 0.1 * (1/factor) * dmchunk.fixedActivation! * (1+(Double(nr) / Double(modelStrategies.count)))
            }
        }
        self.modelStrategies.removeAll()
    }
    
    // Implements the Game Logic
    // CheckSequentials outputs an array of the different numbers of coins that are on a line from a certain position. Returns 2 and/or 3 and/or 4.
    func checkSequentials(row:Int, column:Int, currentPlayerColor:Color) -> [Int] {
        var sequentialCoins: Int = 1
        var sequentialsArray = [Int]()

        // check for horizontal 4 coin row
        if (column-1) >= 0 && currentPlayerColor == gameGrid[row][column-1].color {
            sequentialCoins += 1
            if (column-2) >= 0 && currentPlayerColor == gameGrid[row][column-2].color {
                sequentialCoins += 1
                if (column-3) >= 0 && currentPlayerColor == gameGrid[row][column-3].color{
                    sequentialCoins += 1
                }
                else if (column+1) <= cols-1 && currentPlayerColor == gameGrid[row][column+1].color {
                    sequentialCoins += 1
                }
            }
            else if (column+1) <= cols-1 && currentPlayerColor == gameGrid[row][column+1].color {
                sequentialCoins += 1
                if (column+2) <= cols-1 && currentPlayerColor == gameGrid[row][column+2].color{
                    sequentialCoins += 1
                }
            }
        }
        else if (column+1) <= cols-1 && currentPlayerColor == gameGrid[row][column+1].color {
            sequentialCoins += 1
            if (column+2) <= cols-1 && currentPlayerColor == gameGrid[row][column+2].color {
                sequentialCoins += 1
                if (column+3) <= cols-1 && currentPlayerColor == gameGrid[row][column+3].color{
                    sequentialCoins += 1
                }
            }
        }

        // Add the amount of sequentials to an array
        sequentialsArray.append(sequentialCoins)
        sequentialCoins = 1
        
        // check for vertical 4 coin row
        if (row-1) >= 0 && currentPlayerColor == gameGrid[row-1][column].color {
            sequentialCoins += 1
            if (row-2) >= 0 && currentPlayerColor == gameGrid[row-2][column].color {
                sequentialCoins += 1
                if (row-3) >= 0 && currentPlayerColor == gameGrid[row-3][column].color{
                    sequentialCoins += 1
                }
                else if (row+1) <= rows-1 && currentPlayerColor == gameGrid[row+1][column].color {
                    sequentialCoins += 1
                }
            }
            else if (row+1) <= rows-1 && currentPlayerColor == gameGrid[row+1][column].color {
                sequentialCoins += 1
                if (row+2) <= rows-1 && currentPlayerColor == gameGrid[row+2][column].color{
                    sequentialCoins += 1
                }
            }
        }
        else if (row+1) <= rows-1 && currentPlayerColor == gameGrid[row+1][column].color {
            sequentialCoins += 1
            if (row+2) <= rows-1 && currentPlayerColor == gameGrid[row+2][column].color {
                sequentialCoins += 1
                if (row+3) <= rows-1 && currentPlayerColor == gameGrid[row+3][column].color{
                    sequentialCoins += 1
                }
            }
        }

        // Add sequentials to array, only if the number isn't in there yet
        if !sequentialsArray.contains(sequentialCoins) {
            sequentialsArray.append(sequentialCoins)
        }
        sequentialCoins = 1
        
        // check for descending diagonal 4 coin in a row
        if ((row-1) >= 0 && (column-1) >= 0) && currentPlayerColor == gameGrid[row-1][column-1].color {
            sequentialCoins += 1
            if ((row-2) >= 0 && (column-2) >= 0) && currentPlayerColor == gameGrid[row-2][column-2].color {
                sequentialCoins += 1
                if ((row-3) >= 0 && (column-3) >= 0) && currentPlayerColor == gameGrid[row-3][column-3].color{
                    sequentialCoins += 1
                }
                else if ((row+1) <= rows-1 && (column+1) <= cols-1) && currentPlayerColor == gameGrid[row+1][column+1].color {
                        sequentialCoins += 1
                }
            }
            else if ((row+1) <= rows-1 && (column+1) <= cols-1)  && currentPlayerColor == gameGrid[row+1][column+1].color {
                sequentialCoins += 1
                if ((row+2) <= rows-1 && (column+2) <= cols-1)  && currentPlayerColor == gameGrid[row+2][column+2].color{
                    sequentialCoins += 1
                }
            }
        }
        else if ((row+1) <= rows-1 && (column+1) <= cols-1) && currentPlayerColor == gameGrid[row+1][column+1].color {
            sequentialCoins += 1
            if ((row+2) <= rows-1 && (column+2) <= cols-1) && currentPlayerColor == gameGrid[row+2][column+2].color {
                sequentialCoins += 1
                if ((row+3) <= rows-1 && (column+3) <= cols-1) && currentPlayerColor == gameGrid[row+3][column+3].color{
                    sequentialCoins += 1
                }
            }
        }

        // Add sequentials to array, only if the number isn't in there yet
        if !sequentialsArray.contains(sequentialCoins) {
            sequentialsArray.append(sequentialCoins)
        }
        sequentialCoins = 1

        // check for ascending diagonal 4 coin in a row
        if ((row+1 <= rows-1) && (column-1 >= 0)) && currentPlayerColor == gameGrid[row+1][column-1].color {
            sequentialCoins += 1
            
            if ((row+2 <= rows-1) && (column-2 >= 0)) && currentPlayerColor == gameGrid[row+2][column-2].color {
                sequentialCoins += 1
                
                if ((row+3 <= rows-1) && (column-3 >= 0)) && currentPlayerColor == gameGrid[row+3][column-3].color{
                    sequentialCoins += 1
                }
                else if ((row-1 >= 0) && (column+1 <= cols-1)) && currentPlayerColor == gameGrid[row-1][column+1].color {
                    sequentialCoins += 1
                }
            }
            else if ((row-1 >= 0) && (column+1 <= cols-1))  && currentPlayerColor == gameGrid[row-1][column+1].color {
                sequentialCoins += 1
                if ((row-2 >= 0) && (column+2 <= cols-1))  && currentPlayerColor == gameGrid[row-2][column+2].color{
                    sequentialCoins += 1
                }
            }
        }
        else if ((row-1 >= 0) && (column+1 <= cols-1)) && currentPlayerColor == gameGrid[row-1][column+1].color {
            sequentialCoins += 1
            if ((row-2 >= 0) && (column+2 <= cols-1)) && currentPlayerColor == gameGrid[row-2][column+2].color {
                sequentialCoins += 1
                if ((row-3 >= 0) && (column+3 <= cols-1)) && currentPlayerColor == gameGrid[row-3][column+3].color{
                    sequentialCoins += 1
                }
            }
        }
        
        // Add sequentials to array, only if the number isn't in there yet
        if !sequentialsArray.contains(sequentialCoins) {
            sequentialsArray.append(sequentialCoins)
        }
        return sequentialsArray
    }
}


