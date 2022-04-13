//
//  Model_4InARow.swift
//  4InARow
//
//  Created by Helena on 21.02.22.
//

import Foundation
import SwiftUI

struct CoinGame<CoinType> {
    private(set) var coins: Array<Coin>
    
    mutating func choose(_ coin: Coin) {
        if let chosenIndex = coins.firstIndex(where: {$0.id == coin.id}),
           coins[chosenIndex].isSelected {
            coins[chosenIndex].isSelected.toggle()
        }

    }
    
 
    
    init (numberOfCoins: Int) {
        
        coins = Array<Coin>()
        
        for Index in 0..<numberOfCoins {
            coins.append(Coin(id: Index))
        }
    }
 
    
     // maybe delete this
    struct Coin: Identifiable {
        var isSelected = false // is clicked means that it was touched and therefore colored in
        let isPlayer: Int = 1 // which player
        let id: Int
        // let row: Int
        // let colum: Int
    }
    
    func coinColor(_ player: Int) -> Color {
        if player == 1 {
            return Color.red
        } else {
            return Color.yellow
        }
    }
}
