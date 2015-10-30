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
    
    var brain = CalculatorBrain()

    @IBAction func clear() {
        brain.clearStack()
        brain.variableValues.removeAll()
        displayValue = nil
        history.text = " "
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

    @IBAction func backspace(sender: UIButton) {
        appendHistory(" \(sender.currentTitle!) ")
        if display.text!.characters.count > 1 {
            display.text = String(display.text!.characters.dropLast())
        } else {
            displayValue = defaultDisplayValue
        }
    }
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if displayValue != nil {
                displayValue = displayValue! * -1
                userIsInTheMiddleOfTypingANumber = true
            }
        } else {
            appendHistory(" ᐩ/- ")
            displayValue = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func pi() {
        if userIsInTheMiddleOfTypingANumber {
            appendHistory(display.text!)
            enter()
        }
        appendHistory(" π ")
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
            appendHistory(display.text!)
            enter()
        }
        displayValue = brain.pushOperand("M")
    }    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            appendHistory(display.text!)
            enter()
        }
        if let operation = sender.currentTitle {
            appendHistory(" \(operation) ")
            appendHistory(" = ")
            displayValue = brain.performOperation(operation)
        }
    }
    
    // Because displayValue is now an Optional Double the task of showing a suitable (result, zero, error)
    // display text can be safely handed over to the setter of displayValue.
    
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
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = defaultDisplayValue
            }
        }
    }

}

