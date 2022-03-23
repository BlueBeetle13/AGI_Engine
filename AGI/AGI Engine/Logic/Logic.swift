//
//  Logic.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-21.
//

import Foundation

class Logic: Resource {
    
    private var messages = [String]()
    private var messagesBytePosition = 0
    
    override init(gameData: GameData, volumeInfo: VolumeInfo, id: Int, version: Int) {
        super.init(gameData: gameData, volumeInfo: volumeInfo, id: id, version: version)
        
        // Get the logic commands
        
        // Get the offst to the messages section
        let messagesOffset = Utils.getNextWord(at: &dataPosition, from: data) + 2
        getMessages(offset: messagesOffset)
    }
    
    private func getMessages(offset: Int) {
        dataPosition = offset
        
        let numberOfMessages = Int(Utils.getNextByte(at: &dataPosition, from: data))
        
        // Move past the end of messages word and the message offsets
        dataPosition += ((numberOfMessages * 2) + 2)
        
        // Now get the messages
        for messageNum in 0 ..< numberOfMessages {
    
            var message = ""
            var char = getNextChar()
            
            while char != 0x00 && dataPosition < data.length {
                message.append(String(format: "%c", char))
                char = getNextChar()
            }
            
            Utils.debug("Logic Room #\(id) -> Message \(messageNum): \(message)")
            messages.append(message)
        }
    }
    
    private func getNextChar() -> UInt8 {
        var byte = Utils.getNextByte(at: &dataPosition, from: data)
        
        // Version 2 encrypts the data using 'Avis Durgan' string
        if agiVersion == 2 {
            byte = AvisDurganEncryption.decrypt(dataPosition: messagesBytePosition, byte: byte)
            messagesBytePosition += 1
        }
        
        return byte
    }
}
