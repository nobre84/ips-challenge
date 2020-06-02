/*
 `AssetPersistenceManager` is the main class in this sample that demonstrates how to manage downloading HLS streams.  
 It includes APIs for starting and canceling downloads, deleting existing assets off the users device, and monitoring 
 the download progress.
 This class can be copied to the application's code, and modified to fit particular needs. It was derived from Apple's
 "HLSCatalog" sample app, with minimal changes and fixes.
 
 When downloading a new asset, this implementation first downloads the main video in low resolution (265000bps), then 
 downloads all additional media selections (subtitles, audio). This logic SHOULD be customized to fit app needs.
 
 */

import Foundation
import AVFoundation

extension Notification.Name {
    /// Notification for when download progress has changed.
    static let assetDownloadProgressNotification: NSNotification.Name = NSNotification.Name(rawValue: "AssetDownloadProgressNotification")
    
    /// Notification for when the download state of an Asset has changed.
    static let assetDownloadStateChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "AssetDownloadStateChangedNotification")

    /// Notification for when AssetPersistenceManager has completely restored its state.
    static let assetPersistenceManagerDidRestoreStateNotification: NSNotification.Name = NSNotification.Name(rawValue: "AssetPersistenceManagerDidRestoreStateNotification")
}



class AssetPersistenceManager: NSObject {
    // MARK: Properties
    
    /// Singleton for AssetPersistenceManager.
    static let sharedManager = AssetPersistenceManager()
    
    /// Used to query if state restoring has been completed
    var isAvailable = false
    
    /// Internal Bool used to track if the AssetPersistenceManager finished restoring its state.
    private var didRestorePersistenceManager = false
    
    /// The AVAssetDownloadURLSession to use for managing AVAssetDownloadTasks.
    fileprivate var assetDownloadURLSession: AVAssetDownloadURLSession!
    
    /// Internal map of AVAssetDownloadTask to its corresponding Asset.
    fileprivate var activeDownloadsMap = [AVAggregateAssetDownloadTask : Asset]()
    
    /// Internal map of AVAggregateAssetDownloadTask to download URL.
    fileprivate var willDownloadToUrlMap = [AVAggregateAssetDownloadTask: URL]()
    
    // MARK: Intialization
    
    override private init() {
        
        super.init()
        
        // Create the configuration for the AVAssetDownloadURLSession.
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "AAPL-Identifier")
        
