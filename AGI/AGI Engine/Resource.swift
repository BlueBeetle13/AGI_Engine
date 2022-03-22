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
    
    init(gameData: GameData, rawData: NSData, id: Int, version: Int) {
        self.id = id
        self.gameData = gameData
        self.agiVersion = version
        self.data = NSData.init(data: rawData as Data)
    }
}
