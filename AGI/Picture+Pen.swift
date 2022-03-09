//
//  Picture+Pen.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-04.
//

import Foundation

extension Picture {
    
    struct PenType {
        let isSolid: Bool
        let isRectangle: Bool
        let penSize: UInt8
    }
    
    func changePenSizeAndStyle() {
        let penInfo = getNextByte()

        currentPenType = PenType(isSolid: (penInfo & 0x20) == 0,
                                 isRectangle: (penInfo & 0x10) != 0,
                                 penSize: penInfo & 0x07)
        
        Utils.debug("Change Pen Size and Style: \(currentPenType)")
    }
    
    func plotWithPen() {
        Utils.debug("Plot With Pen")
        
        let penSize = Int(currentPenType.penSize)
        let penShape = currentPenType.isRectangle ? penSizes.rectanglePens : penSizes.ciclePens
        let penOffset = penSize < penSizes.offsets.count ? penSizes.offsets[penSize] : [0,0]
        let penPixels = penSize < penShape.count ? penShape[penSize] : [[1]]
        
        while (peekNextByte() < 0xF0) {
            
            // Texture
            var textureOffset = 0
            if !currentPenType.isSolid {
                let texturePatternNumber = Int(getNextByte())
                textureOffset = texturePatternNumber < penSizes.textureOffsets.count
                    ? penSizes.textureOffsets[texturePatternNumber] : 0
            }
            
            let posX = Int(getNextByte())
            let posY = Int(getNextByte())
            
            // Offset (currentPos is th center of the pen)
            var penX = posX - penOffset[0]
            var penY = posY - penOffset[1]
            
            for row in penPixels {
                for col in row {
                    
                    // This shape has a pixel here
                    if col == 1 {
                        
                        // If we aren't using the texture OR
                        // we are usng the texture but there is a pixel here
                        if currentPenType.isSolid || !currentPenType.isSolid && penSizes.texture[textureOffset] == 1 {
                            
                            // Plot within bounds
                            if penX >= 0 && penY >= 0 && penX < 160 && penY < 200 {
                                drawPixel(x: UInt8(penX), y: UInt8(penY))
                            }
                        }
                    }
                    
                    penX += 1
                    textureOffset += 1
                    if textureOffset > 254 {
                        textureOffset = 0
                    }
                }
                
                penX = posX - penOffset[0]
                penY += 1
            }
        }
    }
    
    struct PenSizes {
        let offsets = [
            
            // 0
            [0, 0],
            
            // 1
            [1, 1],
            
            // 2
            [1, 2],
            
            // 3
            [2, 3],
            
            // 4
            [2, 4],
            
            // 5
            [3, 5],
            
            // 6
            [3, 6],
            
            // 7
            [4, 7]
        ]
        
        let rectanglePens = [
            // 0
            [[1]],
            
            // 1
            [[1, 1],
             [1, 1],
             [1, 1]],
            
            // 2
            [[1, 1, 1],
             [1, 1, 1],
             [1, 1, 1],
             [1, 1, 1],
             [1, 1, 1]],
            
            // 3
            [[1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1]],
            
            // 4
            [[1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1]],
            
            // 5
            [[1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1]],
            
            // 6
            [[1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1]],
            
            // 7
            [[1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],]
        ]
        
        let ciclePens = [
            // 0
            [[1]],
            
            // 1
            [[0, 0],
             [1, 1],
             [0, 0]],
            
            // 2
            [[0, 1, 0],
             [1, 1, 1],
             [1, 1, 1],
             [1, 1, 1],
             [0, 1, 0]],
            
            // 3
            [[0, 1, 1, 0],
             [0, 1, 1, 0],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [1, 1, 1, 1],
             [0, 1, 1, 0],
             [0, 1, 1, 0]],
            
            // 4
            [[0, 0, 1, 0, 0],
             [0, 1, 1, 1, 0],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1],
             [0, 1, 1, 1, 0],
             [0, 0, 1, 0, 0]],
            
