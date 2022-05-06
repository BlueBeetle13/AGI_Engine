//
//  LogicControlTests.swift
//  AGITests
//
//  Created by Phil Inglis on 2022-05-04.
//

import XCTest
@testable import AGI

class LogicControlTests: XCTestCase {
    
    // Set up control commands
    let controlLogicIf = Logic.ControlCommand(name: Logic.CommandName.control_if, numberOfArguments: 0)
    let controlLogicNot = Logic.ControlCommand(name: Logic.CommandName.control_not, numberOfArguments: 0)
    let controlLogicOr = Logic.ControlCommand(name: Logic.CommandName.control_or, numberOfArguments: 0)
    let conditionTrue = Logic.ConditionCommand(name: Logic.CommandName.condition_equal, numberOfArguments: 2)
    let conditionFalse = Logic.ConditionCommand(name: Logic.CommandName.condition_equal, numberOfArguments: 2)

    override func setUpWithError() throws {
        
        // Reset all variables and flags
        for index in 0 ..< Logic.numVariables {
            Logic.variables[index] = 0
        }
        
        for index in 0 ..< Logic.numFlags {
            Logic.flags[index] = false
        }
        
        // Reset all object position and size
        for index in 0 ..< Logic.numScreenObjects {
            Logic.screenObjects[index].posX = 0
            Logic.screenObjects[index].posY = 0
            Logic.screenObjects[index].sizeX = 0
            Logic.screenObjects[index].sizeY = 0
        }
        
        // Reset all strings
        for index in 0 ..< Logic.numStrings {
            Logic.strings[index] = ""
        }
        
        // Finish setting up the conditions
        Logic.variables[0] = 1
        conditionTrue.data = [0, 1]
        
        Logic.variables[1] = 0
        conditionFalse.data = [1, 1]
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testControl_And_True() throws {
        
        controlLogicIf.conditions.append(conditionTrue)
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_And_False() throws {
        
        controlLogicIf.conditions.append(conditionFalse)
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_And_TrueTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionTrue,
            conditionTrue,
            conditionTrue
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_And_TrueFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionTrue,
            conditionFalse,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_And_TrueTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionTrue,
            conditionTrue,
            conditionFalse
        ])
    }
    
    func testControl_And_FalseTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionFalse,
            conditionTrue,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_Not_True() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionTrue
        ])
        
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_Not_False() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionFalse
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_NotAnd_FalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionFalse,
            conditionTrue
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_NotAnd_TrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionTrue,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_NotAnd_TrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionTrue,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_NotAnd_FalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicNot,
            conditionFalse,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_Or_TrueTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionTrue,
            conditionTrue,
            controlLogicOr
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_Or_TrueFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionTrue,
            controlLogicOr
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_Or_TrueTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionTrue,
            conditionFalse,
            controlLogicOr
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_Or_FalseTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionTrue,
            conditionTrue,
            controlLogicOr
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_Or_FalseFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_AndOr_TrueFalseFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionTrue,
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_AndOr_TrueFalseTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            conditionTrue,
            controlLogicOr,
            conditionFalse,
            conditionTrue,
            conditionFalse,
            controlLogicOr
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrAnd_TrueFalseTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionTrue,
            controlLogicOr,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAnd_TrueFalseTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionTrue,
            controlLogicOr,
            conditionTrue
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrAnd_FalseFalseFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrNotAnd_FalseFalseFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrNotAnd_TrueFalseFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrNotAnd_TrueFalseFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionFalse
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrOr_TrueFalseFalseTrueFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrOr_FalseFalseFalseTrueFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndAnd_TrueFalseFalseTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            conditionTrue,
            conditionTrue
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndAnd_TrueFalseFalseTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            conditionTrue,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndAnd_TrueFalseFalseFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            conditionFalse,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndAnd_FalseFalseFalseFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionFalse,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            conditionFalse,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndNotAnd_TrueFalseFalseFalseTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionFalse,
            conditionTrue
        ])
            
        XCTAssertTrue(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndNotAnd_TrueFalseFalseTrueFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionTrue,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndNotAnd_TrueFalseFalseTrueTrue() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionTrue,
            conditionTrue
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
    
    func testControl_OrAndNotAnd_TrueFalseFalseFalseFalse() throws {
        
        controlLogicIf.conditions.append(contentsOf: [
            controlLogicOr,
            conditionTrue,
            conditionFalse,
            conditionFalse,
            controlLogicOr,
            controlLogicNot,
            conditionFalse,
            conditionFalse
        ])
            
        XCTAssertFalse(controlLogicIf.processLogic())
    }
}
