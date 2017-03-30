//
//  CaculatorBrain.swift
//  Caculator
//
//  Created by certainly on 2017/3/21.
//  1222
//  Copyright © 2017年 certainly. All rights reserved.
//

import Foundation





struct CalculatorBrain {
    
    var variableValues = [String:Double]()
    
    private var accumulator: Double?
    
    var resultIsPending: Bool {
        get {
           return pendingBinaryOperation != nil
        }
    }
    
    var description: String {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                                   pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    fileprivate var descriptionAccumulator = "0" {
        didSet {
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case nullaryOperation(() -> Double, String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "cos" : Operation.unaryOperation(cos, {"cos(\($0))"}),
        "±" : Operation.unaryOperation({ -$0 }, {"-(\($0)"}),
        "×" : Operation.binaryOperation({ $0 * $1 }, {"\($0) × \($1)"}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, {"\($0) ÷ \($1)"}),
        "+" : Operation.binaryOperation({ $0 + $1 }, {"\($0) + \($1)"}),
        "−" : Operation.binaryOperation({ $0 - $1 }, {"\($0) - \($1)"}),
        "rand" : Operation.nullaryOperation( { Double(arc4random()) }, "arc4random()"),
        "=": Operation.equals
    ]
        
    
    mutating func performOperation(_ symbol: String)  {
         internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
             case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .unaryOperation(let function, let descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                }
            case .binaryOperation(let function, let descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
            
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            descriptionAccumulator = pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, descriptionAccumulator)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    mutating func setOperand(_ variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    mutating func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
        } else {
            clear()
            descriptionAccumulator = ""
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    fileprivate var internalProgram = [AnyObject]()
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let variabelName = op as? String {
                        if variableValues[variabelName] != nil {
                            setOperand(variabelName)
                        } else if let operation = op as? String{
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    mutating func clear() {
        pendingBinaryOperation = nil
        accumulator = 0
        descriptionAccumulator = "0"
        internalProgram.removeAll()
    }
    
    func getDescription() -> String {
      
//        return "cccc"
        let whitespace = (description.hasSuffix(" ") ? "" : " ")
        return resultIsPending ? (description + whitespace  + "...") : (description + whitespace  + "=")
    }
    
    
}


