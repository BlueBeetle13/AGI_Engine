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

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var screenView: NSImageView!
    @IBOutlet weak var priorityView: NSImageView!
    @IBOutlet weak var picturesTableView: NSTableView!
    @IBOutlet weak var viewsTableView: NSTableView!
    
    // Rendering
    var renderStartTime: TimeInterval = 0
    
    let gameData = GameData()
    var pictures: [Picture] = []
    var views: [View] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturesTableView.dataSource = self
        picturesTableView.delegate = self
        
        viewsTableView.dataSource = self
        viewsTableView.delegate = self
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
                                      loadFinished: { pictures, views in
                                        self.pictures = Array(pictures.values).sorted(by: { $0.id < $1.id })
                                        self.views = Array(views.values).sorted(by: { $0.id < $1.id })
                                        
                                        DispatchQueue.main.async {
                                            self.picturesTableView.reloadData()
                                            self.picturesTableView.scrollRowToVisible(0)
                                            self.picturesTableView.selectRowIndexes(.init(integer: 0),
                                                                                    byExtendingSelection: false)
                                            
                                            self.viewsTableView.reloadData()
                                            self.viewsTableView.scrollRowToVisible(0)
                                        }
                                      },
                                      redraw: {
                                        
                                        print("Time1: \(Date().timeIntervalSince1970 - self.renderStartTime)")
                                        
                                        // Redraw image
                                        DispatchQueue.main.async {
                                            
                                            // Picture
                                            if let image = NSImage.init(pixels: self.gameData.pictureBuffer,
                                                                        width: self.gameData.width,
                                                                        height: self.gameData.height)  {
                                                
                                                self.screenView.image = image
                                            }
                                            
                                            // Priority
                                            if let image = NSImage.init(pixels: self.gameData.priorityBuffer,
                                                                        width: self.gameData.width,
                                                                        height: self.gameData.height)  {
                                                
                                                self.priorityView.image = image
                                            }
                                            
                                            print("Time2: \(Date().timeIntervalSince1970 - self.renderStartTime)")
                                        }
                                      })
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // Pictures
        if tableView == picturesTableView {
            return pictures.count
        }
        
        // Views
        else {
            
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
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let tableView = notification.object as? NSTableView {
            
            renderStartTime = Date().timeIntervalSince1970
            
            // Pictures
            if tableView == picturesTableView {
                print("Selected: \(pictures[picturesTableView.selectedRow].id)")
                gameData.drawPicture(id: pictures[picturesTableView.selectedRow].id)
                
                // Deselect View
                self.viewsTableView.deselectAll(nil)
            }
            
            // Views
            else if viewsTableView.selectedRow >= 0 {
                if let viewInfo = viewsTableView.view(atColumn: 0,
                                                      row: viewsTableView.selectedRow,
                                                      makeIfNecessary: false) as? NSTableCellView {
                    
                    // Extract the view info
                    var viewNum = 0
                    var loopNum = 0
                    var cellNum = 0
                    if let itemsArray = viewInfo.textField?.stringValue.split(separator: " "), itemsArray.count == 3 {
                        
                        viewNum = (itemsArray[0].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        loopNum = (itemsArray[1].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        cellNum = (itemsArray[2].split(separator: ":").last as NSString?)?.integerValue ?? 0
                        
                        print("Selected: \(viewNum), \(loopNum), \(cellNum)")
                        gameData.drawView(viewNum: viewNum, loopNum: loopNum, cellNum: cellNum)
                    }
                }
            }
        }
    }
}

