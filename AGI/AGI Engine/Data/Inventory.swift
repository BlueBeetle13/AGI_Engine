//
//  Objects.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-06.
//

import Foundation

struct InventoryItem {
    let offset: UInt16
    let location: UInt8
    var name: String
}

/// An Object consists of an initial room number and a name. Used for inventory items
class Inventory {
    
    static let locationInitiallyCarried: UInt8 = 0xFF
    
    static func fetchInventoryItems(from path: String) -> [InventoryItem] {
        
        var dataPosition = 0
        var isEncrypted = true
        
        var items: [InventoryItem] = []
        
        if let data = NSData(contentsOfFile: path) {
            Utils.debug("Objects: \(path) Total Size: \(data.length)")
            
            func decryptNextByte() throws -> UInt8 {
                let bytePosition = dataPosition
                let byte = try Utils.getNextByte(at: &dataPosition, from: data)
                
                return isEncrypted ? AvisDurganEncryption.decrypt(dataPosition: bytePosition, byte: byte) : byte
            }
            
            func decryptNextWord() throws -> UInt16 {
                let byte1 = UInt16(try decryptNextByte())
                let byte2 = UInt16(try decryptNextByte())
                return (byte2 << 8) + byte1
            }
            
            if data.length > 2 {
                
                do {
                    // Peek ahead and see if the itemNamesOffset indicates the file is encrypted
                    let peekOffset = Utils.peekNextWord(at: dataPosition, from: data)
                    isEncrypted = peekOffset > data.length
                    
                    // Get the offset where the text for the object names begine
                    var itemNamesOffset = Int(try decryptNextWord())
                    _ = try decryptNextByte()
                    
                    // Maybe we were wrong about encyption, is the offset too much?
                    if itemNamesOffset > data.length {
                        isEncrypted = !isEncrypted
                        dataPosition = 0
                        itemNamesOffset = Int(try decryptNextWord())
                        _ = try decryptNextByte()
                    }
                    
                    // Offset must be divible by 3 (DOS) or 4 (Amiga) to indicate padding
                    let padding = (itemNamesOffset % 3 == 0) ? 3 : 4
                    
                    let numItems = itemNamesOffset / padding
                    
                    Utils.debug("Total Objects: \(numItems), Offset: \(itemNamesOffset), Encrypted: \(isEncrypted), Padding: \(padding)")
                    
                    // Get the object offsets and starting room numbers
                    for itemNum in 0 ..< numItems {
                        
                        // Move to the expected position and read the offset
                        dataPosition = (itemNum + 1) * padding
                        if dataPosition + padding < data.length {
                            let offset = try decryptNextWord() + UInt16(padding)
                            let location = try decryptNextByte()
                            
                            let item = InventoryItem(offset: offset,
                                                     location: location,
                                                     name: "")
                            
                            items.append(item)
                        }
                    }
                    
                    // Get the object names
                    dataPosition = itemNamesOffset
                    for pos in 1 ..< items.count {
                        
                        dataPosition = Int(items[pos].offset)
                        
                        var byte = try decryptNextByte()
                        
                        var name = ""
                        while byte != 0x00 {
                            name.append(String(format: "%c", byte))
                            byte = try decryptNextByte()
                        }
                        
                        items[pos].name = name
                        
                        Utils.debug("\(dataPosition): \(items[pos])")
                    }
                } catch {
                    Utils.debug("Objects: EndOfData")
                }
            }
        }
        
        return items
    }
}
