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
        0xFF: ControlCommand(name: CommandName.control_if, numberOfArguments: 0),
        0xFE: ControlCommand(name: CommandName.control_else, numberOfArguments: 0),
        0xFD: ControlCommand(name: CommandName.control_not, numberOfArguments: 0),
        0xFC: ControlCommand(name: CommandName.control_or, numberOfArguments: 0)
    ]
    
    class ControlCommand: Command {
        
        var conditions = [Command]()
        
        var conditionsPassedSubCommands = [Command]()
        var conditionsFailedSubCommands = [Command]()
        
        override func copy() -> ControlCommand {
            return ControlCommand(name: name, numberOfArguments: numberOfArguments)
        }
        
        override func process(_ drawGraphics: (Int?, ScreenObject?, Bool) -> Void) -> ProcessingChoice {
            
            func processSubCommands(evaluatesTrue: Bool) -> ProcessingChoice {
                
                if evaluatesTrue, !conditionsPassedSubCommands.isEmpty {
                    print("Process: \(name) (\(conditions[0].debugPrint(""))) {")
                    
                    for command in conditionsPassedSubCommands {
                        if command.process(drawGraphics) == .stopProcessing {
                            return .stopProcessing
                        }
                    }
                    
                    print ("}")
                }
                
                // conditionsFailedSubCommands
                else if !conditionsFailedSubCommands.isEmpty {
                    print("Process: else (\(conditions[0].debugPrint(""))) {")
                    
                    for command in conditionsFailedSubCommands {
                        if command.process(drawGraphics) == .stopProcessing {
                            return .stopProcessing
                        }
                    }
                    
                    print ("}")
                }
                
                return .continueProcessing
            }
            
            
            return processSubCommands(evaluatesTrue: processLogic())
        }
        
        func processLogic() -> Bool {
            
            // if
            if name == CommandName.control_if {
                
                var orMode = false
                var orModeEvaluatesTrue = false
                var notMode = false
                
                for condition in conditions {
                    
                    // A Control code
                    if let controlCommand = condition as? ControlCommand {
                        
                        // Enable 'Not' mode - always followed by the only condition it effects
                        if controlCommand.name == CommandName.control_not {
                            notMode = true
                        }
                        
                        // 'Or' Mode
                        if controlCommand.name == CommandName.control_or {
                            
                            // We are already in 'Or' mode and we get an 'Or' command.
                            if orMode {
                                
                                // This evaluates false, since this is always &&'d with everything a false
                                // will always mean the condition evaluates false
                                if !orModeEvaluatesTrue {
                                    return false
                                }
                                
                                orMode = false
                            }
                            
                            // Enable 'Or' mode
                            else {
                                orMode = true
                                orModeEvaluatesTrue = false
                            }
                            
                        }
                    }
                    
                    // A Condition Code
                    else if let conditionCommand = condition as? ConditionCommand {
                        
                        // 'And' mode
                        if !orMode, !notMode {
                            
                            // We evaluateFalse we know all the logc will fail
                            if !conditionCommand.evaluate() {
                                return false
                            }
                        }
                        
                        // 'Or' mode
                        if orMode {
                            
                            // If we evaluateTrue, the 'Or' command will always pass from now on
                            if conditionCommand.evaluate() {
                                orModeEvaluatesTrue = true
                            }
                        }
                        
                        // 'Not' mode
                        if notMode {
                            
                            // If we evaluateTrue, and we are Not'ing this, we are false, and fail
                            if conditionCommand.evaluate() {
                                return false
                            }
                            
                            // We evaluatedFalse, which is Not'ed to true, so we pass and continue
                            else {
                                
                                // Only stays set for 1 condition
                                notMode = false
                            }
                        }
                    }
                    
                    print(condition.debugPrint("Condition: "))
                }
                
                // We made it to the end, it must evaluateTrue
                return true
            }
            
            return true
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
