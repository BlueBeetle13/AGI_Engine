//
//  Logic.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-21.
//

import Foundation

class Logic: Resource {
    
    // Variables and Flags are shared across all Logic
    static var variables: [UInt8] = Array.init(repeating: 0, count: 255)
    static var flags: [Bool] = Array.init(repeating: false, count: 255)
    
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
    
    
    struct LogicCode {
        let name: String
        let numberOfArguments: Int
        var evaluate: (([UInt8]) -> Any)? = nil
    }

    enum LogicCodeType {
        case control
        case condition
        case operation
    }
    
    private var commands = [Command]()
    var messages = [String]()
    var messagesBytePosition = 0
    
    override init(volumeInfo: VolumeInfo, id: Int, version: Int) {
        super.init(volumeInfo: volumeInfo, id: id, version: version)
        
        var messagesOffset = 0
        
        do {
            // Get the offset to the messages section
            messagesOffset = try Utils.getNextWord(at: &dataPosition, from: data) + 2
            
            // Get the logic commands
            let logicLength = (messagesOffset == 0x00) ? data.length - 2 : messagesOffset - 2
            
            let logicData = data.subdata(with: NSRange(location: 2,
                                                       length: logicLength)) as NSData
            
            Utils.debug("Logic #\(id) -> \(logicData) \(volumeInfo.length) - \(volumeInfo.compressedLength)")
            
            commands = getSubCommandsFromData(prefix: "", logicData: logicData)
            
            if id == 140 {
                for command in commands { print("\(command.debugPrint(""))") }
            }
        } catch {
            Utils.debug("Logic: EndOfData")
        }
        
        // Get the Messages portion of the logic file
        do {
            if messagesOffset > 0 {
                try getMessages(offset: messagesOffset)
            }
        } catch {
            Utils.debug("Logic Messages: EndOfData")
        }
    }
    
    func executeLogic(_ drawGraphics: (Int, Int, Int, Int, Bool) -> Void) {
        print("Execute Logic for Room: \(id)")
        
        for command in commands {
            command.execute(drawGraphics)
        }
    }
}
