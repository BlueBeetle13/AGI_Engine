//
//  Directory.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Foundation

struct DirectoryItem {
    var volumeNumber: UInt8
    var position: UInt32
    
    init(byte1: UInt8, byte2: UInt8, byte3: UInt8) {
        volumeNumber = byte1 >> 4
        position = (UInt32(byte1 & 0x0F) << 16) + (UInt32(byte2) << 8) + UInt32(byte3)
        /*print("B1: \(String(format: "%02X", byte1 >> 4)) -- \(String(format: "%02X", byte1 & 0x0f))")
        print("\(String(format: "%02X", byte1)) - \(String(format: "%02X", byte2)) - \(String(format: "%02X", byte3))")
        print("V: \(volumeNumber), P: \(position)")
        print("\(byte1 >> 4) - \(UInt32((byte1 & 0x0F)) << 16) - \(UInt32(byte2) << 8) - \(UInt32(byte3))")*/
    }
}

class Directory {
    
    var items: [Int: DirectoryItem] = [:]
    
    init(_ path: String) {
        
        // Load the file at the path as NSData
        if let data = NSData(contentsOfFile: path) {
            print("Directory: \(path) Total Items: \(data.length / 3)")
                        
            getDirectoryItems(from: data)
        }
    }
    
    init (_ data: NSData) {
        getDirectoryItems(from: data)
    }
    
    private func getDirectoryItems(from data: NSData) {
        
        print("Directory - Total Items: \(data.length / 3)")
        
        let bytes: [UInt8] = data.map { $0 }
        
        var index: Int = 0
        for itemNum in 0...((data.length / 3) - 1) {
            let byte1 = bytes[index]
            let byte2 = bytes[index + 1]
            let byte3 = bytes[index + 2]
            
            if (byte1 != 0xFF && byte2 != 0xFF && byte3 != 0xFF) {
                items[itemNum] = DirectoryItem(byte1: byte1, byte2: byte2, byte3: byte3)
            }
            
            //print("DirectoryItem: \(itemNum): \(items[itemNum])")
            
            index += 3
        }
    }
}
