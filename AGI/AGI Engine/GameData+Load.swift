//
//  GameData+Load.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-10.
//

import Foundation

extension GameData {
    
    func loadGameData(from path: String,
                      loadFinished: ([Int: Picture], [Int: View]) -> Void,
                      redraw: @escaping () -> Void) {
        do {
            agiVersion = 2
            picturesDirectory = nil
            viewsDirectory = nil
            volumes.clear()
            pictures.removeAll()
            views.removeAll()
            objects.removeAll()
            words.removeAll()
            redrawLambda = redraw
            
            let fileList = try FileManager.default.contentsOfDirectory(atPath: path)
            
            for file in fileList {
                switch file.lowercased() {
                
                // Logic
                case FileName.logic.rawValue:
                    logicDirectory = loadDirectoryData(from: "\(path)/\(file)")
                
                // Pictures Directory
                case FileName.pictures.rawValue:
                    picturesDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
                // View Directory
                case FileName.view.rawValue:
                    viewsDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
                // Words
                case FileName.words.rawValue:
                    words = Words.fetchWords(from: "\(path)/\(file)")
                    
                // Objects
                case FileName.objects.rawValue:
                    objects = Objects.fetchObjects(from: "\(path)/\(file)")
                    
                // Multiple files
                default:
                    
                    let fileParts = file.lowercased().split(separator: ".")
                    
                    // Volumes
                    if fileParts.first?.hasSuffix(FileName.volume.rawValue) ?? false, let ext = fileParts.last {
                        volumes.addFile(String(ext), "\(path)/\(file)")
                    }
                    
                    // All files directory
                    else if allFilesDirectories.contains(file.lowercased()) {
                        loadAllFilesDirectoryData("\(path)/\(file)")
                    }
                    
                    // Unknown
                    else {
                        Utils.debug("Uknown file: \(file)")
                    }
                }
            }
    
        } catch { Utils.debug("Error getting file list: \(error)")}
        
        // Now that we have read in all the files, populate the data structures
        
        // Get all the logic, picture and view data from the vol files
        loadLogicData()
        loadPictureData()
        loadViewData()
        
        // Tell UI load is finished
        loadFinished(pictures, views)
        
        playRoom(roomNumber: 140)
    }
    
    func loadAllFilesDirectoryData(_ path: String) {
        
        // Load the file to get the header and locations of the individual directories
        if let data = NSData(contentsOfFile: path) {
            
            var dataPosition = 0
            
            agiVersion = 3
            
            do {
                let logicDirectoryStart = try Utils.getNextWord(at: &dataPosition, from: data)
                let pictureDirectoryStart = try Utils.getNextWord(at: &dataPosition, from: data)
                let viewDirectoryStart = try Utils.getNextWord(at: &dataPosition, from: data)
                let soundDirectoryStart = try Utils.getNextWord(at: &dataPosition, from: data)
                
                // Logic
                let logicData = data.subdata(with: NSRange(location: logicDirectoryStart,
                                                           length: pictureDirectoryStart - logicDirectoryStart))
                logicDirectory = Directory(logicData as NSData)
                
                // Pictures
                let pictureData = data.subdata(with: NSRange(location: pictureDirectoryStart,
                                                             length: viewDirectoryStart - pictureDirectoryStart))
                picturesDirectory = Directory(pictureData as NSData)
                
                // View
                let viewData = data.subdata(with: NSRange(location: viewDirectoryStart,
                                                          length: soundDirectoryStart - viewDirectoryStart))
                viewsDirectory = Directory(viewData as NSData)
                
                // Sound
                var soundDirectoryLength = data.length - soundDirectoryStart
                if soundDirectoryLength > 256 * 3 {
                    soundDirectoryLength = 256 * 3
                }
                let soundData = data.subdata(with: NSRange(location: soundDirectoryStart,
                                                           length: soundDirectoryLength))
                soundsDirectory = Directory(soundData as NSData)
            } catch {
                Utils.debug("GameData loadAllFilesDirectoryData: EndOfData")
            }
        }
    }
    
    func loadDirectoryData(from path: String) -> Directory? {
        return Directory(path)
    }
    
    func loadLogicData() {
        
        if let keys = logicDirectory?.items.keys.sorted() {
            for key in keys {
                if let directoryItem = logicDirectory?.items[key] {
                    
                    Utils.debug("Logic \(key): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let logicInfo = volumes.getData(version: agiVersion,
                                                       volumeNumber: directoryItem.volumeNumber,
                                                       position: directoryItem.position,
                                                       type: VolumeType.logic) {
                        
                        logic[key] = Logic(volumeInfo: logicInfo, id: key, version: agiVersion)
                    }
                }
            }
        }
    }
    
    func loadPictureData() {
        
        if let keys = picturesDirectory?.items.keys.sorted() {
            for key in keys {
                if let directoryItem = picturesDirectory?.items[key] {
                    
                    Utils.debug("Picture \(key): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let pictureInfo = volumes.getData(version: agiVersion,
                                                         volumeNumber: directoryItem.volumeNumber,
                                                         position: directoryItem.position,
                                                         type: VolumeType.picture) {
                        
                        pictures[key] = Picture(volumeInfo: pictureInfo, id: key, version: agiVersion)
                    }
                }
            }
        }
    }
    
    func loadViewData() {
        
        if let keys = viewsDirectory?.items.keys.sorted() {
            for key in keys {
                if let directoryItem = viewsDirectory?.items[key] {
                    
                    Utils.debug("View \(key): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let viewInfo = volumes.getData(version: agiVersion,
                                                      volumeNumber: directoryItem.volumeNumber,
                                                      position: directoryItem.position,
                                                      type: VolumeType.view) {
                        
                        views[key] = View(volumeInfo: viewInfo, id: key, version: agiVersion)
                    }
                }
            }
        }
    }
}
