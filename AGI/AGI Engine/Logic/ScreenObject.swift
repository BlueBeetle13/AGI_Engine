//
//  ScreenObject.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-27.
//

import Foundation

class ScreenObject {
    
    var viewId = 0
    
    // Position
    var posX = 0
    var posY = 0
    var prevPosX = 0
    var prevPosY = 0
    
    // Size
    var sizeX = 0
    var sizeY = 0
    
    // Move
    var moveX = 0
    var moveY = 0
    var moveStepSize = 0
    var moveFlags = 0
    
    // Drawing
    var loopCount = 0
    
    var currentLoopNum = 0
    var currentCellNum = 0
    
    func setView(viewId: Int) {
        self.viewId = viewId
    }
}
