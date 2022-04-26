//
//  Logic+ConditionCommand.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-30.
//

import Foundation

// Condition Codes
extension Logic {
    
    static let conditionCommands: [UInt8: ConditionCommand] = [
        0x00: ConditionCommand(id: 0x00, name: "unknown", numberOfArguments: 0),
        0x01: ConditionCommand(id: 0x01, name: "equal", numberOfArguments: 2),
        0x02: ConditionCommand(id: 0x02, name: "equal.v", numberOfArguments: 2),
        0x03: ConditionCommand(id: 0x03, name: "less", numberOfArguments: 2),
        0x04: ConditionCommand(id: 0x04, name: "less.v", numberOfArguments: 2),
        0x05: ConditionCommand(id: 0x05, name: "greater", numberOfArguments: 2),
        0x06: ConditionCommand(id: 0x06, name: "greater.v", numberOfArguments: 2),
        0x07: ConditionCommand(id: 0x07, name: "isset", numberOfArguments: 1),
        0x08: ConditionCommand(id: 0x08, name: "isset.v", numberOfArguments: 1),
        0x09: ConditionCommand(id: 0x09, name: "has", numberOfArguments: 1),
        0x0A: ConditionCommand(id: 0x0A, name: "obj.in.room", numberOfArguments: 2),
        0x0B: ConditionCommand(id: 0x0B, name: "position", numberOfArguments: 5),
        0x0C: ConditionCommand(id: 0x0C, name: "controller", numberOfArguments: 1),
        0x0D: ConditionCommand(id: 0x0D, name: "have.key", numberOfArguments: 0),
        0x0E: ConditionCommand(id: 0x0E, name: "said", numberOfArguments: -1),
        0x0F: ConditionCommand(id: 0x0F, name: "compare.strings", numberOfArguments: 2),
        0x10: ConditionCommand(id: 0x10, name: "obj.in.box", numberOfArguments: 5),
        0x11: ConditionCommand(id: 0x11, name: "center.position", numberOfArguments: 5),
        0x12: ConditionCommand(id: 0x12, name: "right.position", numberOfArguments: 5),
        0x13: ConditionCommand(id: 0x13, name: "in.motion.using.mouse", numberOfArguments: 0)
    ]
    
    class ConditionCommand: Command {
        
        override func copy() -> ConditionCommand {
            return ConditionCommand(id: id, name: name, numberOfArguments: numberOfArguments)
        }
        
        func evaluate() -> Bool {
            
            // isset
            if name == "isset" {
                guard data.count == 1, (0 ... 255).contains(data[0]) else { return false }
                
                return Logic.flags[Int(data[0])] == 1
            }
            
            // isset_v
            if name == "isset_v" {
                guard data.count == 1, (0 ... 255).contains(data[0]) else { return false }
                
                return Logic.variables[Int(data[0])] == 1
            }
            
            return false
        }
    }
}
