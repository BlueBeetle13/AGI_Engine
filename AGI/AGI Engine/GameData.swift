//
//  GameData.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation

class GameData {
    
    enum FileName: String {
        case logic = "logdir"
        case pictures = "picdir"
        case view = "viewdir"
        case volume = "vol"
        case objects = "object"
        case words = "words.tok"
    }
    let allFilesDirectories = ["mh2dir", "mhdir", "grdir", "kq4dir"]

    private var currentPictureNum = -1
    var agiVersion = 2
    var logicDirectory: Directory?
    var picturesDirectory: Directory?
    var viewsDirectory: Directory?
    var soundsDirectory: Directory?
    let volumes = Volume()
    var logic: [Int: Logic] = [:]
    var pictures: [Int: Picture] = [:]
    var views: [Int: View] = [:]
    var words: [Word] = []
    var objects: [Object] = []
    var redrawLambda: (() -> Void)? = nil
    
    // Rendering
    static let width = 320
    static let height = 168
    var pictureBuffer: UnsafeMutablePointer<Pixel>
    var priorityBuffer: UnsafeMutablePointer<Pixel>
    
    init() {
        
        // Rendering
        pictureBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity:GameData.width * GameData.height)
        priorityBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity: GameData.width * GameData.height)
    }
    
    func playRoom(roomNumber: UInt8) {
        
        guard let logic = logic[Int(roomNumber)] else {
            Utils.debug("Missing Room info; \(roomNumber)")
            return
        }
        
        Logic.setNewRoomGameState(roomNumber: roomNumber)
        
        let drawGraphics = { [weak self] (pictureId: Int, viewId: Int, viewLoopNum: Int, viewCellNum: Int) in
            
            // Picure
            if pictureId != -1 {
                self?.drawPicture(id: pictureId)
            }
            
            // View
            else if viewId != -1 {
                self?.drawView(viewId, viewLoopNum, viewCellNum)
            }
        }
        
        logic.executeLogic(drawGraphics)
    }
    
    func drawPicture(id: Int) {
        if let picture = pictures[id] {
            
            currentPictureNum = id
            
            picture.drawToBuffer(pictureBuffer, priorityBuffer)
            
            redrawLambda?()
        }
    }
    
    func drawView(_ viewId: Int, _ loopNum: Int, _ cellNum: Int) {
        
        if currentPictureNum != -1, let picture = pictures[currentPictureNum], let view = views[viewId] {
            
            // Draw the picture
            picture.drawToBuffer(pictureBuffer, priorityBuffer)
            
            // Draw the view
            view.drawView(pictureBuffer: pictureBuffer,
                          priorityBuffer: priorityBuffer,
                          posX: 0,
                          posY: 0,
                          loopNum: loopNum,
                          cellNum: cellNum)
            
            redrawLambda?()
        }
    }
}
