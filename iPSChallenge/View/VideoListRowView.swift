//
//  VideoListRowView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 30/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI
import URLImage

struct VideoListRowView: View {
            
    @ObservedObject var viewModel: VideoListRowViewModel
    
    init(viewModel: VideoListRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            self.thumbnail
            Text(viewModel.title)
                .font(.body)
        }
    }
    
    private var thumbnail: some View {
        URLImage(viewModel.thumbnail,
                 processors: [ Resize(size: CGSize(width: 54, height: 54),
                                      scale: UIScreen.main.scale) ],
                 placeholder: { _ in
                    ActivityIndicator(isAnimating: .constant(true),
                                      style: .medium)
                },
                content:  {
                    $0.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .cornerRadius(2)
                })
            .frame(width: 54, height: 54)
    }
}
