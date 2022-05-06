//
//  ViewController.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Cocoa
import CoreGraphics

extension NSImage {
    convenience init?(pixels: UnsafeRawPointer, width: Int, height: Int) {
        let data = Data(bytes: pixels, count: width * height * MemoryLayout<Pixel>.size) as CFData
        guard let providerRef = CGDataProvider(data: data)  else { return nil }

        guard let cgim = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 24,
                bytesPerRow: width * MemoryLayout<Pixel>.size,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                provider: providerRef,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim, size: NSSize(width: width, height: height))
    }
}

class ViewController: NSViewController,
                      NSTableViewDataSource,
                      NSTableViewDelegate {
    
    @IBOutlet weak var screenView: NSImageView!
    @IBOutlet weak var priorityView: NSImageView!
    @IBOutlet weak var picturesTableView: NSTableView!
    @IBOutlet weak var viewsTableView: NSTableView!
    @IBOutlet weak var logicTableView: NSTableView!
    @IBOutlet weak var doubleResolutionButton: NSButton!
    
    // Rendering
    var renderStartTime: TimeInterval = 0
    
    let gameData = GameData()
    var pictures: [Picture] = []
    var views: [View] = []
    var logic: [Logic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturesTableView.dataSource = self
        picturesTableView.delegate = self
        
        viewsTableView.dataSource = self
        viewsTableView.delegate = self
        
        logicTableView.dataSource = self
        logicTableView.delegate = self
    }
    
    @IBAction func onLoadButtonPressed(_ sender: Any) {
        
        let dialog = NSOpenPanel()
        dialog.title = "Select Game Folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let path = dialog.url?.path {
                print("Folder: \(path)")
                
                gameData.loadGameData(from: path,
                                      loadFinished: { pictures, views, logic in
                                        self.pictures = Array(pictures.values).sorted(by: { $0.id < $1.id })
                                        self.views = Array(views.values).sorted(by: { $0.id < $1.id })
                                        self.logic = Array(logic.values).sorted(by: { $0.id < $1.id })
                                        
                                        DispatchQueue.main.async {
                                            self.picturesTableView.reloadData()
                                            self.picturesTableView.scrollRowToVisible(0)
                                            //self.picturesTableView.selectRowIndexes(.init(integer: 0),
                                            //                                        byExtendingSelection: false)
                                            
                                            self.viewsTableView.reloadData()
                                            self.viewsTableView.scrollRowToVisible(0)
                                            
                                            self.logicTableView.reloadData()
                                            self.logicTableView.scrollRowToVisible(0)
                                        }
                                      },
                                      redraw: {
                                        
                                        print("Time1: \(Date().timeIntervalSince1970 - self.renderStartTime)")
                                        
                                        // Redraw image
                                        DispatchQueue.main.async {
                                            
                                            // Picture
                                            if let image = NSImage.init(pixels: self.gameData.pictureBuffer,
                                                                        width: GameData.width,
                                                                        height: GameData.height)  {
                                                
                                                self.screenView.image = image
                                            }
                                            
                                            // Priority
                                            if let image = NSImage.init(pixels: self.gameData.priorityBuffer,
                                                                        width: GameData.width,
                                                                        height: GameData.height)  {
                                                
                                                self.priorityView.image = image
                                            }
                                            
                                            print("Time2: \(Date().timeIntervalSince1970 - self.renderStartTime)")
                                        }
                                      })
            }
        }
    }
    
    @IBAction func onLogicStepButtonPressed(_ sender: Any) {
        gameData.stepLogic()
    }
    
    @IBAction func onDoubleResolutionChecked(_ sender: Any) {
        if doubleResolutionButton.state == .on {
            screenView.imageScaling = .scaleProportionallyUpOrDown
            priorityView.imageScaling = .scaleProportionallyUpOrDown
        } else {
            screenView.imageScaling = .scaleNone
            priorityView.imageScaling = .scaleNone
        }
    }
    
    // MARK: - TableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // Pictures
        if tableView == picturesTableView {
            return pictures.count
        }
        
        // Views
        else if tableView == viewsTableView {
            
            var numRows = 0
            for view in views {
                for loop in view.loops {
                    for _ in loop.cells {
                        numRows += 1
                    }
                }
            }
            return numRows
        }
        
        // Logic
        else {
            return logic.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Pictures
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "pictureCellId"),
                                     owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(pictures[row].id)"
            return cell
        }
        
        // Views
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "viewCellId"),
                                     owner: nil) as? NSTableCellView {
            
            var numRows = 0
            for view in views {
                for (loopIndex, loop) in view.loops.enumerated() {
                    for (cellIndex, _) in loop.cells.enumerated() {
                        
                        if numRows == row {
                            cell.textField?.stringValue = "V:\(view.id) L:\(loopIndex) C:\(cellIndex)"
                            return cell
                        }
                        
                        numRows += 1
                    }
                }
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "logicCellId"),
                                     owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(logic[row].id)"
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let tableView = notification.object as? NSTableView {
            
            renderStartTime = Date().timeIntervalSince1970
            
            // Pictures
            if tableView == picturesTableView, (0 ..< pictures.count).contains(picturesTableView.selectedRow) {
                
                print("Picture Selected: \(pictures[picturesTableView.selectedRow].id)")
                gameData.drawPicture(id: pictures[picturesTableView.selectedRow].id)
                
                // Deselect View
                self.viewsTableView.deselectAll(nil)
            }
            
            // Views
            else if tableView == viewsTableView {
                
                if let viewInfo = viewsTableView.view(atColumn: 0,
                                                      row: viewsTableView.selectedRow,
                                                      makeIfNecessary: true) as? NSTableCellView {
                    
                    // Extract the view info
                    var viewId = 0
                    var loopNum = 0
                    var cellNum = 0
                    if let itemsArray = viewInfo.textField?.stringValue.split(separator: " "), itemsArray.count == 3 {
                        
                        viewId = (itemsArray[0].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        loopNum = (itemsArray[1].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        cellNum = (itemsArray[2].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        
                        print("View Selected: \(viewId), \(loopNum), \(cellNum)")
                        let object = ScreenObject()
                        object.viewId = viewId
                        object.currentLoopNum = loopNum
                        object.currentCellNum = cellNum
                        gameData.drawScreenObject(object)
                    }
                }
            }
            
            // Logic
            else if tableView == logicTableView, (0 ..< logic.count).contains(logicTableView.selectedRow) {
                
                print("Logic Selected: \(logic[logicTableView.selectedRow].id)")
                gameData.playRoom(roomNumber: UInt8(logic[logicTableView.selectedRow].id))
                
                // Deselect Picture, View
                self.picturesTableView.deselectAll(nil)
                self.viewsTableView.deselectAll(nil)
            }
        }
    }
}

