//
//  Logic.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-21.
//

import Foundation

class Logic: Resource {
    
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
            
            /*if id == 0 {
                for command in commands { print("\(command.debugPrint(""))") }
            }*/
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
    
    func processLogic(_ drawGraphics: (Int?, ScreenObject?, Bool) -> Void) {
        print("Execute Logic for Room: \(id)")
        
        for command in commands {
            
            if command.process(drawGraphics) == .stopProcessing {
                break
            }
        }
    }
}
