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
                    self.videoPreviewButton
                    self.titleView
                    self.descriptionView
                }
            }.padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: trailingBarItem)
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("video-detail.error-title"),
                  message: Text(viewModel.errorMessage ?? NSLocalizedString("video-detail.error-default-message",
                                                                            comment: "")))
        }
    }
    
    private var titleView: some View {
        Text(viewModel.title)
            .font(.title)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionView: some View {
        Text(viewModel.description)
            .foregroundColor(.gray)
            .font(.body)
            .padding([.top, .bottom])
    }
    
    private var videoPreviewButton: some View {
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
    }
    
    private var trailingBarItem: some View {
        // There's a weird SwiftUI bug when changing the bar item contents:
        // https://stackoverflow.com/questions/61915629/swiftui-navigationbaritem-showing-in-strange-position-after-showing-a-different
        Group {
            if viewModel.downloadAvailable {
                if self.viewModel.downloadState.isDownloading {
                    self.progressBar
                } else if self.viewModel.downloadState.isDownloaded {
                    self.eraseVideoButton
                } else {
                    self.downloadVideoButton
                }
            }
        }
    }
    
    private var progressBar: some View {
        Button(action: {
            self.viewModel.cancelDownload()
        }) {
            HStack(spacing: 4) {
                Text("video-detail.cancel-download-button")
                ProgressBar(progress: self.$viewModel.progress)
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    private var eraseVideoButton: some View {
        Button(action: {
            self.viewModel.removeVideo()
        }) {
            Text("video-detail.delete-button")
                .foregroundColor(.red)
        }
    }
    
    private var downloadVideoButton: some View {
        Button(action: {
            self.viewModel.downloadVideo()
        }) {
            HStack {
                Text("video-detail.download-button")
                Image(systemName: "square.and.arrow.down")
            }
        }
    }
}
