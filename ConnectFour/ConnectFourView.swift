//
//  ConnectFourView.swift
//  View
//
//  Created by J. Bruin on 22/02/2022.


import SwiftUI

// Start Screen and navigation to subviews
struct Connect4View: View {
    
    @ObservedObject var game: Connect4ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    static let columns = [0, 1, 2, 3, 4, 5, 6] // x coordinates
    static let rows = [0, 1, 2, 3, 4, 5] // y coordinates (0 at the top)
    
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundColor.edgesIgnoringSafeArea(.all)
                VStack{
                    Spacer()
                    Text("Welcome to").foregroundColor(.white).font(.title)
                    Text("Connect4").foregroundColor(.white).font(Font.custom("Phosphate", size: 45, relativeTo: .largeTitle)).padding(.bottom)
                    Text("Press 'Start Game' to start playing").foregroundColor(.white).italic()
                    Spacer()
                    NavigationLink(destination: GamePlayView(game:game)){
                        Text("Start Game").foregroundColor(.white).bold()
                    }
                    NavigationLink(destination: SettingsView (game: game)){
                        Text("Settings").foregroundColor(.white).bold()
                    }
                    NavigationLink(destination: HowToView(game: game)){
                        Text("How to play").foregroundColor(.white).bold()
                    }
                    NavigationLink(destination: AppInfoView(game: game)) {
                        Text("App info").foregroundColor(.white).bold()
                    }
                    Spacer()
                }
            }
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// Game view, game board, title, winning message views put together. Handles landscape/portrait mode
struct GamePlayView: View {
    @ObservedObject var game: Connect4ViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "house")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
        }
    }
    
    var refreshButton : some View {
        Button(action: {
        self.game.resetGrid()
        self.game.resetScore()
        }) {
            Image(systemName: "gobackward")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        
        let screenwidth = UIScreen.main.bounds.width
        let screenheight = UIScreen.main.bounds.height
        
            if screenwidth > screenheight{
                // landscape mode
                ZStack {
                    if game.winner == .none {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundColor(.BackgroundColor)
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundColor(game.winner.color)
                    }
                    HStack{
                        Spacer()
                        VStack{
                            Spacer()
                            TitleView(game:game).padding(10)
                            Spacer()
                            HStack{
                                Spacer()
                                ScoreView(game:game)
                                Spacer()
                            }
                            Spacer()
                            TurnView(game:game)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            ZStack {
                                GameboardView(game:game).padding(20)
                                if game.winner != .none {
                                    PlayAgainView(game:game)
                                        .contentShape(Rectangle())
                                } else if game.stalemateview {
                                    PlayAgainView(game:game)
                                        .contentShape(Rectangle())
                                }
                            }
                            Spacer()
                        }
                        
                        Spacer()
                    }
                        
                    }.edgesIgnoringSafeArea([.all])
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: refreshButton)
                    .navigationBarItems(leading: backButton)
                }
            else {
                // portrait mode
                ZStack {
                    if game.winner == .none {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundColor(.BackgroundColor)
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundColor(game.winner.color)
                    }
                    VStack{
                        Spacer()
                        TitleView(game:game).padding(5)
                        Spacer()
                        ScoreView(game:game)
                        Spacer()
                        if game.winner != .none {
                            ZStack {
                                GameboardView(game:game).padding()
                                PlayAgainView(game:game)
                                    .contentShape(Rectangle())
                                    .frame(width: 400, height: 70)
                            }
                        } else if game.stalemateview {
                            ZStack {
                                GameboardView(game:game).padding()
                                PlayAgainView(game:game)
                                    .contentShape(Rectangle())
                                    .frame(width: 400, height: 70)
                            }
                        } else {
                            ZStack {
                                PlayAgainView(game:game)
                                    .contentShape(Rectangle())
                                    .frame(width: 400, height: 70)
                                    .opacity(0)
                                GameboardView(game:game).padding()
                            }
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            TurnView(game:game)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea([.top, .bottom])
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: backButton)
                .navigationBarItems(trailing: refreshButton)
            }
    }
}

// Controls appearance of how to page in the navigation
struct HowToView: View {
    @ObservedObject var game: Connect4ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "house")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
        }
    }

    var body: some View{
        ZStack {
            Rectangle().foregroundColor(.BackgroundColor)
            Text("Connect 4 Rules \n \n OBJECTIVE: \n\n To win you must be the first player to connect four same colored coins in a row (either horizontally, vertically, or diagonally) \n\n  HOW TO PLAY: \n\n Each player (or cognitive model) may drop only one coin into the grid in each turn and you and the ACT-R model alternate turns. \n When it is your turn, drop one of your red discs into any of the seven slots. \n The game ends when there is a 4-in-a-row or a stalemate. \n\n You can go back to the start screen at any time without losing your progress by clicking the house icon on the top left. By clicking on the reload symbol on the top right, you can restart the game, reset the scores and reset the model.")
                .padding(10)
                .font(.body)
                .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea([.all])
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

// App info page
struct AppInfoView: View {
    @ObservedObject var game: Connect4ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "house")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
        }
    }

    var body: some View{
        ZStack {
            Rectangle().foregroundColor(.BackgroundColor)
            Text("This game was developed by Gijs, Helena and Juliette")
                .padding(10)
                .font(.body)
                .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea([.all])
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

// Settings page
struct SettingsView: View {
    @ObservedObject var game: Connect4ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var backButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "house")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
        }
    }

    var body: some View{
        ZStack {
            Rectangle().foregroundColor(.BackgroundColor)
            Text("Sorry, your settings cannot be changed")
                .padding(10)
                .font(.body)
                .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea([.all])
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}


// Title
struct TitleView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View{
        Text("Connect4").foregroundColor(.white)
            .font(Font.custom("Phosphate", size: 45, relativeTo: .title))
    }
}

