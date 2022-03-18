//
//  Objects.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-06.
//

import Foundation

struct Object {
    let offset: UInt16
    let location: UInt8
    var name: String
}

/// An Object consists of an initial room number and a name. Used for inventory items
class Objects {
    
    static let locationInitiallyCarried: UInt8 = 0xFF
    
    static func fetchObjects(from path: String) -> [Object] {
        
        let encryptionKeys: [UInt8] = [0x41, 0x76, 0x69, 0x73,
                                       0x20, 0x44, 0x75, 0x72,
                                       0x67, 0x61, 0x6E] // Avis Durgan
        var dataPosition = 0
        var isEncrypted = true
        
        var objects: [Object] = []
        
        if let data = NSData(contentsOfFile: path) {
            Utils.debug("Objects: \(path) Total Size: \(data.length)")
            
            func decryptNextByte() -> UInt8 {
                // Encryption pos cycles through the keys
                let encryptionKeyPos = dataPosition < encryptionKeys.count ?
                    dataPosition : dataPosition % encryptionKeys.count
                
                let byte = Utils.getNextByte(at: &dataPosition, from: data)
                
                return isEncrypted ? byte ^ encryptionKeys[encryptionKeyPos] : byte
            }
            
            func decryptNextWord() -> UInt16 {
                let byte1 = UInt16(decryptNextByte())
                let byte2 = UInt16(decryptNextByte())
                return (byte2 << 8) + byte1
            }
            
            if data.length > 2 {
                
                // Peek ahead and see if the itemNamesOffset indicates the file is encrypted
                let peekOffset = Utils.peekNextWord(at: dataPosition, from: data)
                isEncrypted = peekOffset > data.length
                
                // Get the offset where the text for the object names begine
                var itemNamesOffset = Int(decryptNextWord())
                _ = decryptNextByte()
                
                // Maybe we were wrong about encyption, is the offset too much?
                if itemNamesOffset > data.length {
                    isEncrypted = !isEncrypted
                    dataPosition = 0
                    itemNamesOffset = Int(decryptNextWord())
                    _ = decryptNextByte()
                }
                
                // Offset must be divible by 3 (DOS) or 4 (Amiga) to indicate padding
                let padding = (itemNamesOffset % 3 == 0) ? 3 : 4
                
                let numObjects = itemNamesOffset / padding
                
                Utils.debug("Total Objects: \(numObjects), Offset: \(itemNamesOffset), Encrypted: \(isEncrypted), Padding: \(padding)")
                
                // Get the object offsets and starting room numbers
                for objectNum in 0 ..< numObjects {
                    
                    // Move to the expected position and read the offset
                    dataPosition = (objectNum + 1) * padding
                    if dataPosition + padding < data.length {
                        let offset = decryptNextWord() + UInt16(padding)
                        let location = decryptNextByte()
                        
                        let object = Object(offset: offset,
                                            location: location,
                                            name: "")
                        
                        objects.append(object)
                    }
                }
                
                // Get the object names
                dataPosition = itemNamesOffset
                for pos in 1 ..< objects.count {
                    
                    dataPosition = Int(objects[pos].offset)
                    
                    var byte = decryptNextByte()
                    
                    var name = ""
                    while byte != 0x00 {
                        name.append(String(format: "%c", byte))
                        byte = decryptNextByte()
                    }
                    
                    objects[pos].name = name
                    
                    Utils.debug("\(dataPosition): \(objects[pos])")
                }
            }
        }
        
        return objects
    }
}
