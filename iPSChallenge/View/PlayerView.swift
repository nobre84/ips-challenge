//
//  PlayerViewController.swift
//  iPSChallenge
//
//  Created by Rafael Nobre on 01/06/20.
//  Copyright © 2020 Rafael Nobre. All rights reserved.
//

import UIKit
import AVKit
import SwiftUI

struct PlayerView: UIViewControllerRepresentable {
    
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.exitsFullScreenWhenPlaybackEnds = true
        
        controller.player = AVPlayer(url: videoURL)
        controller.player?.play()
        
        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {

    }
    
}
