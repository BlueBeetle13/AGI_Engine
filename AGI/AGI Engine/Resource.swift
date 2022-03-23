//
//  Resource.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-21.
//

import Foundation

class Resource {
    
    let id: Int
    var gameData: GameData
    var agiVersion: Int
    var data: NSData
    
    var dataPosition = 0
    
    init(gameData: GameData, volumeInfo: VolumeInfo, id: Int, version: Int) {
        self.id = id
        self.gameData = gameData
        self.agiVersion = version
        
        // If this is version 3, and this is not a picture resource,
        // the data is compressed with LZW. We need to decompress first
        if version == 3, volumeInfo.type != VolumeType.picture {
            self.data = LZWCompression().decompress(input: volumeInfo.data)
        }
        
        // Version 2 just uses the data as-is
        else {
            self.data = NSData.init(data: volumeInfo.data as Data)
        }
    }
}
