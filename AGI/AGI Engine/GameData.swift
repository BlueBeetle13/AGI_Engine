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
    var inventoryItems: [InventoryItem] = []
    var redrawLambda: (() -> Void)? = nil
    
    // Rendering
    static let width = 320
    static let height = 168
    var pictureBuffer: UnsafeMutablePointer<Pixel>
    var priorityBuffer: UnsafeMutablePointer<Pixel>
    
    // Game Flow
    var drawGraphics: (Int?, ScreenObject?, Bool) -> Void = { (_, _, _) in }
    var currentRoomLogic: Logic? = nil
    
    init() {
        
        // Rendering
        pictureBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity:GameData.width * GameData.height)
        priorityBuffer = UnsafeMutablePointer<Pixel>.allocate(capacity: GameData.width * GameData.height)
        
        drawGraphics = { (pictureId: Int?,
                          screenObject: ScreenObject?,
                          redrawScreen: Bool) in
            
            // Picture
            if let id = pictureId {
                print("Draw Picure: \(id)")
                self.drawPicture(id: id)
            }
            
            // Screen Object
            if let object = screenObject {
                print("Draw ScreenObject: \(object.viewId) - \(object.posX) - \(object.posY)")
                self.drawScreenObject(object)
            }
            
            // Redraw
            if redrawScreen {
                print("Draw Screen")
                self.redrawLambda?()
            }
        }
    }
    
    func playRoom(roomNumber: UInt8) {
        
        print("Play Room: \(roomNumber)")
        
        guard logic.keys.contains(Int(roomNumber)) else {
            Utils.debug("Missing Room info; \(roomNumber)")
            return
        }
        
        Logic.setNewRoomGameState(roomNumber: roomNumber)
        currentRoomLogic = logic[Int(roomNumber)]
        currentRoomLogic?.processLogic(drawGraphics)
    }
    
    func stepLogic() {
        
        if let logic = currentRoomLogic {
            
            // Show game state
            print("Flags")
            for (index, flag) in Logic.flags.enumerated() {
                print("\(index)) \(flag)")
            }
            print("\nVariables")
            for (index, variable) in Logic.variables.enumerated() {
                print("\(index)) \(variable)")
            }
            
            Logic.setLogicStepState()
            logic.processLogic(drawGraphics)
        }
    }
    
    func drawPicture(id: Int) {
        if let picture = pictures[id] {
            
            currentPictureNum = id
            
            picture.drawToBuffer(pictureBuffer, priorityBuffer)
            
            redrawLambda?()
        }
    }
    
    func drawScreenObject(_ screenObject: ScreenObject) {
        
        if currentPictureNum != -1, let picture = pictures[currentPictureNum],
           let view = views[screenObject.viewId] {
            
            // Draw the picture
            picture.drawToBuffer(pictureBuffer, priorityBuffer)
            
            // Draw the view
            view.drawView(pictureBuffer: pictureBuffer,
                          priorityBuffer: priorityBuffer,
                          posX: screenObject.posX,
                          posY: screenObject.posY,
                          loopNum: screenObject.currentLoopNum,
                          cellNum: screenObject.currentCellNum)
            
            redrawLambda?()
        }
    }
}
