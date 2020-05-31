//
//  VideoListView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 30/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI

struct VideoListView: View {
        
    @ObservedObject var viewModel: VideoListViewModel
    
    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.state.isLoading),
                    message: .constant(NSLocalizedString("Loading", comment: ""))) {
            List {
                self.content
            }
        }
        .navigationBarTitle("Videos")
        .onAppear() {
            self.viewModel.fetchVideos()
        }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .loading:
            return AnyView(EmptyView()).id("LoadingView")
        case .error(let error):
            return AnyView(
                Text(error.localizedDescription)
                    .foregroundColor(.gray)
            ).id("ErrorView")
        case .ready(let rows):
            if rows.isEmpty {
                return AnyView(
                    Text("No videos")
                        .foregroundColor(.gray)
                ).id("EmptyView")
            }
            return AnyView(
                ForEach(rows, content: VideoListRowView.init(viewModel:))                
            ).id("ListView")
        }
    }
}
