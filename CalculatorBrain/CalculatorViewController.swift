//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Sanjib Ahmad on 10/24/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    private let defaultDisplayText = "0"

    @IBAction func clear() {
        operandStack = [Double]()
        userIsInTheMiddleOfTypingANumber = false
        display.text = defaultDisplayText
        history.text = " "
    }

    @IBAction func backspace(sender: UIButton) {
        appendHistory(" \(sender.currentTitle!) ")
        if display.text!.characters.count > 1 {
            display.text = String(display.text!.characters.dropLast())
        } else {
            userIsInTheMiddleOfTypingANumber = false
            display.text = defaultDisplayText
        }
    }
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if displayValue != nil {
                display.text =  "\(displayValue! * -1)"
            }
        } else {
            appendHistory(" ᐩ/- ")
            performOperation { -$0 }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit != ".") || (digit == "." && display.text!.rangeOfString(".") == nil) {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    private func appendHistory(value: String) {
        // Remove the last " = "
        if (value != " = ") && (history.text!.rangeOfString(" = ") != nil) {
            history.text = history.text!.stringByReplacingOccurrencesOfString(" = ", withString: "")
        }
        history.text = history.text! + value
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            appendHistory(display.text!)
            enter()
        }
        appendHistory(" \(operation) ")
        appendHistory(" = ")
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": displayValue = M_PI; enter()
        default: break
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = [Double]()
    
    var displayValue: Double? {
        get {
            if let displayValue = NSNumberFormatter().numberFromString(display.text!) {
                return displayValue.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = defaultDisplayText
            }
        }
    }

    // Overload the enter function for user input, because we want add to add it the history. The enter
    // function is also called from other places in the code where we don't want to add to history.
    
    @IBAction func enter(sender: UIButton) {
        appendHistory(display.text!)
        appendHistory(" ⏎ ")
        enter()
    }
    
    private func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            operandStack.append(displayValue!)
            print("operandStack = \(operandStack)")
        }
    }

}

