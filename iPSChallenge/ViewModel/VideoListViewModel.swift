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

    enum State: Equatable {
        case uninitialized
        case loading
        case error(Error)
        case ready([VideoListRowViewModel])
        
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
        
        static func == (lhs: VideoListViewModel.State, rhs: VideoListViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.uninitialized, .uninitialized):
                return true
            case (.loading, .loading):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError as NSError == rhsError as NSError
            case (.ready(let lhsRows), .ready(let rhsRows)):
                return lhsRows == rhsRows
            default:
                return false
            }
        }
    }
    
    @Published var state: State = .uninitialized
    
    private let provider: MoyaProvider<iPSService>
    private var disposables = Set<AnyCancellable>()
    
    init(provider: MoyaProvider<iPSService> = MoyaProvider<iPSService>(plugins: [MoyaCachePlugin()])) {
        self.provider = provider
    }
    
    func fetchVideos() {
        state = .loading
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
                    Log.debug("Error fetching /videos endpoint: \(error)")
                }
            }, receiveValue: { [weak self] videos in
                self?.state = .ready(videos.map { VideoListRowViewModel(video: $0) })
            })
            .store(in: &disposables)
    }
}

