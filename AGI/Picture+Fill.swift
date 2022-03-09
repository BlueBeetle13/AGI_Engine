//
//  Picture+Fill.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-04.
//

import Foundation

extension Picture {
    
    func fill(buffer: inout [Pixel]) {
        Utils.debug("Fill")

        while (peekNextByte() < 0xF0) {
            
            let posX = getNextByte()
            let posY = getNextByte()
   
            if isDrawingPicture {
                floodFill(&buffer, Int(posX), Int(posY))
            }
        }
    }
    
    private func floodFill(_ buffer: inout [Pixel], _ posX: Int, _ posY: Int) {
        
        struct FillPosition {
            let posX: Int
            let posY: Int
        }
        
        func isPixelDrawable(_ posX: Int, _ posY: Int) -> Bool {
            
            guard posX >= 0, posX < 160, posY >= 0, posY < 200 - 32 else { return false }
            
            let pixelColor = getPixel(from: buffer, x: posX, y: posY)
            return (currentColor != palette[15] && pixelColor == palette[15])
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
                drawPixel(to: &buffer, x: posX, y: posY)
                
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
