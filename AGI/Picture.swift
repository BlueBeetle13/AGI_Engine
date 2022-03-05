//
//  Picture.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation
import AppKit

class Picture {
    
    //func debug(_ message: String) { print(message) }
    func debug(_ message: String) { }
    
    enum PaletteColor: Int {
        case black = 0
        case white = 15
    }

    let palette: [Pixel] = [
        Pixel(a: 255, r: 0, g: 0, b: 0), // Black
        Pixel(a: 255, r: 0, g: 0, b: 172), // Blue
        Pixel(a: 255, r: 0, g: 172, b: 0), // Green
        Pixel(a: 255, r: 0, g: 172, b: 172), // Cyan
        Pixel(a: 255, r: 172, g: 0, b: 0), // Red
        Pixel(a: 255, r: 172, g: 0, b: 172), // Magenta
        Pixel(a: 255, r: 172, g: 86, b: 0), // Brown
        Pixel(a: 255, r: 172, g: 172, b: 172), // Light Grey
        Pixel(a: 255, r: 86, g: 86, b: 86), // Dark Grey
        Pixel(a: 255, r: 86, g: 86, b: 255), // Light Blue
        Pixel(a: 255, r: 86, g: 255, b: 86), // Light Green
        Pixel(a: 255, r: 86, g: 255, b: 255), // Light Cyan
        Pixel(a: 255, r: 255, g: 86, b: 86), // Light Red
        Pixel(a: 255, r: 255, g: 86, b: 255), // Light Magenta
        Pixel(a: 255, r: 255, g: 255, b: 86), // Yellow
        Pixel(a: 255, r: 255, g: 255, b: 255), // White
    ]

    enum PictureAction: UInt8 {
        case changePictureColorEnablePictureDraw = 0xF0
        case disablePictureDraw = 0xF1
        case changePriorityColorEnablePictureDraw = 0xF2
        case disablePriorityDraw = 0xF3
        case drawYCorner = 0xF4
        case drawXCorner = 0xF5
        case drawAbsoluteLine = 0xF6
        case drawRelativeLine = 0xF7
        case fill = 0xF8
        case changePenSizeAndStyle = 0xF9
        case plotWithPen = 0xFA
        case endOfPicture = 0xFF
        
    }
    
    let id: Int
    var isDrawingPicture = false
    var currentColor = Pixel(a: 255, r: 0, g: 0, b: 0)
    var currentPenType = PenType(isSolid: true, isRectangle: true, penSize: 0)
    let penSizes = PenSizes()
    
    private var data: NSData
    private var dataPosition = 0
    private var byteBuffer: UInt8 = 0
    private var prevByte: UInt8 = 0
    private var agiVersion: Int
    private var isVersion3BitShifting = false
    
    init(with data: NSData, id: Int, version: Int) {
        self.id = id
        self.agiVersion = version
        self.data = NSData.init(data: data as Data)
    }
    
    func arrayPos(x: UInt8, y: UInt8) -> Int {
        guard x < 160 && y < 200 && x >= 0 && y >= 0 else { return 0 }
        
        return (Int(y) * 160) + Int(x)
    }
    
    func getNextByte() -> UInt8 {
        prevByte = byteBuffer
        
        if dataPosition < data.length {
            data.getBytes(&byteBuffer, range: NSRange(location: dataPosition, length: 1))
            dataPosition += 1
            
            if isVersion3BitShifting {
                return (prevByte << 4) + (byteBuffer >> 4)
            } else {
                return byteBuffer
            }
        }
        
        return PictureAction.endOfPicture.rawValue
    }
    
    func peekNextByte() -> UInt8 {
        
        var peekBuffer: UInt8 = 0
        
        if dataPosition < data.length {
            data.getBytes(&peekBuffer, range: NSRange(location: dataPosition, length: 1))
            
            if isVersion3BitShifting {
                return (byteBuffer << 4) + (peekBuffer >> 4)
            } else {
                return peekBuffer
            }
        }
        
        return PictureAction.endOfPicture.rawValue
    }
    
    func drawToBuffer(buffer: inout [Pixel]) {
        dataPosition = 0
        byteBuffer = 0
        prevByte = 0
        isDrawingPicture = false
        currentColor = palette[0]
        currentPenType = PenType(isSolid: true, isRectangle: true, penSize: 0)
        isVersion3BitShifting = false
        
        while dataPosition < data.length {

            if let pictureAction = PictureAction(rawValue: getNextByte()) {
                
                // Get the picture action
                switch pictureAction {
                case PictureAction.changePictureColorEnablePictureDraw:
                    changePictureColorEnablePictureDraw()
                    
                case PictureAction.disablePictureDraw:
                    disablePictureDraw()
                    
                case PictureAction.changePriorityColorEnablePictureDraw:
                    changePictureColorEnablePriorityDraw()
                    
                case PictureAction.disablePriorityDraw:
                    debug("Disable Priority Draw")
                    
                case PictureAction.drawYCorner:
                    drawCornerLine(isYDirection: true, buffer: &buffer)
                    
                case PictureAction.drawXCorner:
                    drawCornerLine(isYDirection: false, buffer: &buffer)
                    
                case PictureAction.drawAbsoluteLine:
                    drawAbsoluteLine(buffer: &buffer)
                    
                case PictureAction.drawRelativeLine:
                    drawRelativeLine(buffer: &buffer)
                    
                case PictureAction.fill:
                    fill(buffer: &buffer)
                    
                case PictureAction.changePenSizeAndStyle:
                    changePenSizeAndStyle(buffer: &buffer)
                    
                case PictureAction.plotWithPen:
                    plotWithPen(buffer: &buffer)
                    
                case PictureAction.endOfPicture:
                    debug("End of Picture: \(dataPosition)")
                }
            }
        }
    }
    
    private func changePictureColorEnablePictureDraw() {
        isDrawingPicture = true
        
        var colorNum: Int = 0
        
        if agiVersion == 3 {
            
            // If shifting is on, we already have this color
            colorNum = isVersion3BitShifting ? Int(byteBuffer & 0x0F) : Int(getNextByte() >> 4)
            
            isVersion3BitShifting = !isVersion3BitShifting
        } else {
            colorNum = Int(getNextByte())
        }
        
        // Set the color
        if colorNum < palette.count {
            currentColor = palette[colorNum]
        }
        
        debug("Enable Picture Draw: \(colorNum) \(currentColor)")
    }
    
    private func changePictureColorEnablePriorityDraw() {
        
        var colorNum: Int = 0
        
        if agiVersion == 3 {
            
            // If shifting is on, we already have this color
            colorNum = isVersion3BitShifting ? Int(byteBuffer & 0x0F) : Int(getNextByte() >> 4)
            
            isVersion3BitShifting = !isVersion3BitShifting
        } else {
            colorNum = Int(getNextByte())
        }
        
        debug("Enable Priority Draw: \(colorNum) \(currentColor)")
    }
    
    private func disablePictureDraw() {
        debug("Disable Picture Draw")
        isDrawingPicture = false
    }
}
