//
//  Picture.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation
import AppKit

class Picture {
    
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
    var gameData: GameData
    var isDrawingPicture = false
    var isDrawingPriority = false
    var currentPictureColor = Pixel(a: 255, r: 0, g: 0, b: 0)
    var currentPriorityColor = Pixel(a: 255, r: 172, g: 0, b: 0)
    var currentPenType = PenType(isSolid: true, isRectangle: true, penSize: 0)
    let penSizes = PenSizes()
    
    private var data: NSData
    private var dataPosition = 0
    private var byteBuffer: UInt8 = 0
    private var prevByte: UInt8 = 0
    private var agiVersion: Int
    private var isVersion3BitShifting = false
    
    init(with gameData: GameData, data: NSData, id: Int, version: Int) {
        self.gameData = gameData
        self.data = NSData.init(data: data as Data)
        self.id = id
        self.agiVersion = version
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
    
    func arrayPos(_ x: Int, _ y: Int) -> Int {
        //guard x < 320 && y < 200 && x >= 0 && y >= 0 else { return 0 }
        
        return (Int(y) * 320 * 4) + Int(x)
    }
    
    func drawPixel(x: UInt8, y: UInt8) {
        drawPixel(x: Int(x), y: Int(y))
    }
    
    // All drawing coordinates are for 160x200, we need to stretch every pixel 2x wide
    func drawPixel(x: Int, y: Int) {
        
        if isDrawingPicture {
            //gameData.pictureBuffer[arrayPos(x * 2, y)] = currentPictureColor
            //gameData.pictureBuffer[arrayPos((x * 2) + 1, y)] = currentPictureColor
            
            let pos = arrayPos(x * 2 * 4, y)
            var data = currentPictureColor
            memcpy(&gameData.bitfield[pos], &data, 4)
            memcpy(&gameData.bitfield[pos+4], &data, 4)
            /*gameData.bitfield[pos] = currentPictureColor.a
            gameData.bitfield[pos + 1] = currentPictureColor.r
            gameData.bitfield[pos + 2] = currentPictureColor.g
            gameData.bitfield[pos + 3] = currentPictureColor.b
            gameData.bitfield[pos + 4] = currentPictureColor.a
            gameData.bitfield[pos + 5] = currentPictureColor.r
            gameData.bitfield[pos + 6] = currentPictureColor.g
            gameData.bitfield[pos + 7] = currentPictureColor.b*/
        }
        
        if isDrawingPriority {
            //gameData.priorityBuffer[arrayPos(x * 2, y)] = currentPriorityColor
            //gameData.priorityBuffer[arrayPos((x * 2) + 1, y)] = currentPriorityColor
        }
    }
    
    func drawPixel(to buffer: NSMutableArray, color: Pixel, x: UInt8, y: UInt8) {
        drawPixel(to: buffer, color: color, x: Int(x), y: Int(y))
    }
    
    func drawPixel(to buffer: NSMutableArray, color: Pixel, x: Int, y: Int) {
        //buffer[arrayPos(x * 2, y)] = color
        //buffer[arrayPos((x * 2) + 1, y)] = color
        
        let pos = arrayPos(x * 2 * 4, y)
        
        var data = color
        memcpy(&gameData.bitfield[pos], &data, 4)
        memcpy(&gameData.bitfield[pos+4], &data, 4)
        /*gameData.bitfield[pos] = color.a
        gameData.bitfield[pos + 1] = color.r
        gameData.bitfield[pos + 2] = color.g
        gameData.bitfield[pos + 3] = color.b
        gameData.bitfield[pos + 4] = color.a
        gameData.bitfield[pos + 5] = color.r
        gameData.bitfield[pos + 6] = color.g
        gameData.bitfield[pos + 7] = color.b*/
    }
    
    func getPixel(from buffer: NSArray, x: UInt8, y: UInt8) -> Pixel {
        getPixel(from: buffer, x: Int(x), y: Int(y))
    }
    
    func getPixel(from buffer: NSArray, x: Int, y: Int) -> Pixel {
        let pos = arrayPos(x * 2 * 4, y)
        return Pixel(a: gameData.bitfield[pos],
                     r: gameData.bitfield[pos + 1],
                     g: gameData.bitfield[pos + 2],
                     b: gameData.bitfield[pos + 3])
        //return buffer[arrayPos(x * 2, y)] as! Pixel
    }
    
    func drawToBuffer() {
        dataPosition = 0
        byteBuffer = 0
        prevByte = 0
        isDrawingPicture = false
        isDrawingPriority = false
        currentPictureColor = Pixel(a: 255, r: 0, g: 0, b: 0)
        currentPriorityColor = Pixel(a: 255, r: 172, g: 0, b: 0)
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
        if colorNum < palette.count {
            currentPictureColor = palette[colorNum]
        }
        
        Utils.debug("Enable Picture Draw: \(colorNum) \(currentPictureColor)")
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
        if colorNum < palette.count {
            currentPriorityColor = palette[colorNum]
        }
        
        Utils.debug("Enable Priority Draw: \(colorNum) \(currentPriorityColor)")
    }
    
    private func disablePictureDraw() {
        Utils.debug("Disable Picture Draw")
        isDrawingPicture = false
    }
    
    private func disablePriorityDraw() {
        Utils.debug("Disable Priority Draw")
        isDrawingPriority = false
    }
}
