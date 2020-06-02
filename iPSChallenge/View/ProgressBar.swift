//
//  ProgressBar.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 02/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI

/// From: https://www.simpleswiftguide.com/how-to-build-a-circular-progress-bar-in-swiftui/
struct ProgressBar: View {
    
    private let size: CGFloat = 16.0
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: size)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: size, lineCap: .butt, lineJoin: .miter))
                .opacity(0.7)
                .foregroundColor(.gray)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}
