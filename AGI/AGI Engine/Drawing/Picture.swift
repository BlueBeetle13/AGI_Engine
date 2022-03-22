//
//  Picture.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation
import AppKit

public struct Pixel: Equatable {
    var r,g,b: UInt8
    
    public static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
}

class Picture: Resource {
    
    static let palette: [Pixel] = [
        Pixel(r: 0, g: 0, b: 0),        // Black
        Pixel(r: 0, g: 0, b: 168),      // Blue
        Pixel(r: 0, g: 168, b: 0),      // Green
        Pixel(r: 0, g: 168, b: 168),    // Cyan
        Pixel(r: 168, g: 0, b: 0),      // Red
        Pixel(r: 168, g: 0, b: 168),    // Magenta
        Pixel(r: 168, g: 84, b: 0),     // Brown
        Pixel(r: 168, g: 168, b: 168),  // Light Grey
        Pixel(r: 84, g: 84, b: 84),     // Dark Grey
        Pixel(r: 84, g: 84, b: 255),    // Light Blue
        Pixel(r: 84, g: 255, b: 84),    // Light Green
        Pixel(r: 84, g: 255, b: 255),   // Light Cyan
        Pixel(r: 255, g: 84, b: 84),    // Light Red
        Pixel(r: 255, g: 84, b: 255),   // Light Magenta
        Pixel(r: 255, g: 255, b: 84),   // Yellow
        Pixel(r: 255, g: 255, b: 255),  // White
    ]
    static let colorBlack = palette[0]
    static let colorRed = palette[4]
    static let colorWhite = palette[15]

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
    
    let pictureWidth = 160          // Pictures are only 160 in width and each pixel is doubled width-wise
    let pictureHeight = 200 - 32    // Height is reduced by 32 to for the menu bar at the top and text entry at the bottom
    var isDrawingPicture = false
    var isDrawingPriority = false
    var currentPictureColor: Pixel
    var currentPriorityColor: Pixel
    var currentPenType = PenType(isSolid: true, isRectangle: true, penSize: 0)
    let penSizes = PenSizes()
    
    private var dataPosition = 0
    private var width = 0
    private var height = 0
    private var byteBuffer: UInt8 = 0
    private var prevByte: UInt8 = 0
    private var isVersion3BitShifting = false
    
    override init(gameData: GameData, rawData: NSData, id: Int, version: Int) {
        currentPictureColor = Picture.colorBlack
        currentPriorityColor = Picture.colorBlack
        
        super.init(gameData: gameData, rawData: rawData, id: id, version: version)
    }
    
    // In order to support bit shifting (using only 4 bits to represent colors instead of 8 as a form of compression,
    // we need our own custom get and peek byte functions
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
    
    func drawPixel(x: UInt8, y: UInt8) {
        drawPixel(x: Int(x), y: Int(y))
    }
    
    // All drawing coordinates are for 160x200, we need to stretch every pixel 2x wide
    func drawPixel(x: Int, y: Int) {
        
        if isDrawingPicture {
            Utils.drawPixel(buffer: gameData.pictureBuffer, x: x, y: y, color: currentPictureColor)
        }
        
        if isDrawingPriority {
            Utils.drawPixel(buffer: gameData.priorityBuffer, x: x, y: y, color: currentPriorityColor)
        }
    }
    
    func getPicturePixel(x: UInt8, y: UInt8) -> Pixel {
        getPicturePixel(x: Int(x), y: Int(y))
    }
    
    func getPicturePixel(x: Int, y: Int) -> Pixel {
        return Utils.getPixel(buffer: gameData.pictureBuffer, x: x, y: y)
    }
    
    func getPriorityPixel(x: UInt8, y: UInt8) -> Pixel {
        getPriorityPixel(x: Int(x), y: Int(y))
    }
    
    func getPriorityPixel(x: Int, y: Int) -> Pixel {
        return Utils.getPixel(buffer: gameData.priorityBuffer, x: x, y: y)
    }
    
    func drawToBuffer() {
        dataPosition = 0
        byteBuffer = 0
        prevByte = 0
        isDrawingPicture = false
        isDrawingPriority = false
        currentPictureColor = Picture.colorBlack
        currentPriorityColor = Picture.colorBlack
        currentPenType = PenType(isSolid: true, isRectangle: true, penSize: 0)
        isVersion3BitShifting = false
        
        while dataPosition < data.length {

            let byte = getNextByte()
            if let pictureAction = PictureAction(rawValue: byte) {
                
                // Get the picture action
                switch pictureAction {
                case PictureAction.changePictureColorEnablePictureDraw:
                    changePictureColorEnablePictureDraw()
                    
                case PictureAction.disablePictureDraw:
                    disablePictureDraw()
                    
                case PictureAction.changePriorityColorEnablePictureDraw:
                    changePictureColorEnablePriorityDraw()
                    
                case PictureAction.disablePriorityDraw:
                    disablePriorityDraw()
                    
                case PictureAction.drawYCorner:
                    drawCornerLine(isYDirection: true)
                    
                case PictureAction.drawXCorner:
                    drawCornerLine(isYDirection: false)
                    
                case PictureAction.drawAbsoluteLine:
                    drawAbsoluteLine()
                    
                case PictureAction.drawRelativeLine:
                    drawRelativeLine()
                    
                case PictureAction.fill:
                    fill()
                    
                case PictureAction.changePenSizeAndStyle:
                    changePenSizeAndStyle()
                    
                case PictureAction.plotWithPen:
                    plotWithPen()
                    
                case PictureAction.endOfPicture:
                    Utils.debug("End of Picture: \(dataPosition)")
                }
                
            } else {
                Utils.debug("Unknown Picture Action: \(byte)")
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
        if colorNum < Picture.palette.count {
            currentPictureColor = Picture.palette[colorNum]
        }
        
        Utils.debug("Enable Picture Draw: \(colorNum) \(currentPictureColor)")
    }
    
    private func disablePictureDraw() {
        Utils.debug("Disable Picture Draw")
        isDrawingPicture = false
    }
    
    private func changePictureColorEnablePriorityDraw() {
        isDrawingPriority = true
        
        var colorNum: Int = 0
        
        if agiVersion == 3 {
            
            // If shifting is on, we already have this color
            colorNum = isVersion3BitShifting ? Int(byteBuffer & 0x0F) : Int(getNextByte() >> 4)
            
            isVersion3BitShifting = !isVersion3BitShifting
        } else {
            colorNum = Int(getNextByte())
        }
        
        // Set the color
        if colorNum < Picture.palette.count {
            currentPriorityColor = Picture.palette[colorNum]
        }
        
        Utils.debug("Enable Priority Draw: \(colorNum) \(currentPriorityColor)")
    }
    
    private func disablePriorityDraw() {
        Utils.debug("Disable Priority Draw")
        isDrawingPriority = false
    }
}