        // Create the AVAssetDownloadURLSession using the configuration.
        assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }
    
    /// Restores the Application state by getting all the AVAssetDownloadTasks and restoring their Asset structs.
    func restorePersistenceManager() {
        guard !didRestorePersistenceManager else { return }
        
        didRestorePersistenceManager = true
        
        // Grab all the tasks associated with the assetDownloadURLSession
        assetDownloadURLSession.getAllTasks { tasksArray in
            // For each task, restore the state in the app by recreating Asset structs and reusing existing AVURLAsset objects.
            for task in tasksArray {
                guard let assetDownloadTask = task as? AVAggregateAssetDownloadTask, let assetName = task.taskDescription else { break }
                
                let asset = Asset(id: assetName, urlAsset: assetDownloadTask.urlAsset)
                self.activeDownloadsMap[assetDownloadTask] = asset
            }
            
            self.isAvailable = true
            NotificationCenter.default.post(name: .assetPersistenceManagerDidRestoreStateNotification, object: nil)
            print("Manager restoration complete")
        }
    }
    
    /// Triggers the initial AVAssetDownloadTask for a given Asset.
    func downloadStream(for asset: Asset) {
        // Get the default media selections for the asset's media selection groups.
        let preferredMediaSelection = asset.urlAsset.preferredMediaSelection
        
        /*
         For the initial download, we ask the URLSession for an AVAssetDownloadTask
         with a minimum bitrate corresponding with one of the lower bitrate variants
         in the asset.
         */
        guard let task = assetDownloadURLSession.aggregateAssetDownloadTask(with: asset.urlAsset,
                                                       mediaSelections: [preferredMediaSelection],
                                                       assetTitle: asset.id,
                                                       assetArtworkData: nil,
                                                       options:
        [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]) else { return }
        
        // To better track the AVAssetDownloadTask we set the taskDescription to something unique for our sample.
        task.taskDescription = asset.id
        
        activeDownloadsMap[task] = asset
        
        task.resume()
        
        var userInfo = [Asset.Keys: Any]()
        userInfo[Asset.Keys.id] = asset.id
        userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading
        
        postUpdate(userInfo)
    }
    
    func assetFor(id: String, url: URL) -> Asset {
        // Downloading in progress asset
        if let asset = inflightAsset(withId: id) {
            return asset
        } else {
            // Already downloaded asset
            if let asset = localAsset(withId: id) {
                return asset
            } else {
                // Not downloaded asset
                let urlAsset = AVURLAsset(url: url)
                
                let asset = Asset(id: id, urlAsset: urlAsset)
                
                return asset
            }
        }
    }
    
    /// Returns an Asset given a specific name if that Asset is asasociated with an active download.
    func inflightAsset(withId id: String) -> Asset? {
        var asset: Asset?
        
        for (_, assetValue) in activeDownloadsMap {
            if id == assetValue.id {
                asset = assetValue
                break
            }
        }
        
        return asset
    }
    
    /// Returns an Asset pointing to a file on disk if it exists.
    func localAsset(withId id: String) -> Asset? {
        let userDefaults = UserDefaults.standard
        guard let localFileLocation = userDefaults.value(forKey: id) as? Data else {
            print("Not downloaded")
            return nil 
        }
        
        var asset: Asset?
        var bookmarkDataIsStale = false
        do {
            let url = try URL(resolvingBookmarkData: localFileLocation, bookmarkDataIsStale: &bookmarkDataIsStale)
            
            if bookmarkDataIsStale {
                throw "Bookmark data is stale!"
            }
            
            asset = Asset(id: id, urlAsset: AVURLAsset(url: url))
            
            return asset
        } catch  {
            print("Failed to create URL from bookmark with error: \(error)")
            userDefaults.removeObject(forKey: id)
            return nil
        }
    }
    
    /// Returns the current download state for a given Asset.
    func downloadState(for asset: Asset) -> Asset.DownloadState {
        // Check if there is a file URL stored for this asset.
        if let localFileLocation = localAsset(withId: asset.id)?.urlAsset.url {
            // Check if the file exists on disk
            if FileManager.default.fileExists(atPath: localFileLocation.path) {
                return .downloaded
            }
        }
        
        // Check if there are any active downloads in flight.
        if inflightAsset(withId: asset.id) != nil {
            return .downloading
        }
        
        return .notDownloaded
    }
    
    /// Deletes an Asset on disk if possible.
    func deleteAsset(_ asset: Asset) {
        let userDefaults = UserDefaults.standard
        
        do {
            if let localFileLocation = localAsset(withId: asset.id)?.urlAsset.url {
                try FileManager.default.removeItem(at: localFileLocation)
                
                userDefaults.removeObject(forKey: asset.id)
                
                var userInfo = [Asset.Keys: Any]()
                userInfo[Asset.Keys.id] = asset.id
                userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded
                
                postUpdate(userInfo)
            }
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
    
    /// Cancels an AVAssetDownloadTask given an Asset.
    func cancelDownload(for asset: Asset) {
        var task: AVAggregateAssetDownloadTask?
        
        for (taskKey, assetVal) in activeDownloadsMap {
            if asset == assetVal  {
                task = taskKey
                break
            }
        }
        
        task?.cancel()
    }
    
    // MARK: Convenience
    
    typealias MediaSelectionPair = (group: AVMediaSelectionGroup?, option: AVMediaSelectionOption?)
    fileprivate var mediaSelectionOptions = [AVURLAsset: [MediaSelectionPair]]()
    
    fileprivate func buildSelectionOptions(for asset: AVURLAsset) {
        
        if mediaSelectionOptions[asset] != nil {
            return
        }

        var options = [MediaSelectionPair]()
        
        let mediaCharacteristics = [AVMediaCharacteristic.audible, AVMediaCharacteristic.legible]
        
        guard let assetCache = asset.assetCache else { return }
        for mediaCharacteristic in mediaCharacteristics {
            if let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) {
                let savedOptions = assetCache.mediaSelectionOptions(in: mediaSelectionGroup)
                
                if savedOptions.count < mediaSelectionGroup.options.count {
                    // There are still media options left to download.
                    for option in mediaSelectionGroup.options {
                        if !savedOptions.contains(option) && option.mediaType != AVMediaType.closedCaption {
                            // This option has not been downloaded.
                            options.append((mediaSelectionGroup, option))
                        }
                    }
                }
            }
        }
        
        let reversed = Array(options.reversed())
        
        mediaSelectionOptions[asset] = reversed
    }

    /**
     This function demonstrates returns the next `AVMediaSelectionGroup` and
     `AVMediaSelectionOption` that should be downloaded if needed. This is done
     by querying an `AVURLAsset`'s `AVAssetCache` for its available `AVMediaSelection`
     and comparing it to the remote versions.
     */
    fileprivate func nextMediaSelection(_ asset: AVURLAsset) -> MediaSelectionPair? {
        
        // PlayKit note: originally, this function iterates over all media selections every time it's called,
        // Looking for new things to download. This logic is slightly modified: we first build a list of all
        // additional selections, and then download all of them.
        buildSelectionOptions(for: asset)
        
        if var options = mediaSelectionOptions[asset] {
            if options.count > 0 {
                let selection = options.removeLast()
                mediaSelectionOptions[asset] = options
                return selection
            } else {
                return nil
            }
        }
        
        // At this point all media options have been downloaded.
        return nil
    }
}

