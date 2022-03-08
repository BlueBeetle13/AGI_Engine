//
//  Words.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-05.
//

import Foundation

struct Word {
    let wordId: UInt16
    let text: String
}

class Words {
    
    private static let maxWordCharacters = 64
    static let wordIdIgnore: UInt16 = 0
    static let wordIdAnyword: UInt16 = 1
    
    static func fetchWords(from path: String) -> [Word] {
        
        var words: [Word] = []
        
        if let data = NSData(contentsOfFile: path) {
            Utils.debug("Words: \(path) Total Size: \(data.length)")
            
            // The start of the file is the offsets for each letter, this isn't needed to extract the words, so skip
            var dataPosition: Int = 26 * 2
            
            var previousWord: String = ""
            var letters: String = ""
            
            // Start fetching characters until we fine the end of file word
            while dataPosition < data.length {
                
                var letterPos = 0
                
                // Get the letter count for reusing the letter of the previous word.
                // This will be 0 when we start a new letter
                let reuseLetterCount = Int(Utils.getNextByte(at: &dataPosition, from: data))
                
                // Get the first letter of the word, and continue getting letters until we reach the 0x00 character
                var byte = Utils.getNextByte(at: &dataPosition, from: data)
                while letterPos < maxWordCharacters && byte != 0x00 && byte != 0x01 {

                    // Decrpyt the letter and add to the text
                    let letter = String(format: "%c", ((byte ^ 0x7F) & 0x7F))
                    letters.append(letter)
                    
                    byte = Utils.getNextByte(at: &dataPosition, from: data)
                    letterPos += 1
                }
                
                // Now get the WordId
                let wordId = (UInt16(byte) << 8) + UInt16(Utils.getNextByte(at: &dataPosition, from: data))
                
                // We finished getting the word, combine with the reused letters of the previous word
                let text = "\(previousWord.prefix(reuseLetterCount))\(letters)"
                words.append(Word(wordId: wordId, text: text))
                    
                previousWord = text
                letters = ""
            }
        }
        
        return words
    }
}
