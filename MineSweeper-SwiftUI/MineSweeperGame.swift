//
//  MineSweeperGame.swift
//  MineSweeper-SwiftUI
//
//  Created by Joshua Homann on 12/7/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit

class MineSweeperGame: ObservableObject {
  @Published var gameState: GameState  = .playing

  struct Square {
    enum Contents: Equatable {
      case bomb, empty(Int)
    }
    enum Visibility {
      case flagged, covered, visible
    }
    var visibility: Visibility
    var contents: Contents
  }

  enum GameState {
    case playing, won, lost
    var isOver: Bool { self != .playing }
  }

  let dimension: Int

  private var squares: [Square] = []
  private let adjacentOffsets: [(Int, Int)] = (-1...1).flatMap {x in (-1...1).map { y in (x,y)}}
    .filter {(x,y) in !(x == 0 && y == 0)}
  private let bombCount: Int

  init(dimension: Int, bombCount: Int) {
    self.dimension = dimension
    self.bombCount = bombCount
    self.reset()
  }

  private func show(x: Int, y: Int) {
    guard x >= 0 && y >= 0 && x < dimension && y < dimension else {
      return
    }
    let index = self.index(x: x, y: y)
    guard squares[index].visibility == .covered else {
      return
    }
    squares[index].visibility = .visible
    guard case let .empty(count) = squares[index].contents, count == 0 else {
      return
    }
    adjacentOffsets.map {i,j in (i+x, j+y)}.forEach {(x, y) in self.reveal(x: x, y: y)}
  }

  private func index(x: Int, y: Int) -> Int { x+y*dimension }

  func flag(x: Int, y: Int) {
    switch squares[index(x: x, y: y)].visibility {
    case .visible:
      return
    case .covered:
      squares[index(x: x, y: y)].visibility = .flagged
    case .flagged:
      squares[index(x: x, y: y)].visibility = .covered
    }
    let temp = gameState
    gameState = temp
  }

  func reveal(x: Int, y: Int) {
    show(x: x, y: y)
    gameState = {
      var won = true
      for index in (0..<dimension*dimension) {
        if squares[index].contents == .bomb && squares[index].visibility == .visible {
          return .lost
        }
        if case .empty = squares[index].contents, squares[index].visibility != .visible{
          won = false
        }
      }
      return won ? .won : .playing
    }()
  }

  func reset() {
    gameState = .playing
    let shuffled = (0..<(dimension * dimension))
      .map { Square(visibility: .covered, contents: $0 < bombCount ? .bomb : .empty(0))}
      .shuffled()
    squares = shuffled.enumerated().map { index, element in
      if element.contents == .bomb {
        return element
      }
      let count = adjacentOffsets.map {(x,y) in (x + index % dimension, y + index / dimension)}
        .reduce(0) { result, coordinate in
          let (x, y) = coordinate
          guard (0..<dimension).contains(x), (0..<dimension).contains(y) else {
            return result
          }
          return result + (shuffled[x + y * dimension].contents == .bomb ? 1 : 0)
      }
      return Square(visibility: .covered, contents: .empty(count))
    }
  }

  subscript (x: Int, y: Int) -> Square {
    return squares[index(x: x, y: y)]
  }
}
