//
//  GameView.swift
//  MineSweeper-SwiftUI
//
//  Created by Joshua Homann on 12/7/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI
import Combine

struct GameView: View {
  @ObservedObject var game: MineSweeperGame
  @State var squareSize: CGFloat = 0
  private enum Constant {
    static let boardMargin: CGFloat = 12
    static let squareSpacing: CGFloat = 4
    static let fontThreshold: CGFloat = 36
  }

  var body: some View {
    VStack(spacing: 0) {
      Text(self.makeTitle()).font(.largeTitle)
      GeometryReader { geometry in
        VStack(spacing: Constant.squareSpacing) {
          ForEach (0..<self.game.dimension) { y in
            HStack(spacing: Constant.squareSpacing) {
              ForEach (0..<self.game.dimension) { x in
                Text(self.makeLabel(x: x, y:y))
                   .font(self.squareSize < Constant.fontThreshold ? .body : .largeTitle)
                   .foregroundColor(Color.gray)
                .frame(
                  width: self.squareSize,
                  height: self.squareSize
                )
                .background(Color(self.boardColor(x: x, y: y)))
                .cornerRadius(Constant.squareSpacing)
                .onTapGesture {
                  self.game.reveal(x: x, y: y)
                }
                .onLongPressGesture {
                  self.game.flag(x: x, y: y)
                }
              }
            }
          }
        }.sideEffect {
          let geometry = geometry.frame(in: .local).size
          let minimumDimension = min(geometry.width, geometry.height)
          let dimension = CGFloat(self.game.dimension)
          let squareSize = (minimumDimension -  dimension * Constant.squareSpacing - 2 * Constant.boardMargin) / dimension
          DispatchQueue.main.async {
            self.squareSize = squareSize
          }
        }
      }
      Button(action: {
        self.game.reset()
      }, label: {
        Text("Reset").font(.largeTitle)
      })
    }
  }

  private func makeTitle() -> String  {
    switch game.gameState {
    case .lost:
      return "You lost!"
    case .won:
      return "You won!"
    case .playing:
      return " "
    }
  }

  private func boardColor(x: Int, y: Int) -> UIColor {
    switch game.gameState {
    case .lost:
      return .init(red: 1, green: 0.7, blue: 0.7, alpha: 1)
    case .won:
      return .init(red: 0.7, green: 1, blue: 0.7, alpha: 1)
    case .playing:
      switch game[x, y].visibility {
      case .visible:
        return .init(white: 0.95, alpha: 1)
      case .covered, .flagged:
        return .init(white: 0.90, alpha: 1)
      }
    }
  }

  private func makeLabel(x: Int, y: Int) -> String {
    func contents(square: MineSweeperGame.Square) -> String {
      switch square.contents {
      case .bomb:
        return "💣"
      case .empty(let count):
        return count == 0 ? " " : count.description
      }
    }
    guard !game.gameState.isOver else {
      return contents(square: game[x,y])
    }
    switch game[x,y].visibility {
    case .covered:
      return " "
    case .flagged:
      return "🎌"
    case .visible:
      return contents(square: game[x,y])
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    GameView(game: MineSweeperGame(dimension: 8, bombCount: 10))
  }
}

