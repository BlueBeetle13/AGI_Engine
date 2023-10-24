//
//  LogicConditionTests.swift
//  AGITests
//
//  Created by Phil Inglis on 2022-05-03.
//

import XCTest
@testable import AGI

class LogicConditionTests: XCTestCase {

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
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCondition_Equal() throws {
        
        if let conditionEqual = Logic.conditionCommands[0x01]?.copy(),
           conditionEqual.name == Logic.CommandName.condition_equal {
            
            // Given
            let value: UInt8 = 5
            let variableNum: UInt8 = 1
            Logic.variables[Int(variableNum)] = value
            
            conditionEqual.data = [variableNum, value]
            
            // When
            let result = conditionEqual.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Equal_V() throws {
        
        if let conditionEqualV = Logic.conditionCommands[0x02]?.copy(),
           conditionEqualV.name == Logic.CommandName.condition_equal_v {
            
            // Given
            let value1: UInt8 = 5
            let variableNum1: UInt8 = 1
            Logic.variables[Int(variableNum1)] = value1
            
            let value2: UInt8 = 5
            let variableNum2: UInt8 = 2
            Logic.variables[Int(variableNum2)] = value2
            
            conditionEqualV.data = [variableNum1, variableNum2]
            
            // When
            let result = conditionEqualV.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Less() throws {
        
        if let conditionLess = Logic.conditionCommands[0x03]?.copy(),
           conditionLess.name == Logic.CommandName.condition_less {
            
            // Given
            let value: UInt8 = 5
            let variableNum: UInt8 = 1
            Logic.variables[Int(variableNum)] = value
            
            conditionLess.data = [variableNum, value + 1]
            
            // When
            let result = conditionLess.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Less_V() throws {
        
        if let conditionLessV = Logic.conditionCommands[0x04]?.copy(),
           conditionLessV.name == Logic.CommandName.condition_less_v {
            
            // Given
            let value1: UInt8 = 5
            let variableNum1: UInt8 = 1
            Logic.variables[Int(variableNum1)] = value1
            
            let value2 = value1 + 1
            let variableNum2: UInt8 = 2
            Logic.variables[Int(variableNum2)] = value2
            
            conditionLessV.data = [variableNum1, variableNum2]
            
            // When
            let result = conditionLessV.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Greater() throws {
        
        if let conditionGreater = Logic.conditionCommands[0x05]?.copy(),
           conditionGreater.name == Logic.CommandName.condition_greater {
            
            // Given
            let value: UInt8 = 5
            let variableNum: UInt8 = 1
            Logic.variables[Int(variableNum)] = value
            
            conditionGreater.data = [variableNum, value - 1]
            
            // When
            let result = conditionGreater.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Greater_V() throws {
        
        if let conditionGreaterV = Logic.conditionCommands[0x06]?.copy(),
           conditionGreaterV.name == Logic.CommandName.condition_greater_v {
            
            // Given
            let value1: UInt8 = 5
            let variableNum1: UInt8 = 1
            Logic.variables[Int(variableNum1)] = value1
            
            let value2 = value1 - 1
            let variableNum2: UInt8 = 2
            Logic.variables[Int(variableNum2)] = value2
            
            conditionGreaterV.data = [variableNum1, variableNum2]
            
            // When
            let result = conditionGreaterV.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Isset() throws {
        
        if let conditionIsset = Logic.conditionCommands[0x07]?.copy(),
           conditionIsset.name == Logic.CommandName.condition_isset {
            
            // Given
            let flagNum: UInt8 = 1
            Logic.flags[Int(flagNum)] = true
            
            conditionIsset.data = [flagNum]
            
            // When
            let result = conditionIsset.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    func testCondition_Isset_V() throws {
        
        if let conditionIssetV = Logic.conditionCommands[0x08]?.copy(),
           conditionIssetV.name == Logic.CommandName.condition_isset_v {
            
            // Given
            let variableNum: UInt8 = 1
            Logic.variables[Int(variableNum)] = 1
            
            conditionIssetV.data = [variableNum]
            
            // When
            let result = conditionIssetV.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if an objects position is in the bounding box given by the top-left and bottom-right coords
    func testCondition_Position_Inside() throws {
        
        if let conditionPosition = Logic.conditionCommands[0x0B]?.copy(),
           conditionPosition.name == Logic.CommandName.condition_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 5
            object.posY = 5
            
            conditionPosition.data = [objectNum, 0, 0, 10, 10]
            
            // When
            let result = conditionPosition.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if an objects position is in the bounding box given by the top-left and bottom-right coords
    func testCondition_Position_Inside2() throws {
        
        if let conditionPosition = Logic.conditionCommands[0x0B]?.copy(),
           conditionPosition.name == Logic.CommandName.condition_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 74
            object.posY = 93
            
            conditionPosition.data = [objectNum, 74, 92, 75, 93]
            
            // When
            let result = conditionPosition.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if an objects position is not in the bounding box given by the top-left and bottom-right coords
    func testCondition_Position_Outside() throws {
        
        if let conditionPosition = Logic.conditionCommands[0x0B]?.copy(),
           conditionPosition.name == Logic.CommandName.condition_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 15
            object.posY = 15
            
            conditionPosition.data = [objectNum, 0, 0, 10, 10]
            
            // When
            let result = conditionPosition.evaluate()
            
            // Then
            XCTAssertFalse(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Compare 2 strings to see if they are equal
    func testCondition_CompareStrings_Simple() throws {
        
        if let conditionCompareStrings = Logic.conditionCommands[0x0F]?.copy(),
           conditionCompareStrings.name == Logic.CommandName.condition_compare_strings {
            
            // Given
            let stringNum1: UInt8 = 0
            let stringNum2: UInt8 = 1
            
            Logic.strings[Int(stringNum1)] = "test"
            Logic.strings[Int(stringNum2)] = "test"
            
            conditionCompareStrings.data = [stringNum1, stringNum2]
            
            // When
            let result = conditionCompareStrings.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Compare 2 strings to see if they are equal, test if ignored characters are really ignored
    func testCondition_CompareStrings_Ignore() throws {
        
        if let conditionCompareStrings = Logic.conditionCommands[0x0F]?.copy(),
           conditionCompareStrings.name == Logic.CommandName.condition_compare_strings {
            
            // Given
            let stringNum1: UInt8 = 0
            let stringNum2: UInt8 = 1
            
            Logic.strings[Int(stringNum1)] = "te-st"
            Logic.strings[Int(stringNum2)] = "tes!t;"
            
            conditionCompareStrings.data = [stringNum1, stringNum2]
            
            // When
            let result = conditionCompareStrings.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Compare 2 strings to see if they are equal, test if ignored characters are really ignored
    func testCondition_CompareStrings_Different() throws {
        
        if let conditionCompareStrings = Logic.conditionCommands[0x0F]?.copy(),
           conditionCompareStrings.name == Logic.CommandName.condition_compare_strings {
            
            // Given
            let stringNum1: UInt8 = 0
            let stringNum2: UInt8 = 1
            
            Logic.strings[Int(stringNum1)] = "test"
            Logic.strings[Int(stringNum2)] = "different"
            
            conditionCompareStrings.data = [stringNum1, stringNum2]
            
            // When
            let result = conditionCompareStrings.evaluate()
            
            // Then
            XCTAssertFalse(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if an object is entirely in (position and size) the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_ObjInBox_Inside() throws {
        
        if let conditionObjInBox = Logic.conditionCommands[0x10]?.copy(),
           conditionObjInBox.name == Logic.CommandName.condition_obj_in_box {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 5
            object.posY = 5
            object.sizeX = 3
            object.sizeY = 3
            
            conditionObjInBox.data = [objectNum, 0, 0, 10, 10]
            
            // When
            let result = conditionObjInBox.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if an object is outside (position and size) the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_ObjInBox_Outside() throws {
        
        if let conditionObjInBox = Logic.conditionCommands[0x10]?.copy(),
           conditionObjInBox.name == Logic.CommandName.condition_obj_in_box {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 5
            object.posY = 5
            object.sizeX = 6
            object.sizeY = 6
            
            conditionObjInBox.data = [objectNum, 0, 0, 10, 10]
            
            // When
            let result = conditionObjInBox.evaluate()
            
            // Then
            XCTAssertFalse(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if the center of an object is in the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_CenterPosition_Inside() throws {
        
        if let conditionCenterPosition = Logic.conditionCommands[0x11]?.copy(),
           conditionCenterPosition.name == Logic.CommandName.condition_center_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 0
            object.posY = 0
            object.sizeX = 8
            object.sizeY = 8
            
            conditionCenterPosition.data = [objectNum, 0, 0, 5, 5]
            
            // When
            let result = conditionCenterPosition.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if the center of an object is outside the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_CenterPosition_Outside() throws {
        
        if let conditionCenterPosition = Logic.conditionCommands[0x11]?.copy(),
           conditionCenterPosition.name == Logic.CommandName.condition_center_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 0
            object.posY = 0
            object.sizeX = 8
            object.sizeY = 8
            
            conditionCenterPosition.data = [objectNum, 5, 5, 8, 8]
            
            // When
            let result = conditionCenterPosition.evaluate()
            
            // Then
            XCTAssertFalse(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if the right side of an object is in the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_RightPosition_Inside() throws {
        
        if let conditionRightPosition = Logic.conditionCommands[0x12]?.copy(),
           conditionRightPosition.name == Logic.CommandName.condition_right_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 0
            object.posY = 8
            object.sizeX = 8
            object.sizeY = 8
            
            conditionRightPosition.data = [objectNum, 7, 7, 12, 12]
            
            // When
            let result = conditionRightPosition.evaluate()
            
            // Then
            XCTAssertTrue(result)
            
        } else {
            XCTFail()
        }
    }
    
    // Test if the right side of an object is outside the bounding box given by
    // the top-left and bottom-right coords
    func testCondition_RightPosition_Outside() throws {
        
        if let conditionRightPosition = Logic.conditionCommands[0x12]?.copy(),
           conditionRightPosition.name == Logic.CommandName.condition_right_position {
            
            // Given
            let objectNum: UInt8 = 0
            
            let object = Logic.screenObjects[Int(objectNum)]
            object.posX = 0
            object.posY = 0
            object.sizeX = 8
            object.sizeY = 8
            
            conditionRightPosition.data = [objectNum, 2, 2, 7, 7]
            
            // When
            let result = conditionRightPosition.evaluate()
            
            // Then
            XCTAssertFalse(result)
            
        } else {
            XCTFail()
        }
    }
}

