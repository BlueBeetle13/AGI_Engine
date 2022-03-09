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
        case objects = "object"
        case words = "words.tok"
    }
    let allFilesDirectories = ["mh2dir", "mhdir", "grdir", "kq4dir"]
    
    // Rendering
    let width = 320
    let height = 200
    var pictureBuffer: NSMutableArray
    var priorityBuffer: NSMutableArray
    
    var bitfield = UnsafeMutablePointer<UInt8>.allocate(capacity: 320 * 200 * 4)
    var clearBitfield = UnsafeMutablePointer<UInt8>.allocate(capacity: 320 * 200 * 4)
    
    
    private var agiVersion = 2
    private var picturesDirectory: Directory?
    private var viewDirectory: Directory?
    private let volumes = Volume()
    private var pictures: [Int: Picture] = [:]
    private var words: [Word] = []
    private var objects: [Object] = []
    private var redrawLambda: (() -> Void)? = nil
    
    init() {
        pictureBuffer = NSMutableArray.init(capacity: width * height)
        priorityBuffer = NSMutableArray.init(capacity: width * height)
        
        for pos in 0..<(width * height) {
            pictureBuffer[pos] = Pixel(a: 255, r: 255, g: 255, b: 255)
            priorityBuffer[pos] = Pixel(a: 255, r: 172, g: 0, b: 0)
        }
        
        memset(bitfield, 255, 320 * 200 * 4)
        memset(clearBitfield, 255, 320 * 200 * 4)
    }
    
    func loadGameData(from path: String,
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
                
                // Pictures Directory
                case FileName.pictures.rawValue:
                    picturesDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
                // View Directory
                case FileName.view.rawValue:
                    viewDirectory = loadDirectoryData(from: "\(path)/\(file)")
                    
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
        
        // Get all the pictures
        loadPictureData()
        
        // Tell UI load is finished
        loadFinished(pictures)
    }
    
    func loadPicture(id: Int) {
        if let picture = pictures[id] {
            
            // Clear buffers
            /*for pos in 0..<(width * height) {
                //pictureBuffer[pos] = Pixel(a: 255, r: 255, g: 255, b: 255)
                //priorityBuffer[pos] = Pixel(a: 255, r: 172, g: 0, b: 0)
            }*/
            
            memcpy(bitfield, clearBitfield, 320 * 200 * 4)
            //memset(bitfield, 255, 320 * 200 * 4)
            
            // Draw the picture to the buffers
            picture.drawToBuffer()
            
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
            
            let logDirectory = Utils.getNextWord(at: &dataPosition, from: data)
            let picDirectory = Utils.getNextWord(at: &dataPosition, from: data)
            
            let picData = data.subdata(with: NSRange(location: logDirectory, length:  picDirectory - logDirectory))
            picturesDirectory = Directory(picData as NSData)
        }
    }
    
    private func loadDirectoryData(from path: String) -> Directory? {
        return Directory(path)
    }
    
    private func loadPictureData() {
        
        if let items = picturesDirectory?.items {
            for pos in 0..<items.count {
                if let directoryItem = items[pos] {
                    
                    Utils.debug("Picture \(pos): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let pictureData = volumes.getData(version: agiVersion,
                                                         volumeNumber: directoryItem.volumeNumber,
                                                         position: directoryItem.position) {
                        
                        Utils.debug("Picture \(pos) data: \(pictureData.length)")
                        pictures[pos] = Picture(with: self, data: pictureData, id: pos, version: agiVersion)
                    }
                }
            }
        }
    }
}
