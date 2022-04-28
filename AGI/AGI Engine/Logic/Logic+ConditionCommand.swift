//
//  Logic+ConditionCommand.swift
//  AGI
//
//  Created by Phil Inglis on 2022-03-30.
//

import Foundation

// Conditions for 'if' statements
extension Logic {
    
    static let conditionCommands: [UInt8: ConditionCommand] = [
        0x00: ConditionCommand(name: CommandName.condition_unknown, numberOfArguments: 0),
        0x01: ConditionCommand(name: CommandName.condition_equal, numberOfArguments: 2),
        0x02: ConditionCommand(name: CommandName.condition_equal_v, numberOfArguments: 2),
        0x03: ConditionCommand(name: CommandName.condition_less, numberOfArguments: 2),
        0x04: ConditionCommand(name: CommandName.condition_less_v, numberOfArguments: 2),
        0x05: ConditionCommand(name: CommandName.condition_greater, numberOfArguments: 2),
        0x06: ConditionCommand(name: CommandName.condition_greater_v, numberOfArguments: 2),
        0x07: ConditionCommand(name: CommandName.condition_isset, numberOfArguments: 1),
        0x08: ConditionCommand(name: CommandName.condition_isset_v, numberOfArguments: 1),
        0x09: ConditionCommand(name: CommandName.condition_has, numberOfArguments: 1),
        0x0A: ConditionCommand(name: CommandName.condition_obj_in_room, numberOfArguments: 2),
        0x0B: ConditionCommand(name: CommandName.condition_position, numberOfArguments: 5),
        0x0C: ConditionCommand(name: CommandName.condition_controller, numberOfArguments: 1),
        0x0D: ConditionCommand(name: CommandName.condition_have_key, numberOfArguments: 0),
        0x0E: ConditionCommand(name: CommandName.condition_said, numberOfArguments: -1),
        0x0F: ConditionCommand(name: CommandName.condition_compare_strings, numberOfArguments: 2),
        0x10: ConditionCommand(name: CommandName.condition_obj_in_box, numberOfArguments: 5),
        0x11: ConditionCommand(name: CommandName.condition_center_position, numberOfArguments: 5),
        0x12: ConditionCommand(name: CommandName.condition_right_position, numberOfArguments: 5),
        0x13: ConditionCommand(name: CommandName.condition_in_motion_using_mouse, numberOfArguments: 0)
    ]
    
    class ConditionCommand: Command {
        
        override func copy() -> ConditionCommand {
            return ConditionCommand(name: name, numberOfArguments: numberOfArguments)
        }
        
        func evaluate() -> Bool {
            
            // equal
            if name == CommandName.condition_equal {
                guard data.count == 2, (0 ... 255).contains(data[0]), (0 ... 255).contains(data[1]) else { return false }
                
                let variableNum = Int(data[0])
                let value = data[1]
                
                return Logic.variables[variableNum] == value
            }
            
            // equal.v
            if name == CommandName.condition_equal_v {
                guard data.count == 2, (0 ... 255).contains(data[0]), (0 ... 255).contains(data[1]) else { return false }
                
                let variableNum = Int(data[0])
                let valueNum = Int(data[1])
                
                return Logic.variables[variableNum] == Logic.variables[valueNum]
            }
            
            // isset
            if name == CommandName.condition_isset {
                guard data.count == 1, (0 ... 255).contains(data[0]) else { return false }
                
                return Logic.flags[Int(data[0])] == true
            }
            
            // isset_v
            if name == CommandName.condition_isset_v {
                guard data.count == 1, (0 ... 255).contains(data[0]) else { return false }
                
                return Logic.variables[Int(data[0])] == 1
            }
            
            return false
        }
    }
}
