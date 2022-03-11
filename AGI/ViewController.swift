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
    
    // Rendering
    var renderStartTime: TimeInterval = 0
    
    let gameData = GameData()
    var pictures: [Picture] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturesTableView.dataSource = self
        picturesTableView.delegate = self
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
                                      loadFinished: { pictures in
                                        self.pictures = Array(pictures.values).sorted(by: { $0.id < $1.id })
                                        
                                        DispatchQueue.main.async {
                                            self.picturesTableView.reloadData()
                                            self.picturesTableView.scrollRowToVisible(0)
                                            self.picturesTableView.selectRowIndexes(.init(integer: 0),
                                                                                    byExtendingSelection: false)
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
        return pictures.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "pictureId"),
                                     owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(pictures[row].id)"
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print("Selected: \(pictures[picturesTableView.selectedRow].id)")
        
        renderStartTime = Date().timeIntervalSince1970
        
        gameData.loadPicture(id: pictures[picturesTableView.selectedRow].id)
    }
}

