//
//  ConnectFourApp.swift
//  App
//
//  Created by Helena on 21.02.22.
//

import SwiftUI

@main
struct ConnectFourApp: App {
    let game = Connect4ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Connect4View(game: game)
        }
    }
}
