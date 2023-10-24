//
//  ScreenObject.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-27.
//

import Foundation

class ScreenObject {
    
    enum ViewFlags: Int {
        case fDrawn          = 0x0001
        case fIgnoreBlocks   = 0x0002
        case fFixedPriority  = 0x0004
        case fIgnoreHorizon  = 0x0008
        case fUpdate         = 0x0010
        case fCycling        = 0x0020
        case fAnimated       = 0x0040
        case fMotion         = 0x0080
        case fOnWater        = 0x0100
        case fIgnoreObjects  = 0x0200
        case fUpdatePos      = 0x0400
        case fOnLand         = 0x0800
        case fDontupdate     = 0x1000
        case fFixLoop        = 0x2000
        case fDidntMove      = 0x4000
        case fAdjEgoXY       = 0x8000
    }
    
    enum MotionType: Int {
        case kMotionNormal = 0
        case kMotionWander = 1
        case kMotionFollowEgo = 2
        case kMotionMoveObj = 3
        case kMotionEgo = 4 // used by us for mouse movement only?
    }
    
    var viewId = 0
    var flags: [ViewFlags: Bool] = [:]
    var playerControl = false
    var direction = 0
    
    // Position
    var posX = 0
    var posY = 0
    var prevPosX = 0
    var prevPosY = 0
    
    // Size
    var sizeX = 0
    var sizeY = 0
    
    // Move
    var motionType: MotionType = .kMotionNormal
    var moveX = 0
    var moveY = 0
    var moveStepSize = 0
    var moveFlags = 0
    
    // Stepping
    var stepSize = 0
    var stepTime = 0
    var stepTimeCount = 0
    var cycleTime: UInt8 = 0
    var cycleTimeCount = 0
    
    // Drawing
    var loopCount = 0
    
    var currentLoopNum = 0
    var currentCellNum = 0
    
    func setView(_ view: View) {
        print("Set View: \(view.id) - \(view.stepSize)")
        viewId = view.id
        loopCount = view.loops.count
        stepSize = Int(view.stepSize)
        cycleTime = view.cycleTime
        cycleTimeCount = 0
    }
    
    func moveTo(moveX: Int, moveY: Int, stepSize: Int, moveFlags: Int) {
        print("moveTo: \(moveX),\(moveY)")
        motionType = .kMotionMoveObj
        self.moveX = moveX
        self.moveY = moveY
        self.moveStepSize = stepSize
        self.moveFlags = moveFlags
        
        if stepSize != 0 {
            self.stepSize = stepSize
        }
        
        Logic.variables[moveFlags] = 0
        
        flags[ScreenObject.ViewFlags.fUpdate] = true
        flags[ScreenObject.ViewFlags.fAnimated] = true
        
        playerControl = false
    }
    
    func changePos() {
        
        var insideBlock = false
        var x = 0
        var y = 0
        let dx = [ 0, 0, 1, 1, 1, 0, -1, -1, -1 ]
        let dy = [ 0, -1, -1, 0, 1, 1, 1, 0, -1 ]
        
        x = posX
        y = posY
        insideBlock = checkBlock(x, y);
    
        print("Object: \(viewId) S: \(stepSize) D: \(direction)")
        print("Old Pos: \(posX),\(posY)")
        posX += stepSize * dx[direction]
        posY += stepSize * dy[direction]
        print("New Pos: \(posX),\(posY)")
        
        if (checkBlock(x, y) == insideBlock) {
            flags[.fMotion] = nil
        } else {
            flags[.fMotion] = true
            direction = 0
        }
    }
    
    func updatePosition() {
        
    }
    
    private func checkBlock(_ x: Int, _ y: Int) -> Bool {
        return false
    }
    
    func checkMotion() {
        
        if motionType == .kMotionMoveObj {
            
            direction = getDirection()
            
            if direction == 0 {
                print("Stop Moving")
                stopMoving()
            }
        }
        
        if direction != 0 {
            changePos()
        }
    }
    
    private func stopMoving() {
        stepSize = moveStepSize
        motionType = .kMotionNormal
    }
    
    private func getDirection() -> Int {
        
        let dirTable: [Int] = [ 8, 1, 2, 7, 0, 3, 6, 5, 4 ]
        return dirTable[checkStep(
                            delta: moveX - posX, step: stepSize) + 3 * checkStep(delta: moveY - posY,
                                                                                 step: stepSize)
        ]
    }
    
    private func checkStep(delta: Int, step: Int) -> Int {
        return (-step >= delta) ? 0 : (step <= delta) ? 2 : 1
    }
}
