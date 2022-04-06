//
//  LZWExpand.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-13.
//

import Foundation

class AvisDurganEncryption {
    
    private static let encryptionKeys: [UInt8] = [0x41, 0x76, 0x69, 0x73,
                                                  0x20, 0x44, 0x75, 0x72,
                                                  0x67, 0x61, 0x6E] // Avis Durgan
    
    static func decrypt(dataPosition: Int, byte: UInt8) -> UInt8 {
        
        // Encryption pos cycles through the keys
        let encryptionKeyPos = dataPosition < encryptionKeys.count ? dataPosition : dataPosition % encryptionKeys.count
        
        return byte ^ encryptionKeys[encryptionKeyPos]
    }
}

class LZWCompression {
    
    // Special code: end of data code tells us to stop decompressing
    private let codeEndOfData: UInt32 = 257
    
    // Sepcial code: start overcode tells us to reset all bits and lookup tale
    private let codeStartOver: UInt32 = 256
    
    // AGI only supports up to 12 bits for codes, after that we reset back to initial values
    private let maximumBitsInLookupTable = 12
    
    // Start with 9 bits as we need to represent all 256 byes (0-255) plus the 2 special codes above
    private let startingBitsInLookupTable = 9
    

    // Reading the input buffer, we keep a buffer of, at most, 32 bits. We need to keep a bit count as the codes we
    // read in don't align evenly into bytes
    private var inputBytesRead = 0
    private var inputBitCount = 0
    private var inputBitBuffer: UInt32 = 0
    private var inputByteArray = [UInt8]()
    
    // Lookup Table
    private var numberOfBitsInLookupTable = 0
    private var maxLookupTableValue = 0
    private var lookupTable = [UInt32: [UInt8]]()
    
    
    /// Decompress the given NSData using LZW and return the expanded data as NSData
    func decompress(input: NSData) -> NSData {
        
        // Get the bytes from the input
        let count = input.length / MemoryLayout<UInt8>.size
        inputByteArray = Array.init(repeating: 0, count: count)
        input.getBytes(&inputByteArray, length: count)
        
        // Create the output buffer
        var outputByteArray = [UInt8]()
        
        // Start at 9 bits in the table
        setNumberOfBitsInLookupTable(value: startingBitsInLookupTable)
        resetLookupTable()
        
        var prevTableEntryKey: UInt32? = nil
        var nextTableEntryKey: UInt32 = 258
        
        // Start reading in the first code, it seems to always start with code 256 (start over)
        var inputCodeCurrent = getNextInputCode()
        
        // Continue until the end of data or the special end of data code
        while (inputBitCount > startingBitsInLookupTable) && (inputCodeCurrent != codeEndOfData) {
            
            // In order to avoid needing more than 12 bits to store the code, this verson of LZW resets and starts again
            if (inputCodeCurrent == codeStartOver) {
                nextTableEntryKey = 258
                
                setNumberOfBitsInLookupTable(value: startingBitsInLookupTable)
                resetLookupTable()
                prevTableEntryKey = nil
                
                inputCodeCurrent = getNextInputCode()
            }
            
            // Continue reading in data
            else {
                
                // Update the previous entry with the first byte of this entry
                if let previousKey = prevTableEntryKey, let currentFirstByte = lookupTable[inputCodeCurrent]?.first {
                    lookupTable[previousKey]?.append(currentFirstByte)
                }
                
                // Item should always be found in the lookup table. I have seen some implementations of LZW
                // that creates future entries (a couple ahead at most), but I tested all AGI games and none of
                // them require this
                if let lookupTableEntry = lookupTable[inputCodeCurrent] {
                    
                    // Add this entry to the lookup table for the next key, we will add the last byte with the next pass
                    lookupTable[nextTableEntryKey] = lookupTableEntry
                    
                    // Output the data for this entry
                    outputByteArray.append(contentsOf: lookupTableEntry)
                }
                
                // We need to increase the bits in the lookup table to handle larger keys
                if nextTableEntryKey > maxLookupTableValue {
                    setNumberOfBitsInLookupTable(value: numberOfBitsInLookupTable + 1)
                }
                
                prevTableEntryKey = nextTableEntryKey
                nextTableEntryKey += 1
                
                inputCodeCurrent = getNextInputCode()
            }
        }
        
        Utils.debug("Decompressed: \(outputByteArray.count) from: \(input.length)")
        
        return NSData(bytes: outputByteArray, length: outputByteArray.count)
    }
    
    /// Reset the lookup table with the first 255 items since we always know what these will be
    private func resetLookupTable() {
        lookupTable.removeAll()
        
        for index in 0 ... 255 {
            lookupTable[UInt32(index)] = [UInt8(index)]
        }
    }
    
    /// We use the minimum (starting at 9) bits to store codes, increase this amount (up to 12) as needed
    private func setNumberOfBitsInLookupTable(value: Int) {
        guard value != maximumBitsInLookupTable else { return }

        numberOfBitsInLookupTable = value
        maxLookupTableValue = (1 << numberOfBitsInLookupTable) - 1
    }
    
    /// Return the next code from the input buffer.  Read up to 32 bits (4 bytes) into the UInt32, then pull out the number of bits we need.
    /// Data is not stored byte aligned to save space, so we need to pull off a set number of bits. inputBitCount is the total number of bits we have read
    private func getNextInputCode() -> UInt32 {
        
        // Ensure the UInt32 is as close the full as possible
        while inputBitCount <= 24 && inputBytesRead < inputByteArray.count {
            inputBitBuffer += (UInt32(inputByteArray[inputBytesRead]) << inputBitCount)
            
            inputBytesRead += 1
            inputBitCount += 8
        }
        
        let code: UInt32 = inputBitBuffer & (UInt32(pow(2, Double(numberOfBitsInLookupTable))) - 1)
        inputBitBuffer = inputBitBuffer >> numberOfBitsInLookupTable
        inputBitCount -= numberOfBitsInLookupTable
        
        return code;
    }
}
