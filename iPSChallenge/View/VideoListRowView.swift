//
//  VideoListRowView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 30/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct VideoListRowView: View {
            
    @ObservedObject var viewModel: VideoListRowViewModel
    
    init(viewModel: VideoListRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationLink(destination: LazyView(VideoDetailView(viewModel: self.viewModel.detailViewModel))) {
            HStack {
                self.thumbnail
                Text(viewModel.title)
                    .font(.body)
            }
        }
    }
    
    private var thumbnail: some View {
        WebImage(url: viewModel.thumbnail)
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 54, height: 54)
            .cornerRadius(3)
    }
}
