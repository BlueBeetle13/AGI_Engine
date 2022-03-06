//
//  Utils.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-06.
//

import Foundation

class Utils {
    
    static func getNextByte(at dataPosition: inout Int, from data: NSData) -> UInt8 {
        var byteBuffer: UInt8 = 0
        
        if dataPosition < data.length {
            data.getBytes(&byteBuffer, range: NSRange(location: dataPosition, length: 1))
            dataPosition += 1
            
            return byteBuffer
        }
        
        return 0
    }
    
    static func peekNextByte(at dataPosition: Int, from data: NSData) -> UInt8 {
        var byteBuffer: UInt8 = 0
        
        if dataPosition < data.length {
            data.getBytes(&byteBuffer, range: NSRange(location: dataPosition, length: 1))
            
            return byteBuffer
        }
        
        return 0
    }
    
    static func getWord(at dataPosition: inout Int, from data: NSData) -> Int {
        let low = Int(getNextByte(at: &dataPosition, from: data))
        let high = Int(getNextByte(at: &dataPosition, from: data))
        return ((high << 8) + low)
    }
}