/**
 Extend `AVAssetDownloadDelegate` to conform to the `AVAssetDownloadDelegate` protocol.
 */
extension AssetPersistenceManager: AVAssetDownloadDelegate {
    
    func postUpdate(_ userInfo: [Asset.Keys: Any]) {
        NotificationCenter.default.post(name: .assetDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let userDefaults = UserDefaults.standard
        
        /*
         This is the ideal place to begin downloading additional media selections
         once the asset itself has finished downloading.
         */
        guard let task = task as? AVAggregateAssetDownloadTask,
            let asset = activeDownloadsMap.removeValue(forKey: task) else { return }
        
        guard let downloadURL = willDownloadToUrlMap.removeValue(forKey: task) else { return }
        
        // Prepare the basic userInfo dictionary that will be posted as part of our notification.
        var userInfo = [Asset.Keys: Any]()
        userInfo[Asset.Keys.id] = asset.id
        
        defer {
            postUpdate(userInfo)
        }
        
        if let error = error as NSError? {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                /*
                 This task was canceled, you should perform cleanup using the
                 URL saved from AVAssetDownloadDelegate.urlSession(_:assetDownloadTask:didFinishDownloadingTo:).
                 */
                guard let localFileLocation = localAsset(withId: asset.id)?.urlAsset.url else { return }
                
                do {
                    try FileManager.default.removeItem(at: localFileLocation)
                    
                    userDefaults.removeObject(forKey: asset.id)
                } catch {
                    print("An error occured trying to delete the contents on disk for \(asset.id): \(error)")
                }
                                
                print("Cancel downloading asset \(asset)")
                
            default:
                userInfo[Asset.Keys.error] = error
                print("Error downloading asset: \(error)")
            }
            
            userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded
            return
        }

        do {
            let bookmark = try downloadURL.bookmarkData()

            userDefaults.set(bookmark, forKey: asset.id)
        } catch {
            print("Failed to create bookmarkData for download URL.")
            userInfo[Asset.Keys.error] = error
            userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded
            return
        }

        userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloaded
    }
    
    /// Method called when the an aggregate download task determines the location this asset will be downloaded to.
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    willDownloadTo location: URL) {

        /*
         This delegate callback should only be used to save the location URL
         somewhere in your application. Any additional work should be done in
         `URLSessionTaskDelegate.urlSession(_:task:didCompleteWithError:)`.
         */

        willDownloadToUrlMap[aggregateAssetDownloadTask] = location
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection) {
        // This delegate callback should be used to provide download progress for your AVAssetDownloadTask.
        guard let asset = activeDownloadsMap[aggregateAssetDownloadTask] else { return }
        
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete +=
                loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        
        var userInfo = [Asset.Keys: Any]()
        userInfo[Asset.Keys.id] = asset.id
        userInfo[Asset.Keys.percentDownloaded] = percentComplete
        
        print("ProgressNotification \(percentComplete)")
        NotificationCenter.default.post(name: .assetDownloadProgressNotification, object: nil, userInfo:  userInfo)
    }
}
