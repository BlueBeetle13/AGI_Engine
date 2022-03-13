//
//  Volume.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-24.
//

import Foundation

class Volume {
    
    private struct Header {
        var signature: UInt16
        var volumeNumber: UInt8
        var length: UInt16
        var compressedLength: UInt16
    }
    
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
    
    func getData(version: Int, volumeNumber: UInt8, position: UInt32) -> NSData? {
        
        // We don't assume the volume data is properly organized by filename
        if let data = dataStore["\(volumeNumber)"] {
            
            let dataBytes = (version == 2) ? 5 : 7
            
            // Ensure we have enough room to fetch the header
            if Int(position) + dataBytes < data.length {
                
                var buffer: [UInt8] = Array.init(repeating: 0, count: dataBytes)
                data.getBytes(&buffer, range: NSRange(location: Int(position), length: dataBytes))
                
                let compressedLength = (version == 3) ? (UInt16(buffer[6]) << 8) + UInt16(buffer[5]) : 0
                
                let header = Header(signature: (UInt16(buffer[0]) << 8) + UInt16(buffer[1]),
                                    volumeNumber: buffer[2] & 0x0F,
                                    length: (UInt16(buffer[4]) << 8) + UInt16(buffer[3]),
                                    compressedLength: compressedLength)
                
                // Ensure we have the right signature
                if (header.signature == 0x1234) {
                    print("Header: \(header)")
                    
                    let length = (version == 3) ? Int(header.compressedLength) : Int(header.length)
                    return data.subdata(with: NSRange(location: Int(position) + dataBytes,
                                                      length: length)) as NSData
                }
            }
        }
     
        return nil
    }
}
