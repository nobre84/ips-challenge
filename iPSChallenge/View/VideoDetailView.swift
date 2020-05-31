//
//  VideoDetailView.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 30/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import SwiftUI
import URLImage

struct VideoDetailView: View {
    @ObservedObject var viewModel: VideoDetailViewModel
        
        init(viewModel: VideoDetailViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.title)
                            .font(.title)
                        Text(viewModel.description)
                            .font(.body)
                            .padding([.top, .bottom])
                    }
                }.padding()
            }
        }
}
