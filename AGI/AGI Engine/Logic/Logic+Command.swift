//
//  Logic+Command.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-06.
//

import Foundation

protocol LogicPrintProtocol {
    func execute(_ drawGraphics: (Int, Int, Int, Int) -> Void)
    func debugPrint(_ prefix: String) -> String
}

extension Logic {
    
    class Command: LogicPrintProtocol {
        
        let id: UInt8
        let name: String
        let numberOfArguments: Int
        var data = [UInt8]()
        
        init(id: UInt8, name: String, numberOfArguments: Int) {
            self.id = id
            self.name = name
            self.numberOfArguments = numberOfArguments
        }
        
        func copy() -> Command {
            return Command(id: id, name: name, numberOfArguments: numberOfArguments)
        }
        
        func execute(_ drawGraphics: (Int, Int, Int, Int) -> Void) {}
        
        // Debug print
        func debugPrint(_ prefix: String) -> String {
            return "\(prefix)\(data)\n"
        }
    }
}
