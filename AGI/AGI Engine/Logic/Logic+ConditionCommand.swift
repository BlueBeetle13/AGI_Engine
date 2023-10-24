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
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum = Int(data[0])
                let value = data[1]
                
                return Logic.variables[variableNum] == value
            }
            
            // equal_v
            else if name == CommandName.condition_equal_v {
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum1 = Int(data[0])
                let variableNum2 = Int(data[1])
                
                return Logic.variables[variableNum1] == Logic.variables[variableNum2]
            }
            
            // less
            else if name == CommandName.condition_less {
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum = Int(data[0])
                let value = data[1]
                
                return Logic.variables[variableNum] < value
            }
            
            // less_v
            else if name == CommandName.condition_less_v {
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum1 = Int(data[0])
                let variableNum2 = Int(data[1])
                
                return Logic.variables[variableNum1] < Logic.variables[variableNum2]
            }
            
            // greater
            else if name == CommandName.condition_greater {
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum = Int(data[0])
                let value = data[1]
                
                return Logic.variables[variableNum] > value
            }
            
            // greater_v
            else if name == CommandName.condition_greater_v {
                guard dataIsValid(bytes: 2) else { return false }
                
                let variableNum1 = Int(data[0])
                let variableNum2 = Int(data[1])
                
                return Logic.variables[variableNum1] > Logic.variables[variableNum2]
            }
            
            // isset
            else if name == CommandName.condition_isset {
                guard dataIsValid(bytes: 1) else { return false }
                
                return Logic.flags[Int(data[0])] == true
            }
            
            // isset_v
            else if name == CommandName.condition_isset_v {
                guard dataIsValid(bytes: 1) else { return false }
                
                return Logic.variables[Int(data[0])] == 1
            }
            
            // position
            else if name == CommandName.condition_position {
                guard dataIsValid(bytes: 5) else { return false }
                
                let object = screenObjects[Int(data[0])]
                let testMinX = data[1]
                let testMinY = data[2]
                let testMaxX = data[3]
                let testMaxY = data[4]
                
                let objectInX = (testMinX ... testMaxX).contains(UInt8(object.posX))
                let objectInY = (testMinY ... testMaxY).contains(UInt8(object.posY))
                
                return objectInX && objectInY
            }
            
            // compare_strings
            else if name == CommandName.condition_compare_strings {
                guard dataIsValid(bytes: 2), data[0] < Logic.numStrings, data[1] < Logic.numStrings else { return false }
                
                let ignoredCharacters: Set<Character> = [Character(String(format: "%c", 0x20)),
                                                         Character(String(format: "%c", 0x09)),
                                                         "-",
                                                         ".",
                                                         ",",
                                                         ":",
                                                         ";",
                                                         "!",
                                                         "\\"]
                
                let stringNum1 = Int(data[0])
                let stringNum2 = Int(data[1])
                
                // Remove characters that are ignored and convert to lowercase
                var string1 = Logic.strings[stringNum1].lowercased()
                string1.removeAll(where: { ignoredCharacters.contains($0) } )
                
                var string2 = Logic.strings[stringNum2].lowercased()
                string2.removeAll(where: { ignoredCharacters.contains($0) } )
                
                return string1.compare(string2) == .orderedSame
            }
            
            // obj_in_box
            else if name == CommandName.condition_obj_in_box {
                guard dataIsValid(bytes: 5) else { return false }
                
                let object = screenObjects[Int(data[0])]
                let testMinX = data[1]
                let testMinY = data[2]
                let testMaxX = data[3]
                let testMaxY = data[4]
                
                return object.posX >= testMinX &&
                    object.posY >= testMinY &&
                    object.posX + object.sizeX <= testMaxX &&
                    object.posY + object.sizeY <= testMaxY
            }
            
            // center_position
            else if name == CommandName.condition_center_position {
                guard dataIsValid(bytes: 5) else { return false }
                
                let object = screenObjects[Int(data[0])]
                let testMinX = data[1]
                let testMinY = data[2]
                let testMaxX = data[3]
                let testMaxY = data[4]
                
                return object.posX + object.sizeX / 2 >= testMinX &&
                    object.posX + object.sizeX / 2 <= testMaxX &&
                    object.posY >= testMinY &&
                    object.posY <= testMaxY
            }
            
            // right_position
            else if name == CommandName.condition_right_position {
                guard dataIsValid(bytes: 5) else { return false }
                
                let object = screenObjects[Int(data[0])]
                let testMinX = data[1]
                let testMinY = data[2]
                let testMaxX = data[3]
                let testMaxY = data[4]
                
                return object.posX + object.sizeX >= testMinX &&
                    object.posX + object.sizeX <= testMaxX &&
                    object.posY >= testMinY &&
                    object.posY <= testMaxY
            }
            
            // in_motion_using_mouse
            else if name == CommandName.condition_in_motion_using_mouse {
                return false
            }
            
            return false
        }
    }
}
