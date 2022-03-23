//
//  Volume.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-24.
//

import Foundation

enum VolumeType {
    case logic
    case picture
    case view
}

struct VolumeInfo {
    let signature: UInt16
    let volumeNumber: UInt8
    let length: UInt16
    let compressedLength: UInt16
    let type: VolumeType
    var data: NSData
}

/// Extract the data from a Volume based on the position and volume number. Ensure the header is correct, and if so return the NSData holding the data bytes
class Volume {
    
    private var dataStore: [String: NSData] = [:]
    
    func addFile(_ ext: String, _ path: String) {
        Utils.debug("Volume added: \(path)")
        
        if let fileData = NSData(contentsOfFile: path) {
            dataStore[ext] = fileData
        }
    }
    
    func clear() {
        dataStore.removeAll()
    }
    
    func getData(version: Int, volumeNumber: UInt8, position: UInt32, type: VolumeType) -> VolumeInfo? {
        
        // We don't assume the volume data is properly organized by filename
        if let data = dataStore["\(volumeNumber)"] {
            
            // Version 3 games are 7 bytes instead of 5
            let dataBytes = (version == 2) ? 5 : 7
            
            // Ensure we have enough room to fetch the header
            if Int(position) + dataBytes < data.length {
                
                var buffer: [UInt8] = Array.init(repeating: 0, count: dataBytes)
                data.getBytes(&buffer, range: NSRange(location: Int(position), length: dataBytes))
                
                let signature = (UInt16(buffer[0]) << 8) + UInt16(buffer[1])
                
                // Ensure we have the right signature
                if (signature == 0x1234) {
                    
                    let volumeNumber = buffer[2] & 0x0F
                    let volumeLength = (UInt16(buffer[4]) << 8) + UInt16(buffer[3])
                    
                    // In version 3, the extra 2 bytes determine messages offset (Logic)
                    // or compressed length (Picture, View)
                    let compressedLength = (version == 3) ? (UInt16(buffer[6]) << 8) + UInt16(buffer[5]) : 0
                    
                    var dataLength = Int(volumeLength)
                    
                    // For version 3, Picture or View, the 'extra' gives the compressed size
                    if (version == 3 && type != VolumeType.logic) {
                        dataLength = Int(compressedLength)
                    }
                    
                    let volumeInfo = VolumeInfo(signature: signature,
                                                volumeNumber: volumeNumber,
                                                length: volumeLength,
                                                compressedLength: compressedLength,
                                                type: type,
                                                data: data.subdata(with: NSRange(location: Int(position) + dataBytes,
                                                                                 length: dataLength)) as NSData)
                    
                    Utils.debug("Volume Info: \(volumeInfo)")
                    return volumeInfo
                }
            }
        }
     
        return nil
    }
}
