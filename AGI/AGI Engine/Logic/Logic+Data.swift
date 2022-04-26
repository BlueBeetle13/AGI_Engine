//
//  Logic+Data.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-11.
//

import Foundation

// Extract Logic Codes and data from Resource Data
extension Logic {
    
    func getSubCommandsFromData(prefix: String, logicData: NSData) -> [Command] {
        
        var commands = [Command]()
        var logicPosition = 0
        
        while logicPosition < logicData.length {
            do {
                var byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
                
                // Control Code - this should always be an 'If' (0xFF)
                if let ifCommand = Logic.controlCommands[byte]?.copy(), ifCommand.name == "if" {
                    
                    // Keep reading in the conditions until we find the closing 'If'
                    byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
                    while byte != ifCommand.id {
                        
                        if let controlCommand = Logic.controlCommands[byte]?.copy() {
                            ifCommand.conditions.append(controlCommand)
                        }
                        
                        else if let conditionCommand = Logic.conditionCommands[byte]?.copy() {
                            try getDataForCommand(command: conditionCommand,
                                                  logicPosition: &logicPosition,
                                                  logicData: logicData)
                            
                            ifCommand.conditions.append(conditionCommand)
                        }
                        
                        else {
                            Utils.debug("Unknown Control Code: \(byte)")
                        }
                        
                        byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
                    }
                    
                    // After the closing control code, we have the length of the sub operations
                    var operationsLength = try Utils.getNextWord(at: &logicPosition, from: logicData)
                    
                    var positionAdvance = 0
                    
                    // The sub data exists
                    if logicData.length >= logicPosition + operationsLength {
                        
                        // There could be an 'else' condition in the last 3 bytes
                        let elseDataLength = 3
                        if logicData.length > logicPosition + elseDataLength {
                            let peekForElse = Utils.peekNextByte(at: logicPosition + operationsLength - elseDataLength,
                                                                 from: logicData)
                            
                            // There is an 'else' section, fetch the else operations
                            if peekForElse == 0xFE {
                                
                                let elseLength = Utils.peekNextWord(at: logicPosition + operationsLength - 2,
                                                                    from: logicData)
                                
                                // The else section is just the number of bytes in the condtions
                                if logicPosition + operationsLength + elseLength <= logicData.length {
                                    
                                    let elseLogicRange = NSRange(location: logicPosition + operationsLength,
                                                                 length: elseLength)
                                    let elseLogicSubData = logicData.subdata(with: elseLogicRange) as NSData
                                    
                                    ifCommand.conditionsFailedSubCommands = getSubCommandsFromData(prefix: prefix + "   ",
                                                                                                 logicData:elseLogicSubData)
                                    
                                    operationsLength -= elseDataLength
                                    positionAdvance = elseLength + elseDataLength
                                }
                            }
                        }
                        
                        let logicSubData = logicData.subdata(with: NSRange(location: logicPosition,
                                                                           length: operationsLength)) as NSData
                        
                        ifCommand.conditionsPassedSubCommands = getSubCommandsFromData(prefix: prefix + "   ",
                                                                                     logicData: logicSubData)
                        
                        positionAdvance += operationsLength
                        logicPosition += positionAdvance
                    }
                    
                    commands.append(ifCommand)
                }
                
                // Operation Code
                else if let operationCommand = Logic.operationCommands[byte]?.copy() {
                    
                    try getDataForCommand(command: operationCommand,
                                          logicPosition: &logicPosition,
                                          logicData: logicData)
                    
                    commands.append(operationCommand)
                }
                
                // Unknown
                else {
                    Utils.debug("Unknown Code: \(byte)")
                }
            } catch {
                Utils.debug("Logic getSubCommandsFromData: EndOfData")
            }
        }
        
        return commands
    }
    
    private func getDataForCommand(command: Command,
                                   logicPosition: inout Int,
                                   logicData: NSData) throws {
        
        var numberOfArguments = command.numberOfArguments
        
        // If numberOfArguments is -1, the number of arguments (in words) is the next byte
        if command.numberOfArguments == -1 {
            let numWords = try Utils.getNextByte(at: &logicPosition, from: logicData)
            numberOfArguments = Int(numWords) * 2
        }
        
        while command.data.count < numberOfArguments {
            
            let byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
            command.data.append(byte)
        }
    }
    
    func getMessages(offset: Int) throws {
        dataPosition = offset
        
        let numberOfMessages = Int(try Utils.getNextByte(at: &dataPosition, from: data))
        
        // Move past the end of messages word and the message offsets
        dataPosition += ((numberOfMessages * 2) + 2)
        
        // Now get the messages
        for messageNum in 0 ..< numberOfMessages {
    
            var message = ""
            var char = try getNextChar()
            
            while char != 0x00 && dataPosition < data.length {
                message.append(String(format: "%c", char))
                char = try getNextChar()
            }
            
            Utils.debug("Logic Room #\(id) -> Message \(messageNum): \(message)")
            messages.append(message)
        }
    }
    
    func getNextChar() throws -> UInt8 {
        var byte = try Utils.getNextByte(at: &dataPosition, from: data)
        
        // Version 2 encrypts the data using 'Avis Durgan' string
        if agiVersion == 2 {
            byte = AvisDurganEncryption.decrypt(dataPosition: messagesBytePosition, byte: byte)
            messagesBytePosition += 1
        }
        
        return byte
    }
}
