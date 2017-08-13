//
//  CalculatorV2Tests.swift
//  CalculatorV2Tests
//
//  Created by Tim Petri on 8/13/17.
//  Copyright © 2017 Tim Petri. All rights reserved.
//

import XCTest

class CalculatorV2Tests: XCTestCase {
    
    var brain: CalculatorBrain!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        brain = CalculatorBrain()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // a. touching 7 + would show "7 + ..." (with 7 still in the display)
    func testA() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        XCTAssertEqual(brain.description!, "7.0+")
    }
    
    // b. 7 + 9 would show "7+ ..." (9 in the display)
    func testB() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        // brain.setOperand(9.0) // entered but not pushed to model
        XCTAssertEqual(brain.description!, "7.0+")
    
    }
    
    // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
    func testC() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "7.0+9.0")
    }
    
    
    
    
    // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
    func testD() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("=")
        brain.performOperation("√")
        XCTAssertEqual(brain.description!, "√(7.0+9.0)")
    }
    
    // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
    func testE() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.performOperation("+")
        brain.setOperand(2.0)
        XCTAssertEqual(brain.description!, "√(7.0+9.0)+2.0")
    }
    
    // f. 7 + 9 √ would show “7 + √(9) …” (3 in the display)
    func testF() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("√")
        XCTAssertEqual(brain.description!, "7.0+√(9.0)")
    }
    
    // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
    func testG() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("√")
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "7.0+√(9.0)")
    }
    
    // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testH() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("=")
        brain.performOperation("+")
        brain.setOperand(6.0)
        brain.performOperation("=")
        brain.performOperation("+")
        brain.setOperand(3.0)
        brain.performOperation("=")
        XCTAssertEqual(brain.description!, "7.0+9.0+6.0+3.0")
    }
    
    // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
    func testI() {
        brain.setOperand(7.0)
        brain.performOperation("+")
        brain.setOperand(9.0)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.setOperand(6.0)
        brain.performOperation("+")
        brain.setOperand(3.0)
        XCTAssertEqual(brain.description!, "6.0+3.0")
    }
    
    // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
    func testJ() {
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("=")
        //brain.setOperand(73) // entered but not pushed to model
        XCTAssertEqual(brain.description, "5.0+6.0")
    }
    
    // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
    func testK() {
        brain.setOperand(4)
        brain.performOperation("×")
        brain.performOperation("π")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "4.0×π")
    }
        
}
