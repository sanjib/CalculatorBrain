//
//  CalculatorBrain.swift
//  CalculatorBrain
//
//  Created by Sanjib Ahmad on 10/26/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                let intValue = Int(operand)
                if Double(intValue) == operand {
                    return "\(intValue)"
                } else {
                    return "\(operand)"
                }
            case .Variable(let symbol):
                return "\(symbol)"
            case .Constant(let symbol, _):
                return "\(symbol)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            }
        }
        
        var precedence: Int {
            switch self {
            case .Operand(_), .Variable(_), .Constant(_, _), .UnaryOperation(_, _):
                return Int.max
            case .BinaryOperation(_, _):
                return Int.min
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    
    // Describes contents of the brain (var opStack)
    var description: String {
        let (descriptionArray, _) = description([String](), ops: opStack)
        return descriptionArray.joinWithSeparator(", ")
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("ᐩ/-") { -$0 })
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.Constant("π", M_PI))
    }
    
    private func description(currentDescription: [String], ops: [Op]) -> (accumulatedDescription: [String], remainingOps: [Op]) {
        var accumulatedDescription = currentDescription
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeFirst()
            switch op {
            case .Operand(_), .Variable(_), .Constant(_, _):
                accumulatedDescription.append(op.description)
                return description(accumulatedDescription, ops: remainingOps)
            case .UnaryOperation(let symbol, _):
                if !accumulatedDescription.isEmpty {
                    let unaryOperand = accumulatedDescription.removeLast()
                    accumulatedDescription.append(symbol + "(\(unaryOperand))")
                    let (newDescription, remainingOps) = description(accumulatedDescription, ops: remainingOps)
                    return (newDescription, remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                if !accumulatedDescription.isEmpty {
                    let binaryOpearndLast = accumulatedDescription.removeLast()
                    if !accumulatedDescription.isEmpty {
                        let binaryOpearndFirst = accumulatedDescription.removeLast()
                        
                        if op.precedence == remainingOps.first?.precedence {
                            if op.description == remainingOps.first?.description {
                                accumulatedDescription.append("\(binaryOpearndFirst)" + symbol + "\(binaryOpearndLast)")
                            } else {
                                accumulatedDescription.append("(\(binaryOpearndFirst)" + symbol + "\(binaryOpearndLast))")
                            }
                        } else {
                            if op.description == remainingOps.first?.description {
                                accumulatedDescription.append("\(binaryOpearndFirst)" + symbol + "\(binaryOpearndLast)")
                            } else {
                                if !remainingOps.isEmpty {
                                    accumulatedDescription.append("(\(binaryOpearndFirst)" + symbol + "\(binaryOpearndLast))")
                                } else {
                                    accumulatedDescription.append("\(binaryOpearndFirst)" + symbol + "\(binaryOpearndLast)")
                                }                                
                            }
                        }
                        
                        return description(accumulatedDescription, ops: remainingOps)
                    } else {
                        accumulatedDescription.append("?" + symbol + "\(binaryOpearndLast)")
                        return description(accumulatedDescription, ops: remainingOps)
                    }
                } else {
                    accumulatedDescription.append("?" + symbol + "?")
                    return description(accumulatedDescription, ops: remainingOps)
                }
            }
        }
        return (accumulatedDescription, ops)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let symbol):
                if let variableValue = variableValues[symbol] {
                    return (variableValue, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .Constant(_, let constantValue):
                return (constantValue, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clearStack() {
        opStack = [Op]()
    }
    
    func removeLastOpFromStack() {
        if opStack.last != nil {
            opStack.removeLast()
        }
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        if let constant = knownOps[symbol] {
            opStack.append(constant)
        }        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}