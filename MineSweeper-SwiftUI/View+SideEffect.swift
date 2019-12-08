//
//  View+SideEffect.swift
//  MineSweeper-SwiftUI
//
//  Created by Joshua Homann on 12/8/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import SwiftUI

extension View {
  func sideEffect(_ sideEffect: @escaping () -> Void) -> some View {
    sideEffect()
    return self
  }
}
