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
    
    @Binding var progress: Float
    let stopHandler: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16.0)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 16.0, lineCap: .butt, lineJoin: .miter))
                .opacity(0.7)
                .foregroundColor(.gray)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Rectangle()
                .fill()
                .foregroundColor(.red)
        }.onTapGesture {
            self.stopHandler()
        }
    }
}
