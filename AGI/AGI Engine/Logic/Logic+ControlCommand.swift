//
//  Logic+Command.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-21.
//

import Foundation

// Control - If, Else, Not, Or
extension Logic {
    
    static let controlCommands: [UInt8: ControlCommand] = [
        0xFF: ControlCommand(id: 0xFF, name: "if", numberOfArguments: 0),
        0xFE: ControlCommand(id: 0xFE, name: "else", numberOfArguments: 0),
        0xFD: ControlCommand(id: 0xFD, name: "not", numberOfArguments: 0),
        0xFC: ControlCommand(id: 0xFC, name: "or", numberOfArguments: 0)
    ]
    
    class ControlCommand: Command {
        
        var conditions = [Command]()
        
        var conditionsPassedSubCommands = [Command]()
        var conditionsFailedSubCommands = [Command]()
        
        override func copy() -> ControlCommand {
            return ControlCommand(id: id, name: name, numberOfArguments: numberOfArguments)
        }
        
        override func execute(_ drawGraphics: (Int, Int, Int, Int) -> Void) {
            
            // Special case 1 command
            if conditions.count == 1 {
                
                print("Execute: \(name) (\(conditions[0].debugPrint(""))) {")
                
                if let conditionCommand = conditions[0] as? ConditionCommand {
                    
                    conditionCommand.evaluate() ?
                        conditionsPassedSubCommands.forEach { $0.execute(drawGraphics) } :
                        conditionsFailedSubCommands.forEach { $0.execute(drawGraphics) }
                    
                    print ("}")
                }
            }
            
            else {
                /*for condition in conditions {
                    
                    print(condition.debugPrint("Condition: "))
                }*/
            }
        }
        
        // Debug print
        override func debugPrint(_ prefix: String) -> String {
            
            let conditionsStr: [String] = conditions.map({ condition in
                return "\(condition.name) -> \(condition.data)"
            })
            
            var output = "\(prefix)\(name) (\(conditionsStr)) {\n"

            for command in conditionsPassedSubCommands {
                output += command.debugPrint(prefix + "   ")
            }
            output += "\(prefix)}\n"
            
            if conditionsFailedSubCommands.count > 0 {
                output += "\(prefix)else {\n"
                for command in conditionsFailedSubCommands {
                    output += command.debugPrint(prefix + "   ")
                }
                
                output += "\(prefix)}\n"
            }
            
            return output
        }
    }
}
