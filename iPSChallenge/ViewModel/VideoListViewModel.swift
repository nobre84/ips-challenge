//
//  VideoListViewModel.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 31/05/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import Foundation
import Combine
import Moya

class VideoListViewModel: ObservableObject, Identifiable {

    enum State {
        
        case loading
        case error(Error)
        case ready([Video])
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
        
        var error: Error? {
            if case .error(let error) = self {
                return error
            }
            return nil
        }
    }
    
    @Published var state: State = .loading
    
    private let provider: MoyaProvider<iPSService>
    private var disposables = Set<AnyCancellable>()
    
    init(provider: MoyaProvider<iPSService> = MoyaProvider<iPSService>()) {
        self.provider = provider
    }
    
    func fetchVideos() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        provider.requestPublisher(.videos)
            .filterSuccessfulStatusAndRedirectCodes()
            .print()
            .map(\.data)
            .decode(type: VideoListResponse.self, decoder: decoder)
            .map(\.videos)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.state = .error(error)
                    print(error)
                }
            }, receiveValue: { [weak self] videos in
                self?.state = .ready(videos)
            })
            .store(in: &disposables)
    }
}

