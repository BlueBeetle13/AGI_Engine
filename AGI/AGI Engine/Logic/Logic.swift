//
//  Logic.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-21.
//

import Foundation

class Logic: Resource {
    
    private var commands = [LogicCommand]()
    private var messages = [String]()
    private var messagesBytePosition = 0
    
    override init(gameData: GameData, volumeInfo: VolumeInfo, id: Int, version: Int) {
        super.init(gameData: gameData, volumeInfo: volumeInfo, id: id, version: version)
        
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
                for command in commands { print("\(command.print(""))") }
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
    
    private func getSubCommandsFromData(prefix: String, logicData: NSData) -> [LogicCommand] {
        
        var commands = [LogicCommand]()
        var logicPosition = 0
        
        while logicPosition < logicData.length {
            do {
                var byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
                
                // Control Code - this should always be an 'If' (0xFF)
                if byte == CodeName.codeIf.rawValue, let controlCode = LogicCodes.controlCodes[byte] {
                    
                    let command = LogicControlCommand(code: controlCode)
                    
                    // Keep reading in the conditions until we find the closing 'If'
                    byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
                    while byte != CodeName.codeIf.rawValue {
                        
                        if let conditionControlCode = LogicCodes.controlCodes[byte] {
                            command.conditions.append(LogicCommand(code: conditionControlCode))
                        }
                        
                        else if let conditionCode = LogicCodes.conditionCodes[byte] {
                            command.conditions.append(try getOperationComand(operationCode: conditionCode,
                                                                             logicPosition: &logicPosition,
                                                                             logicData: logicData))
                        }
                        
                        else {
                            Utils.debug("Unknown Control Code")
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
                            if peekForElse == CodeName.codeElse.rawValue {
                                
                                let elseLength = Utils.peekNextWord(at: logicPosition + operationsLength - 2,
                                                                    from: logicData)
                                
                                // The else section is just the number of bytes in the condtions
                                if logicPosition + operationsLength + elseLength <= logicData.length {
                                    
                                    let elseLogicRange = NSRange(location: logicPosition + operationsLength,
                                                                 length: elseLength)
                                    let elseLogicSubData = logicData.subdata(with: elseLogicRange) as NSData
                                    
                                    command.conditionsFailedSubCommands = getSubCommandsFromData(prefix: prefix + "   ",
                                                                                                 logicData:elseLogicSubData)
                                    
                                    operationsLength -= elseDataLength
                                    positionAdvance = elseLength + elseDataLength
                                }
                            }
                        }
                        
                        let logicSubData = logicData.subdata(with: NSRange(location: logicPosition,
                                                                           length: operationsLength)) as NSData
                        
                        command.conditionsPassedSubCommands = getSubCommandsFromData(prefix: prefix + "   ",
                                                                                     logicData: logicSubData)
                        
                        positionAdvance += operationsLength
                        logicPosition += positionAdvance
                    }
                    
                    commands.append(command)
                }
                
                // Operation Code
                else if let operationCode = LogicCodes.operationCodes[byte] {
                    
                    commands.append(try getOperationComand(operationCode: operationCode,
                                                           logicPosition: &logicPosition,
                                                           logicData: logicData))
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
    
    private func getOperationComand(operationCode: LogicCode,
                                    logicPosition: inout Int,
                                    logicData: NSData) throws -> LogicOperationCommand {
        
        let command = LogicOperationCommand(code: operationCode)
        
        var numberOfArguments = operationCode.numberOfArguments
        
        // If this the "said" command, the number of arguments (in words) is the next byte
        if operationCode.name == LogicCodes.conditionCodes[CodeName.codeSaid.rawValue]?.name {
            let numWords = try Utils.getNextByte(at: &logicPosition, from: logicData)
            numberOfArguments = Int(numWords) * 2
        }
        
        while command.data.count < numberOfArguments {
            
            let byte = try Utils.getNextByte(at: &logicPosition, from: logicData)
            command.data.append(byte)
        }
        
        return command
    }
    
    private func getMessages(offset: Int) throws {
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
    
    private func getNextChar() throws -> UInt8 {
        var byte = try Utils.getNextByte(at: &dataPosition, from: data)
        
        // Version 2 encrypts the data using 'Avis Durgan' string
        if agiVersion == 2 {
            byte = AvisDurganEncryption.decrypt(dataPosition: messagesBytePosition, byte: byte)
            messagesBytePosition += 1
        }
        
        return byte
    }
}
