/*
    Copyright (C) 2017 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A simple struct that holds information about an Asset.
 */

import AVFoundation

struct Asset {
    
    /// The name of the Asset.
    let id: String
    
    /// The AVURLAsset corresponding to this Asset.
    let urlAsset: AVURLAsset
}

/// Extends `Asset` to conform to the `Equatable` protocol.
extension Asset: Equatable {}

func ==(lhs: Asset, rhs: Asset) -> Bool {
    return (lhs.id == rhs.id) && (lhs.urlAsset == rhs.urlAsset)
}


/**
 Extends `Asset` to add a simple download state enumeration used by the sample
 to track the download states of Assets.
 */
extension Asset {
    enum DownloadState: String {
        
        /// The asset is not downloaded at all.
        case notDownloaded
        
        /// The asset has a download in progress.
        case downloading
        
        /// The asset is downloaded and saved on diek.
        case downloaded
    }
}


/**
 Extends `Asset` to define a number of values to use as keys in dictionary lookups.
 */
extension Asset {
    enum Keys: String, Hashable {
        /**
         Key for the Asset name, used for `AssetDownloadProgressNotification` and
         `AssetDownloadStateChangedNotification` Notifications as well as
         AssetListManager.
         */
        case id
        
        /**
         Key for the Asset download percentage, used for
         `AssetDownloadProgressNotification` Notification.
         */
        case percentDownloaded
        
        /**
         Key for the Asset download state, used for
         `AssetDownloadStateChangedNotification` Notification.
         */
        case downloadState
        
        /**
         Key for the Asset download AVMediaSelection display Name, used for
         `AssetDownloadStateChangedNotification` Notification.
         */
        case downloadSelectionDisplayName
        
        /**
         Key for the Asset download Error reporting for
         `AssetDownloadStateChangedNotification` Notification.
         */
        case error
    }
}
