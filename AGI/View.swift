//
//  View.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-12.
//

import Foundation

class View {
    
    struct Cell {
        let width: UInt8
        let height: UInt8
        let transparencyAndMirror: UInt8
    }
    
    struct Loop {
        let numberOfCells: UInt8
        let cells: [Cell]
    }
    
    
    let id: Int
    var gameData: GameData
    
    private let maxCells = 255
    private let maxLoops = 255
    private var data: NSData
    private var dataPosition = 0
    
    private var numberOfLoops: UInt8
    private var descriptionOffset: UInt16
    private var description: String?
    private var loops: [Loop]
    
    init(gameData: GameData, data: NSData, id: Int, version: Int) {
        self.id = id
        self.gameData = gameData
        
        self.data = NSData.init(data: data as Data)
        self.numberOfLoops = 0
        self.descriptionOffset = 0
        self.loops = []
        
        // Read in the view from the vol
        dataPosition = 0
            
        // Unused
        _ = Utils.getNextByte(at: &dataPosition, from: data)
        _ = Utils.getNextByte(at: &dataPosition, from: data)
        
        numberOfLoops = Utils.getNextByte(at: &dataPosition, from: data)
        descriptionOffset = UInt16(Utils.getNextWord(at: &dataPosition, from: data))
        
        Utils.debug("# Loops: \(numberOfLoops), Description Offset: \(descriptionOffset)")
        
        // Get all the loop positions
        var loopPositions = [UInt16]()
        for _ in 0..<numberOfLoops {
            loopPositions.append(UInt16(Utils.getNextWord(at: &dataPosition, from: data)))
        }
        
        // Create all the loops
        for loopPosition in loopPositions {
            dataPosition = Int(loopPosition)
            var cells = [Cell]()
            
            let numberOfCells = Utils.getNextByte(at: &dataPosition, from: data)
            
            Utils.debug("# Cells: \(numberOfCells)")
            
            // Get all the cell positions
            var cellPositions = [UInt16]()
            for _ in 0..<numberOfCells {
                cellPositions.append(UInt16(Utils.getNextWord(at: &dataPosition, from: data)))
            }
            
            // Create all the cells
            for cellPosition in cellPositions {
                dataPosition = Int(cellPosition)
                
                cells.append(Cell(width: Utils.getNextByte(at: &dataPosition, from: data),
                                  height: Utils.getNextByte(at: &dataPosition, from: data),
                                  transparencyAndMirror: Utils.getNextByte(at: &dataPosition, from: data)))
            }
            
            // Add the loop and its cells
            loops.append(Loop(numberOfCells: numberOfCells,
                              cells: cells))
        }
        
        // Get the description if it exists
        if descriptionOffset > 0 {
            dataPosition = Int(descriptionOffset)
            
            // Keep reading in, until null byte is reached
            var byte = Utils.getNextByte(at: &dataPosition, from: data)
            var letters = ""
            while (byte != 0x00) {
                let letter = String(format: "%c", byte)
                letters.append(letter)
                
                byte = Utils.getNextByte(at: &dataPosition, from: data)
            }
            
            description = letters
            Utils.debug("Description Text: \(letters)")
        }
    }
}
