//
//  View.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-12.
//

import Foundation

class View: Resource {
    
    struct Cell {
        let width: UInt8
        let height: UInt8
        let transparencyAndMirror: UInt8
        
        let drawingData: [[UInt8]]
    }
    
    struct Loop {
        let numberOfCells: UInt8
        let cells: [Cell]
    }
    
    var loops: [Loop]
    
    private let maxCells = 255
    private let maxLoops = 255
    
    private var numberOfLoops: UInt8
    private var descriptionOffset: UInt16
    private var description: String?
    
    override init(volumeInfo: VolumeInfo, id: Int, version: Int) {
        self.numberOfLoops = 0
        self.descriptionOffset = 0
        self.loops = []
        
        super.init(volumeInfo: volumeInfo, id: id, version: version)
        
        Utils.debug("View \(id), Size: \(data.length)")
        
        // Read in the view from the vol
        dataPosition = 0
            
        // Unused
        do {
            _ = try Utils.getNextByte(at: &dataPosition, from: data)
            _ = try Utils.getNextByte(at: &dataPosition, from: data)
            
            numberOfLoops = try Utils.getNextByte(at: &dataPosition, from: data)
            descriptionOffset = UInt16(try Utils.getNextWord(at: &dataPosition, from: data))
            
            Utils.debug("# Loops: \(numberOfLoops), Description Offset: \(descriptionOffset)")
            
            // Get all the loop positions
            var loopPositions = [UInt16]()
            for _ in 0 ..< numberOfLoops {
                loopPositions.append(UInt16(try Utils.getNextWord(at: &dataPosition, from: data)))
            }
            
            // Create all the loops
            for loopPosition in loopPositions {
                Utils.debug("Loop Position: \(loopPosition)")
                
                dataPosition = Int(loopPosition)
                var cells = [Cell]()
                
                let numberOfCells = try Utils.getNextByte(at: &dataPosition, from: data)
                
                Utils.debug("# Cells: \(numberOfCells)")
                
                // Get all the cell positions
                var cellPositions = [UInt16]()
                for _ in 0 ..< numberOfCells {
                    cellPositions.append(UInt16(try Utils.getNextWord(at: &dataPosition, from: data)))
                }
                
                // Create all the cells
                for cellPosition in cellPositions {
                    dataPosition = Int(loopPosition) + Int(cellPosition)
                    
                    let width = try Utils.getNextByte(at: &dataPosition, from: data)
                    let height = try Utils.getNextByte(at: &dataPosition, from: data)
                    let transparencyAndMirror = try Utils.getNextByte(at: &dataPosition, from: data)
                    
                    // Read in the RLE drawing data
                    var drawingData = [[UInt8]]()
                    for _ in 0 ..< height {
                        
                        var rowData = [UInt8]()
                        
                        // Read in each row, 0x00 terminated
                        var byte = try Utils.getNextByte(at: &dataPosition, from: data)
                        while byte != 0x00 {
                            rowData.append(byte)
                            byte = try Utils.getNextByte(at: &dataPosition, from: data)
                        }
                        
                        drawingData.append(rowData)
                    }
                    
                    
                    let cell = Cell(width: width,
                                    height: height,
                                    transparencyAndMirror: transparencyAndMirror,
                                    drawingData: drawingData)
                    cells.append(cell)
                }
                
                // Add the loop and its cells
                loops.append(Loop(numberOfCells: numberOfCells,
                                  cells: cells))
            }
            
            // Get the description if it exists
            if descriptionOffset > 0 {
                dataPosition = Int(descriptionOffset)
                
                // Keep reading in, until null byte is reached
                var byte = try Utils.getNextByte(at: &dataPosition, from: data)
                var letters = ""
                while (byte != 0x00) {
                    let letter = String(format: "%c", byte)
                    letters.append(letter)
                    
                    byte = try Utils.getNextByte(at: &dataPosition, from: data)
                }
                
                description = letters
                Utils.debug("Description Text: \(letters)")
            }
        } catch {
            Utils.debug("View: EndOfData")
        }
    }
    
    func drawView(pictureBuffer: UnsafeMutablePointer<Pixel>,
                  priorityBuffer: UnsafeMutablePointer<Pixel>,
                  posX: Int,
                  posY: Int,
                  loopNum: Int,
                  cellNum: Int) {
        
        guard loopNum < loops.count, cellNum < loops[loopNum].cells.count else {
            Utils.debug("Invalid View: \(loopNum), \(cellNum)")
            return
        }
        
        Utils.debug("Draw View: \(id), \(loopNum), \(cellNum)")
        
        var pixelPosX = posX
        var pixelPosY = posY
        
        let cell = loops[loopNum].cells[cellNum]
        
        let transparentColor = Int(cell.transparencyAndMirror & 0x0F)
        
        Utils.debug("Lines: \(cell.drawingData.count) - \(cell.width)x\(cell.height)")
        for row in cell.drawingData {
            
            for rowItem in row {
                let color = Int(rowItem >> 4)
                let numPixels = UInt8(rowItem & 0x0F)
                
                // RLE encoded, draw the pixel the set number of times
                for _ in 0 ..< numPixels {
                    
                    if color != transparentColor {
                        Utils.drawPixel(buffer: pictureBuffer,
                                        x: pixelPosX,
                                        y: pixelPosY,
                                        color: Picture.palette[color])
                    }
                    
                    pixelPosX += 1
                }
            }
            
            pixelPosX = 0
            pixelPosY += 1
        }
    }
}
