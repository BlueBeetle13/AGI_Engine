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
    
    private var agiVersion = 2
    private var logicDirectory: Directory?
    private var picturesDirectory: Directory?
    private var viewsDirectory: Directory?
    private var soundsDirectory: Directory?
    private let volumes = Volume()
    private var pictures: [Int: Picture] = [:]
    private var currentPictureNum = -1
    private var views: [Int: View] = [:]
    private var words: [Word] = []
    private var objects: [Object] = []
    private var redrawLambda: (() -> Void)? = nil
    
    // Rendering
    let width = 320
    let height = 200
    var pictureBuffer: UnsafeMutablePointer<Pixel>
    var priorityBuffer: UnsafeMutablePointer<Pixel>
    var priorityClearBuffer: UnsafeMutablePointer<Pixel>
    
    init() {
        pictureBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        priorityBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        priorityClearBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        // Set priority clear buffer to all red
        for pos in 0 ..< (width * height) {
            priorityClearBuffer[pos] = Picture.colorRed
        }
    }
    
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
        
        // Get all the picture data from the vol files
        loadPictureData()
        
        // Get all the view data from the vol files
        loadViewData()
        
        // Tell UI load is finished
        loadFinished(pictures, views)
    }
    
    func drawPicture(id: Int) {
        if let picture = pictures[id] {
            
            currentPictureNum = id
            
            // Clear the buffers
            memset(pictureBuffer, 0xFF, width * height * MemoryLayout<Pixel>.size)
            memcpy(priorityBuffer, priorityClearBuffer, width * height * MemoryLayout<Pixel>.size)

            picture.drawToBuffer()
            
            redrawLambda?()
        }
    }
    
    func drawView(viewNum: Int, loopNum: Int, cellNum: Int) {
        
        if currentPictureNum != -1, let picture = pictures[currentPictureNum], let view = views[viewNum] {
            
            // Clear the buffers
            memset(pictureBuffer, 0xFF, width * height * MemoryLayout<Pixel>.size)
            memcpy(priorityBuffer, priorityClearBuffer, width * height * MemoryLayout<Pixel>.size)

            // Draw the picture
            picture.drawToBuffer()
            
            // Draw the view
            view.drawView(loopNum: loopNum, cellNum: cellNum)
            
            redrawLambda?()
            
        }
    }
    
    private func loadAllFilesDirectoryData(_ path: String) {
        
        // Load the file to get the header and locations of the individual directories
        if let data = NSData(contentsOfFile: path) {
            
            var dataPosition = 0
            
            agiVersion = 3
            
            let logicDirectoryStart = Utils.getNextWord(at: &dataPosition, from: data)
            let pictureDirectoryStart = Utils.getNextWord(at: &dataPosition, from: data)
            let viewDirectoryStart = Utils.getNextWord(at: &dataPosition, from: data)
            let soundDirectoryStart = Utils.getNextWord(at: &dataPosition, from: data)
            
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
        }
    }
    
    private func loadDirectoryData(from path: String) -> Directory? {
        return Directory(path)
    }
    
    private func loadPictureData() {
        
        if let keys = picturesDirectory?.items.keys.sorted() {
            for key in keys {
                if let directoryItem = picturesDirectory?.items[key] {
                    
                    Utils.debug("Picture \(key): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let pictureData = volumes.getData(version: agiVersion,
                                                         volumeNumber: directoryItem.volumeNumber,
                                                         position: directoryItem.position) {
                        
                        Utils.debug("Picture \(key) data: \(pictureData.length)")
                        pictures[key] = Picture(gameData: self, data: pictureData, id: key, version: agiVersion)
                    }
                }
            }
        }
    }
    
    private func loadViewData() {
        
        if let keys = viewsDirectory?.items.keys.sorted() {
            for key in keys {
                if let directoryItem = viewsDirectory?.items[key] {
                    
                    Utils.debug("View \(key): \(directoryItem.volumeNumber), \(directoryItem.position)")
                    if let viewData = volumes.getData(version: agiVersion,
                                                      volumeNumber: directoryItem.volumeNumber,
                                                      position: directoryItem.position) {
                        
                        Utils.debug("View \(key) data: \(viewData.length)")
                        views[key] = View(gameData: self, compressedData: viewData, id: key, version: agiVersion)
                    }
                }
            }
        }
    }
    
    private func arrayPos(_ x: Int, _ y: Int) -> Int {
        guard x < width && y < height && x >= 0 && y >= 0 else { return 0 }
        
        return (Int(y) * width) + Int(x)
    }
    
    func drawPixel(buffer: UnsafeMutablePointer<Pixel>, x: Int, y: Int, color: Pixel) {
        buffer[arrayPos(x * 2, y)] = color
        buffer[arrayPos((x * 2) + 1, y)] = color
    }
    
    func getPixel(buffer: UnsafeMutablePointer<Pixel>, x: Int, y: Int) -> Pixel {
        buffer[arrayPos(x * 2, y)]
    }
}
