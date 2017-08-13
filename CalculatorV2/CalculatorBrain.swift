//
//  CalculatorBrain.swift
//  CalculatorV2
//
//  Created by Tim Petri on 8/6/17.
//  Copyright © 2017 Tim Petri. All rights reserved.
//

import Foundation

func factorial(_ op1: Double) -> Double {
    if (op1 <= 1.0) {
        return 1.0
    }
    return op1 * factorial(op1 - 1.0)
}

struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double, (String) -> String)
        case binaryOperation((Double, Double)->Double, (String, String) -> String)
        case equals
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        
        // structs provide initializers
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        let firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    
    private var operations = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation({sqrt($0)}, {"√(" + $0 + ")"}),
        "±": Operation.unaryOperation({-1 * $0}, {"-(" + $0 + ")"}),
        "+": Operation.binaryOperation({$0 + $1}, {$0 + "+" + $1}),
        "-": Operation.binaryOperation({$0 - $1}, {$0 + "-" + $1}),
        "×": Operation.binaryOperation({$0 * $1}, {$0 + "×" + $1}),
        "÷": Operation.binaryOperation({$0 / $1}, {$0 + "÷" + $1}),
        "=": Operation.equals,
        
        // new ones
        "x²" : Operation.unaryOperation({ pow($0, 2) }, {"(" + $0 + ")²"}),
        "x³" : Operation.unaryOperation({ pow($0, 3) }, {"(" + $0 + ")³"}),
        "x⁻¹" : Operation.unaryOperation({ 1/$0 }, {"(" + $0 + ")⁻¹"}),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "tan" : Operation.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "sinh" : Operation.unaryOperation(sinh, { "sinh(" + $0 + ")" }),
        "cosh" : Operation.unaryOperation(cosh, { "cosh(" + $0 + ")" }),
        "tanh" : Operation.unaryOperation(tanh, { "tanh(" + $0 + ")" }),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")" }),
        "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")" }),
        "eˣ" : Operation.unaryOperation(exp, { "e^(" + $0 + ")" }),
        "10ˣ" : Operation.unaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")" }),
        "x!" : Operation.unaryOperation(factorial, { "(" + $0 + ")!" }),
        "xʸ" : Operation.binaryOperation(pow, {$0 + "^" + $1})
    ]
    
    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            
            case .constant(let value):
                accumulator = (value, symbol)
             
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                }
            case .binaryOperation(let function, let description):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                    accumulator = nil
             
                }
                
            case .equals:
                performPendingBinaryOperation()
                
            }
        }
    

    }
    
    weak var numberFormatter: NumberFormatter?
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand)")
        
    }
    
    // read-only
    var result: Double? {
        get {
            if nil != accumulator {
                return accumulator!.0
            }
            return nil
        }
    }
    
    var description: String? {
        get {
            if resultIsPending {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            
            } else {
                return accumulator?.1
            }
        }
    }
    
    // returns true if there is a pending binary operation
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
}
