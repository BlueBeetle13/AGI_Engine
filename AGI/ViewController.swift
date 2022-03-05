//
//  ViewController.swift
//  AGI
//
//  Created by Phil Inglis on 2022-02-23.
//

import Cocoa
import CoreGraphics

public struct Pixel: Equatable {
    var a,r,g,b: UInt8
    
    public static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.a == rhs.a && lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
}

extension NSImage {
    convenience init?(pixels: [Pixel], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else { return nil }
        var data = pixels
        guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<Pixel>.size) as CFData)
            else { return nil }
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * MemoryLayout<Pixel>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
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
    @IBOutlet weak var picturesTableView: NSTableView!
    
    // Rendering
    let width = 320
    let height = 200
    var buffer: [Pixel] = []
    
    let gameData = GameData()
    var pictures: [Picture] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buffer = Array.init(repeating: Pixel(a: 255, r: 255, g: 255, b: 255), count: width * height)
        
        if let image = NSImage.init(pixels: buffer, width: width, height: height)  {
            screenView.image = image
        }
        
        picturesTableView.dataSource = self
        picturesTableView.delegate = self

        //gameData.loadGameData(from: "/Users/typhoonsoftware/Downloads/spacequestiivohaulsrevenge1987/sq2/")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
                                      with: &buffer,
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
                                        
                                        // Redraw image
                                        DispatchQueue.main.async {
                                            if let image = NSImage.init(pixels: self.buffer, width: self.width, height: self.height)  {
                                                print("Draw")
                                                self.screenView.image = image
                                            }
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
        
        buffer = Array(repeating: Pixel(a: 255, r: 255, g: 255, b: 255), count: width * height)
        
        gameData.loadPicture(id: pictures[picturesTableView.selectedRow].id, buffer: &buffer)
    }
}