            // 5
            [[0, 0, 1, 1, 0, 0],
             [0, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 0],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1],
             [0, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 0],
             [0, 0, 1, 1, 0, 0]],
            
            // 6
            [[0, 0, 1, 1, 1, 0, 0],
             [0, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 0],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1],
             [0, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 0],
             [0, 0, 1, 1, 1, 0, 0]],
            
            // 7
            [[0, 0, 0, 1, 1, 0, 0, 0],
             [0, 0, 1, 1, 1, 1, 0, 0],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [1, 1, 1, 1, 1, 1, 1, 1],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [0, 1, 1, 1, 1, 1, 1, 0],
             [0, 0, 1, 1, 1, 1, 0, 0],
             [0, 0, 0, 1, 1, 0, 0, 0],]
        ]
        
        let texture = [0,0,1,0,0,0,0,0, 1,0,0,1,0,1,0,0, 0,0,0,0,0,0,1,0, 0,0,1,0,0,1,0,0,
                       1,0,0,1,0,0,0,0, 1,0,0,0,0,0,1,0, 1,0,1,0,0,1,0,0, 1,0,1,0,0,0,1,0,
                       1,0,0,0,0,0,1,0, 0,0,0,0,1,0,0,1, 0,0,0,0,1,0,1,0, 0,0,1,0,0,0,1,0,
                       0,0,0,1,0,0,1,0, 0,0,0,0,1,0,0,0, 0,1,0,0,0,0,1,0, 0,0,0,1,0,1,0,0,
                       1,0,0,1,0,0,0,1, 0,1,0,0,0,0,1,0, 1,0,0,1,0,0,0,1, 0,0,0,1,0,0,0,1,
                       0,0,0,0,1,0,0,0, 0,0,0,1,0,0,1,0, 0,0,1,0,0,1,0,1, 0,0,0,1,0,0,0,0,
                       0,0,1,0,0,0,1,0, 1,0,1,0,1,0,0,0, 0,0,0,1,0,1,0,0, 0,0,1,0,0,1,0,0,
                       0,0,0,0,0,0,0,0, 0,1,0,1,0,0,0,0, 0,0,1,0,0,1,0,0, 0,0,0,0,0,1,0,0]
        
        let textureOffsets = [0x00, 0x18, 0x30, 0xc4, 0xdc, 0x65, 0xeb, 0x48,
                              0x60, 0xbd, 0x89, 0x04, 0x0a, 0xf4, 0x7d, 0x6d,
                              0x85, 0xb0, 0x8e, 0x95, 0x1f, 0x22, 0x0d, 0xdf,
                              0x2a, 0x78, 0xd5, 0x73, 0x1c, 0xb4, 0x40, 0xa1,
                              0xb9, 0x3c, 0xca, 0x58, 0x92, 0x34, 0xcc, 0xce,
                              0xd7, 0x42, 0x90, 0x0f, 0x8b, 0x7f, 0x32, 0xed,
                              0x5c, 0x9d, 0xc8, 0x99, 0xad, 0x4e, 0x56, 0xa6,
                              0xf7, 0x68, 0xb7, 0x25, 0x82, 0x37, 0x3a, 0x51,
                              0x69, 0x26, 0x38, 0x52, 0x9e, 0x9a, 0x4f, 0xa7,
                              0x43, 0x10, 0x80, 0xee, 0x3d, 0x59, 0x35, 0xcf,
                              0x79, 0x74, 0xb5, 0xa2, 0xb1, 0x96, 0x23, 0xe0,
                              0xbe, 0x05, 0xf5, 0x6e, 0x19, 0xc5, 0x66, 0x49,
                              0xf0, 0xd1, 0x54, 0xa9, 0x70, 0x4b, 0xa4, 0xe2,
                              0xe6, 0xe5, 0xab, 0xe4, 0xd2, 0xaa, 0x4c, 0xe3,
                              0x06, 0x6f, 0xc6, 0x4a, 0x75, 0xa3, 0x97, 0xe1]
    }
}
