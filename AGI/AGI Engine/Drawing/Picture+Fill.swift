//
//  Picture+Fill.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-04.
//

import Foundation

extension Picture {
    
    func fill() {
        
        while (peekNextByte() < 0xF0) {
            
            let posX = getNextByte()
            let posY = getNextByte()
            
            Utils.debug("Fill: \(posX),\(posY)")
            
            floodFill(x: Int(posX), y: Int(posY))
        }
    }
    
    private func floodFill(x posX: Int, y posY: Int) {
        
        struct FillPosition {
            let posX: Int
            let posY: Int
        }
        
        func isPixelDrawable(_ posX: Int, _ posY: Int) -> Bool {
            
            guard posX >= 0, posX < pictureWidth, posY >= 0, posY < pictureHeight else { return false }
            
            let pictureColor = getPicturePixel(x: posX, y: posY)
            let priorityColor = getPriorityPixel(x: posX, y: posY)
            
            // Drawing only Picture
            if isDrawingPicture && !isDrawingPriority && currentPictureColor != Picture.colorWhite {
                return pictureColor == Picture.colorWhite
            }
            
            // Drawing only Priority
            if isDrawingPriority && !isDrawingPicture && currentPriorityColor != Picture.colorRed {
                return priorityColor == Picture.colorRed
            }
            
            // Drawing Picture and (possibly) Priority
            return (isDrawingPicture && pictureColor == Picture.colorWhite && currentPictureColor != Picture.colorWhite)
        }
        
        func addToFillQueue(_ posX: Int, _ posY: Int) {
            fillQueue.append(FillPosition(posX: posX, posY: posY))
        }
        
        var fillQueue: [FillPosition] = []
        
        // Get the starting position and add to the queue
        addToFillQueue(posX, posY)
        
        while !fillQueue.isEmpty {
            
            let lastItem = fillQueue.removeLast()
            var posX = Int(lastItem.posX)
            let posY = Int(lastItem.posY)
            
            // This pixel myst have been updated already
            if !isPixelDrawable(posX, posY) {
                continue
            }
            
            // Find the left most pixel on this line
            while isPixelDrawable(posX - 1, posY) {
                posX -= 1
            }
            
            // Move to the right while we can draw and add every other pixel above and below to the queue
            var isCheckingUp = true
            var isCheckingDown = true
            
            while isPixelDrawable(posX, posY) {
                drawPixel(x: posX, y: posY)
                
                if isPixelDrawable(posX, posY - 1) {
                    if isCheckingUp {
                        addToFillQueue(posX, posY - 1)
                        isCheckingUp = false
                    }
                } else {
                    isCheckingUp = true
                }
                
                if isPixelDrawable(posX, posY + 1) {
                    if isCheckingDown {
                        addToFillQueue(posX, posY + 1)
                        isCheckingDown = false
                    }
                } else {
                    isCheckingDown = true
                }
                
                posX += 1
            }
        }
    }
}
