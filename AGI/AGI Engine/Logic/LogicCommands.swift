//
//  LogicCommands.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-06.
//

import Foundation

protocol LogicPrintProtocol {
    func print(_ prefix: String) -> String
}

class LogicCommand: LogicPrintProtocol {
    
    let logicCode: LogicCode
    
    init(code: LogicCode) {
        self.logicCode = code
    }
    
    // Debug print
    func print(_ prefix: String) -> String {
        return "\(prefix)\(logicCode.name)\n"
    }
}

class LogicOperationCommand: LogicCommand {
    var data = [UInt8]()
    
    // Debug print
    override func print(_ prefix: String) -> String {
        return "\(prefix)\(logicCode.name) -> \(data)\n"
    }
}

class LogicControlCommand: LogicCommand {
    var conditions = [LogicCommand]()
    
    var conditionsPassedSubCommands = [LogicCommand]()
    var conditionsFailedSubCommands = [LogicCommand]()
    
    // Debug print
    override func print(_ prefix: String) -> String {
        
        let conditionsStr: [String] = conditions.map({ command in
            
            if let operation = command as? LogicOperationCommand {
                return "\(operation.logicCode.name)(\(operation.data))"
            }
            
            else {
                return "\(command.logicCode.name)"
            }
        })
        
        var output = "\(prefix)\(logicCode.name) (\(conditionsStr)) {\n"
        for command in conditionsPassedSubCommands {
            output += command.print(prefix + "   ")
        }
        output += "\(prefix)}\n"
        
        if conditionsFailedSubCommands.count > 0 {
            output += "\(prefix)else {\n"
            for command in conditionsFailedSubCommands {
                output += command.print(prefix + "   ")
            }
            
            output += "\(prefix)}\n"
        }
        
        return output
    }
}
