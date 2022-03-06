//
//  GameData.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation

class GameData {
    
    enum FileName: String {
        case pictures = "picdir"
        case view = "viewdir"
        case volume = "vol"
        case words = "words.tok"
        case mh2dir = "mh2dir"
        case mhdir = "mhdir"
        case grdir = "grdir"
        case kq4dir = "kq4dir"
    }
    
    private var agiVersion = 2
    private var picturesDirectory: Directory?
    private var viewDirectory: Directory?
    private let volumes = Volume()
    private var pictures: [Int: Picture] = [:]
    private var words: [Word] = []
    private var redrawLambda: (() -> Void)? = nil
    
    func loadGameData(from path: String,
                      with buffer: inout [Pixel],
                      loadFinished: ([Int: Picture]) -> Void,
                      redraw: @escaping () -> Void) {
        do {
            agiVersion = 2
            picturesDirectory = nil
            viewDirectory = nil
            volumes.clear()
            pictures.removeAll()
            words.removeAll()
            redrawLambda = redraw
            
            let fileList = try FileManager.default.contentsOfDirectory(atPath: path)
            
            for file in fileList {
                switch file.lowercased() {
                
                // All Directories file
                case FileName.mh2dir.rawValue,
                     FileName.mhdir.rawValue,
                     FileName.grdir.rawValue,
                     FileName.kq4dir.rawValue:
                    loadAllFilesDirectoryData("\(path)/\(file)")
                
                // Pictures Directory
                case FileName.pictures.rawValue:
                    picturesDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
                // View Directory
                case FileName.view.rawValue:
                    viewDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
                // Words
                case FileName.words.rawValue:
                    words = Words.fetchWords(from: "\(path)/\(file)")
                    
                // Not individual file
                default:
                    
                    let fileParts = file.lowercased().split(separator: ".")
                    
                    // Volume
                    if fileParts.first?.hasSuffix( FileName.volume.rawValue) ?? false,
                       let ext = fileParts.last {
                        print("Volume: \(file)")
                        volumes.addFile(String(ext), "\(path)/\(file)")
                    }
                    
                    // Unknown
                    else {
                        print("Uknown file: \(file)")
                    }
                }
            }
    
        } catch { print("Error getting file list: \(error)")}
        
        // Now that we have read in all the files, populate the data structures
        
        // Get all the pictures
        loadPictureData()
        
        // Tell UI load is finished
        loadFinished(pictures)
    }
    
    func loadPicture(id: Int, buffer: inout [Pixel]) {
        if let picture = pictures[id] {
            
            print("Draw....")
            picture.drawToBuffer(buffer: &buffer)
            
            redrawLambda?()
        }
    }
    
    private func loadAllFilesDirectoryData(_ path: String) {
        
        // Load the file to get the header and locations of the individual directories
        if let data = NSData(contentsOfFile: path) {
            
            var dataPosition = 0
            
            // This file must begin with 0x0800
            guard Utils.getNextByte(at: &dataPosition, from: data) == 0x08,
                  Utils.getNextByte(at: &dataPosition, from: data) == 0x00 else { return }
            
            agiVersion = 3
            
            let logDirectory = Utils.getWord(at: &dataPosition, from: data)
            let picDirectory = Utils.getWord(at: &dataPosition, from: data)
            
            let picData = data.subdata(with: NSRange(location: logDirectory, length:  picDirectory - logDirectory))
            picturesDirectory = Directory(picData as NSData)
        }
    }
    
    private func loadDirectoryData(from path: String) -> Directory? {
        return Directory(path)
    }
    
    private func loadPictureData() {
        
        for pos in 0...(picturesDirectory?.items.count ?? 0) {
            if let directoryItem = picturesDirectory?.items[pos] {
                
                print("Picture \(pos): \(directoryItem.volumeNumber), \(directoryItem.position)")
                if let pictureData = volumes.getData(version: agiVersion,
                                                     volumeNumber: directoryItem.volumeNumber,
                                                     position: directoryItem.position) {
                    
                    print("Picture \(pos) data: \(pictureData.length)")
                    pictures[pos] = Picture(with: pictureData, id: pos, version: agiVersion)
                }
            }
        }
    }
}
