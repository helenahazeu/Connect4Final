//
//  ConnectFourViewModel.swift
//  View Model
//
//  Created by Helena on 21.02.22.
//

import SwiftUI

//The ViewModel handles all communication between View and Model. All properties that the View needs to use are exposed in this class. The functions that are implemented here have the same name as their counterparts in the ConnectFourModel.swift file. They are exposed as instances of the structs in the ConnectFourModel.swift file.
class Connect4ViewModel: ObservableObject {
    
    private let cols = 7
    private let rows = 6
    
    private static func createConnectFourGame() -> Connect4Model {
        return Connect4Model()    }
    
    @Published private var gamemodel = createConnectFourGame()
    
    var player: Player {
        return gamemodel.player
    }
    
    var winner: Player {
        return gamemodel.winner
    }
    
    var gamegrid: [[Coin]] {
        return gamemodel.gameGrid
    }
    
    var stalemateview: Bool {
        return gamemodel.stalemateview
    }
    
    // MARK: - User's Intent(s)
    
    func insertCoin(at selectedCol:Int) {
        
        if gamemodel.winner == .none && gamemodel.stalemateview == false {
            
            gamemodel.insertCoin(at: selectedCol)
       
            if gamemodel.player.isModel && gamemodel.winner == .none {
                let seconds0 = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds0){
                    self.modelAction()
                }}
            
            
        } else if gamemodel.winner != .none && gamemodel.stalemateview == false {
            if gamemodel.winner.isModel {
                self.resetGrid()
            } else {
                self.resetGrid()
                    
                let seconds0 = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds0){
                    self.modelAction()
                }
            }
        } else {
            if gamemodel.player.isModel {
                self.resetGrid()
                
            } else {
                self.resetGrid()
                
                let seconds0 = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds0){
                    self.modelAction()
                }
            }
        }
    }
    
    func modelAction () {
        gamemodel.modelAction()
    }
  
    
    func resetGrid() {
        gamemodel.resetGrid()
    }
    
    func resetScore() {
        gamemodel.resetScore()
    }
    
    func getColor(row:Int, column:Int) -> Color{
        gamemodel.getColor(row: row, column: column)
    }
    
    func getScore(currentPlayer: Player) -> Int{
        gamemodel.getScore(currentPlayer: currentPlayer)
    }
}
