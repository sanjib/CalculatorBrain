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
    private let defaultDisplayValue: Double = 0
    private let defaultHistoryText = " "
    
    var brain = CalculatorBrain()

    @IBAction func clear() {
        brain.clearStack()
        brain.variableValues.removeAll()
        displayValue = nil
        history.text = defaultHistoryText
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

    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber == true {
            if display.text!.characters.count > 1 {
                display.text = String(display.text!.characters.dropLast())
            } else {
                displayValue = defaultDisplayValue
            }
        } else {
            brain.removeLastOpFromStack()
            displayValue = brain.evaluate()
        }

    }
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if displayValue != nil {
                displayValue = displayValue! * -1
                userIsInTheMiddleOfTypingANumber = true
            }
        } else {
            displayValue = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func pi() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = brain.pushConstant("π")
    }
    
    @IBAction func setM() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            brain.variableValues["M"] = displayValue
        }
        displayValue = brain.evaluate()
    }
    
    @IBAction func getM() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = brain.pushOperand("M")
    }    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    // Because displayValue is now an Optional Double the task of showing a suitable (result, zero, error)
    // display text can be safely handed over to the setter of displayValue. Additionally history is also 
    // now assigned in the setter
    
    var displayValue: Double? {
        get {
            if let displayValue = NSNumberFormatter().numberFromString(display.text!) {
                return displayValue.doubleValue
            }
            return nil
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = "\(defaultDisplayValue)"
            }
            userIsInTheMiddleOfTypingANumber = false
            if !brain.description.isEmpty {
                history.text = " \(brain.description) ="
            } else {
                history.text = defaultHistoryText
            }            
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = defaultDisplayValue
            }
        }
    }
    
}

