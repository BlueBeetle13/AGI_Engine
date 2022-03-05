//
//  Picture+Line.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-04.
//

import Foundation

extension Picture {
    
    func drawCornerLine(isYDirection: Bool, buffer: inout [Pixel]) {
        debug("Draw Y Corner")
        
        var startX: UInt8 = 0
        var startY: UInt8 = 0
        
        // Get the starting positions
        if peekNextByte() < 0xF0 {
            startX = getNextByte()
            startY = getNextByte()
        }
        
        var isYDirection = isYDirection
        
        while (peekNextByte() < 0xF0) {
            
            var endX = startX
            var endY = startY
            
            if isYDirection {
                endY = getNextByte()
            } else {
                endX = getNextByte()
            }
            
            if isDrawingPicture {
                drawLine(&buffer, startX, startY, endX, endY)
            }
            
            startX = endX
            startY = endY
            isYDirection = !isYDirection
        }
    }
    
    func drawAbsoluteLine(buffer: inout [Pixel]) {
        debug("Draw Absolute Line")
        
        var startX: UInt8 = 0
        var startY: UInt8 = 0
        
        // Get the starting positions
        if peekNextByte() < 0xF0 {
            startX = getNextByte()
            startY = getNextByte()
        }
        
        while (peekNextByte() < 0xF0) {
            
            let endX = getNextByte()
            let endY = getNextByte()
            
            if isDrawingPicture {
                drawLine(&buffer, startX, startY, endX, endY)
            }
            
            startX = endX
            startY = endY
        }
    }
    
    func drawRelativeLine(buffer: inout [Pixel]) {
        debug("Draw Relative Line")
        
        var startX: UInt8 = 0
        var startY: UInt8 = 0
        
        // Get the starting positions
        if peekNextByte() < 0xF0 {
            startX = getNextByte()
            startY = getNextByte()
        }
        
        while (peekNextByte() < 0xF0) {
            
            let displacement = getNextByte()
            
            let xNegative = Int(displacement >> 7)
            let xDisp = Int((displacement >> 4) & 0x07)
            let xChange: Int = (xNegative == 0x01) ? -xDisp : xDisp
            
            let yNegative = Int(displacement & 0x08) >> 3
            let yDisp = Int(displacement & 0x07)
            let yChange: Int = (yNegative == 0x01) ? -yDisp : yDisp
            
            let endX = Int(startX) + xChange
            let endY = Int(startY) + yChange
            
            if isDrawingPicture {
                drawLine(&buffer, startX, startY, UInt8(endX), UInt8(endY))
            }
            
            startX = UInt8(endX)
            startY = UInt8(endY)
        }
    }
    
    private func drawLine(_ buffer: inout [Pixel], _ startX: UInt8, _ startY: UInt8, _ endX: UInt8, _ endY: UInt8) {
        debug("Draw Line: \(startX),\(startY) -> \(endX),\(endY)")
        
        func round(number: Double, direction: Double) -> UInt8 {
            
            let floor = number.rounded(.down)
            let ceil = number.rounded(.up)
            
            if direction < 0 {
                return (number - floor <= 0.51) ? UInt8(floor) : UInt8(ceil)
            }
            
            return (number - floor < 0.499) ? UInt8(floor) : UInt8(ceil)
        }
        
        let height: Int = Int(endY) - Int(startY)
        let width: Int = Int(endX) - Int(startX)
        
        var addX = (height == 0) ? Double(height) : Double(width) / Double(abs(height))
        var addY = (width == 0) ? Double(width) : Double(height) / Double(abs(width))
        
        if abs(width) > abs(height) {
            var y = Double(startY)
            addX = (width == 0) ? 0 : Double(width)/Double(abs(width))
            
            var x = Double(startX)
            while (UInt8(x) != endX) {
                drawPixel(to: &buffer,
                          x: round(number: x, direction: addX),
                          y: round(number: y, direction: addY))
                x += addX
                y += addY
            }
            
            drawPixel(to: &buffer, x: endX, y: endY)
        }
        else {
            var x = Double(startX);
            addY = (height == 0) ? 0 : Double(height)/Double(abs(height))
            
            var y = Double(startY)
            while (UInt8(y) != endY) {
                drawPixel(to: &buffer,
                          x: round(number: x, direction: addX),
                          y: round(number: y, direction: addY))
                x += addX
                y += addY
            }
            
            drawPixel(to: &buffer, x: endX, y: endY)
        }
    }
}
