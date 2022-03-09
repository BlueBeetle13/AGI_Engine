//
//  Picture+Fill.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-04.
//

import Foundation

extension Picture {
    
    func fill() {
        Utils.debug("Fill")

        while (peekNextByte() < 0xF0) {
            
            let posX = getNextByte()
            let posY = getNextByte()
   
            if isDrawingPicture { floodFill(gameData.pictureBuffer, currentPictureColor, palette[15], posX, posY) }
            //if isDrawingPriority { floodFill(gameData.priorityBuffer, currentPriorityColor, palette[4], posX, posY) }
        }
    }
    
    private func floodFill(_ buffer: NSMutableArray,
                           _ currentColor: Pixel,
                           _ backgroundColor: Pixel,
                           _ posX: UInt8,
                           _ posY: UInt8) {
        
        struct FillPosition: Equatable {
            let posX: UInt8
            let posY: UInt8
            
            init(_ posX: UInt8, _ posY: UInt8) {
                self.posX = posX
                self.posY = posY
            }
            
            public static func == (lhs: FillPosition, rhs: FillPosition) -> Bool {
                return lhs.posX == rhs.posX && lhs.posY == rhs.posY
            }
        }
        
        func addToFillQueue(_ posX: UInt8, _ posY: UInt8) {
            
            let pixelColor = getPixel(from: buffer, x: posX, y: posY)
            if pixelColor != currentColor && pixelColor == backgroundColor {
                fillQueue.append(FillPosition(posX, posY))
            }
        }
        
        var fillQueue: [FillPosition] = []
        
        // Get the starting position and add to the queue
        addToFillQueue(posX, posY)
        
        while !fillQueue.isEmpty {
            
            let lastItem = fillQueue.removeLast()
            let posX = lastItem.posX
            let posY = lastItem.posY
            
            // Color the current pixel
            drawPixel(to: buffer, color: currentColor, x: posX, y: posY)
            
            // If the pixel to the left is white, add to the queue
            if posX > 0 {
                addToFillQueue(posX - 1, posY)
            }
            
            // If the pixel to the right is white, add to the queue
            if posX < 160 - 1 {
                addToFillQueue(posX + 1, posY)
            }
            
            // If the pixel to the top is white, add to the queue
            if posY > 0 {
                addToFillQueue(posX, posY - 1)
            }
            
            // If the pixel to the top is white, add to the queue
            if posY < 200 - 1 - 32 {
                addToFillQueue(posX, posY + 1)
            }
        }
    }
}