// Reset button on the top
struct ResetView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View{
        Menu {
            Button(action:{
                self.game.resetGrid()
                self.game.resetScore()
            }) {Label("Restart game", systemImage: "gobackward")}
        }
        label: {Label("Connect4", systemImage: "list.bullet.circle").foregroundColor(.white).font(.title)}
    }
    
}

// View that appears after winning and prompts the user to click somewhere to start playing again
struct PlayAgainView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View {
        Text("Click gameboard to play again!")
            .foregroundColor(.white)
            .font(.title2)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
            .foregroundColor(.BackgroundColor)
            .opacity(0.8)
            .shadow(color: .black.opacity(0.5), radius: 10, x: 10, y: 10)
            .shadow(color: .black.opacity(0.5), radius: 10, x: 10, y: -1)
    }
}
        

// Winning message
struct WinningMessageView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View {
        VStack {
            if game.winner == .yellow {
                VStack (spacing: -5) {
                    Image(systemName: "bolt.square")
                        .foregroundColor(.white)
                        .font(.system(size: 70))
                    Text("The model won!")
                        .font(.title2)
                        .frame(width: 200, height: 35)
                        .border(Color.yellow, width: 4)
                        .foregroundColor(.white)
                }
          
            } else if game.winner == .red {
                Image(systemName: "person.crop.square")
                    .foregroundColor(.white)
                    .font(.system(size: 70))
                Text("You won!")
                    .font(.title2)
                    .frame(width: 200, height: 35)
                    .border(Color.red, width: 4)
                    .foregroundColor(.white)
            }
        }
    }
            
}

// Stalemate View
struct StalemateMessageView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View {
        VStack {
            VStack (spacing: -5) {
                Image(systemName: "x.square")
                    .foregroundColor(.white)
                    .font(.system(size: 70))
                Text("Stalemate!")
                    .font(.title2)
                    .frame(width: 200, height: 35)
                    .border(Color.BackgroundColor, width: 4)
                    .foregroundColor(.white)
            }
        }
    }
    
}


// Constructs game board of 7x6 and handles the ontapgesture to insert a new coin
struct GameboardView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View{
        ZStack {
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .foregroundColor(.BackgroundColor)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 10, y: 10)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 10, y: -1)
            
            HStack{
                ForEach(Array(zip(Connect4View.columns.indices, Connect4View.columns)), id: \.1){index, column in
                        VStack{
                            ForEach(Array(zip(Connect4View.rows.indices, Connect4View.rows)), id: \.1){index, row in
                                let coinColor: Color = game.getColor(row: row, column: column)
                                    GeometryReader { coinGeometry in
                                        ZStack{
                                            Circle().fill(coinColor).padding(1.5)
                                            if coinColor == .yellow {
                                                Circle()
                                                .foregroundColor(.YellowCoinColor)
                                                .padding(5.5)
                                            } else if coinColor == .red {
                                                Circle()
                                                .foregroundColor(.RedCoinColor)
                                                .padding(5.5)
                                            }
                                            Circle().fill(coinColor).padding(7.5)
                                        }
                                    
                                    }
                            }
                        }
                        .onTapGesture{
                            self.game.insertCoin(at: column)
                                                        
                        }
                }
            }.padding(1.5)
        }.aspectRatio(1.25, contentMode: .fit)
    }
}

// Turn message at the bottom that prompts the user to insert the next coin
struct TurnView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View{
        if game.winner == .none {
                if game.player.isModel == true {
                    Text("It is the model's turn")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(width: 230, height: 45)
                        .background(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(game.player.color)
                    
                } else if game.player.isModel == false {
                    Text("It is your turn!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(width: 230, height: 45)
                        .background(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(game.player.color)
                }
        
        } else {
            Text("There is no turn")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(10)
                .frame(width: 230, height: 45)
                .background(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.blue)
                .opacity(0)
        }
    }
}

// Shows scores and icons of players at the top
struct ScoreView: View {
    @ObservedObject var game: Connect4ViewModel
    
    var body: some View{
        if game.winner == .none && game.stalemateview == false {
            VStack{
                HStack{
                    Spacer()
                    VStack (spacing: -5) {
                        Image(systemName: "bolt.square")
                            .foregroundColor(.yellow)
                            .font(.system(size: 71))
                        Text("\(game.getScore(currentPlayer: .yellow))")
                            .font(.title2)
                            .frame(width: 66, height: 35)
                            .border(Color.yellow, width: 4)
                            .foregroundColor(.white)
                            .cornerRadius(6).padding(.top, 10)
                    }
                    Spacer()
                    VStack (spacing: -5) {
                        Image(systemName: "person.crop.square")
                            .foregroundColor(.red)
                            .font(.system(size: 70))
                        Text("\(game.getScore(currentPlayer: .red))")
                            .font(.title2)
                            .frame(width: 66, height: 35)
                            .border(Color.red, width: 4)
                            .foregroundColor(.white)
                            .cornerRadius(6).padding(.top, 10)
                    }
                    Spacer()
                }
            }
        } else {
            WinningMessageView(game:game)
        }
        
        if game.stalemateview {
            StalemateMessageView(game:game)
        }
        
    }
}


// Drawing constants
struct DrawingConstants {
     static let cornerRadius: CGFloat = 20
 }


// Handles previews
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let game = Connect4ViewModel()
        Connect4View(game: game)
            .previewInterfaceOrientation(.portrait)
    }
}



// Color extension for darkmode
extension Color {
    static let RedCoinColor = Color("RedCoin")
    static let YellowCoinColor = Color("YellowCoin")
    static let BackgroundColor = Color("Background")
}
