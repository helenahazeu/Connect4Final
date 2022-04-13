//
//  Board_Model.swift
//  ConnectFour
//
//  Created by Helena on 01.03.22
//

//import Foundation
//import SwiftUI

//class connect4game : ObservableObject{
//    
//    private(set) var gameGrid = [[Coin]]()
//    private(set) var player: Player = .red
//    
//    private let cols = 7
//    private let rows = 6
//    
//    // create grid to locate coins
//    init() {
//        let initRow = Array(repeating: Coin.white, count: rows)
//        gameGrid = Array(repeating: initRow, count:cols)
//    }
//
//    
//    func insertCoin(at selectedCol:Int) -> Coin {
//        // insert coin at lowest available location in column of grid
//        let row = lowestLocation(selectedCol)
//        gameGrid[row!][selectedCol] = player.player_item
//        return player.player_item
//    }
//    
//    func lowestLocation(_ col:Int) -> Int? {
//        // find final position for coin played in a specific column
//        for row in stride(from: rows, to: 1, by:-1){
//            let coin = gameGrid[row][col]
//            if coin == .white {
//                return row
//            }
//        }
//        return nil //TODO: causes error when column is full
//    }
//    
//}


    



