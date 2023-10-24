//
//  Logic+Static.swift
//  AGI
//
//  Created by Phil Inglis on 2022-05-06.
//

import Foundation

extension Logic {
    
    // Views
    static var views: [Int: View] = [:]
    
    // Variables and Flags are shared across all Logic
    static let numVariables = 255
    static var variables: [UInt8] = Array.init(repeating: 0, count: numVariables)
    
    static let numFlags = 255
    static var flags: [Bool] = Array.init(repeating: false, count: numFlags)
    
    static let numScreenObjects = 256
    static var screenObjects: [ScreenObject] = []
    
    static let numStrings = 25
    static var strings: [String] = Array.init(repeating: "", count: numStrings)
    
    static func setLogicStepState() {
        variables[4] = 0
        variables[5] = 0
        flags[5] = false
        flags[6] = false
        flags[12] = false
    }
    
    static func setNewRoomGameState(roomNumber: UInt8) {
        variables[1] = variables[0]
        variables[0] = roomNumber
        variables[4] = 0
        variables[5] = 0
        variables[9] = 0
        // variables[16] = ?
        variables[2] = 0
        flags[2] = false
        flags[5] = true
    }
}
