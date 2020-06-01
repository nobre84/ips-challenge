//
//  VideoDetailView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 30/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct VideoDetailView: View {
    @ObservedObject var viewModel: VideoDetailViewModel
    @State private var isPlaying = false
    
    private let maxHeight: CGFloat = 226
    private let playIconSize: CGFloat = 30
    
    init(viewModel: VideoDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Button(action: {
                        self.isPlaying = true
                    }) {
                        ZStack {
                            WebImage(url: self.viewModel.thumbnail)
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .frame(height: maxHeight)
                                .cornerRadius(4)
                            Image(systemName: "play.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: playIconSize, height: playIconSize)
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $isPlaying) {
                        PlayerView(videoURL: self.viewModel.videoLink)
                            .edgesIgnoringSafeArea(.all)
                    }
                    Text(viewModel.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(viewModel.description)
                        .foregroundColor(.gray)
                        .font(.body)
                        .padding([.top, .bottom])
                }
            }.padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: downloadVideoButton)
    }
    
    private var downloadVideoButton: some View {
        Button(action: {
            print("Download video")
        }) {
            HStack {
                Text("video-detail.download-button")
                Image(systemName: "square.and.arrow.down")
            }
        }
    }
}
