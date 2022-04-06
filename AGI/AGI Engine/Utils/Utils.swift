//
//  Utils.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-06.
//

import Foundation

enum DataReadError: Error {
    case endOfData
}

class Utils {
    
    //static func debug(_ message: String) { print(message) }
    static func debug(_ message: String) { }
    
    static func arrayPos(_ x: Int, _ y: Int) -> Int {
        guard x < GameData.width && y < GameData.height && x >= 0 && y >= 0 else { return 0 }
        
        return (Int(y) * GameData.width) + Int(x)
    }
    
    static func drawPixel(buffer: UnsafeMutablePointer<Pixel>, x: Int, y: Int, color: Pixel) {
        buffer[arrayPos(x * 2, y)] = color
        buffer[arrayPos((x * 2) + 1, y)] = color
    }
    
    static func getPixel(buffer: UnsafeMutablePointer<Pixel>, x: Int, y: Int) -> Pixel {
        buffer[arrayPos(x * 2, y)]
    }
    
    static func getNextByte(at dataPosition: inout Int, from data: NSData) throws -> UInt8 {
        var byteBuffer: UInt8 = 0
        
        if dataPosition < data.length {
            data.getBytes(&byteBuffer, range: NSRange(location: dataPosition, length: 1))
            dataPosition += 1
            
            return byteBuffer
        }
        
        throw DataReadError.endOfData
    }
    
    static func getNextWord(at dataPosition: inout Int, from data: NSData) throws -> Int {
        let low = try Int(getNextByte(at: &dataPosition, from: data))
        let high = try Int(getNextByte(at: &dataPosition, from: data))
        return ((high << 8) + low)
    }
    
    static func peekNextByte(at dataPosition: Int, from data: NSData) -> UInt8 {
        var byteBuffer: UInt8 = 0
        
        if dataPosition < data.length {
            data.getBytes(&byteBuffer, range: NSRange(location: dataPosition, length: 1))
            
            return byteBuffer
        }
        
        return 0
    }
    
    static func peekNextWord(at dataPosition: Int, from data: NSData) -> Int {
        let low = Int(peekNextByte(at: dataPosition, from: data))
        let high = Int(peekNextByte(at: dataPosition + 1, from: data))
        return ((high << 8) + low)
    }
}
