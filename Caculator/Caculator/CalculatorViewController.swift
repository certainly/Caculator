//
//  ViewController.swift
//  Caculator
//
//  Created by certainly on 2017/3/20.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    var userIsInMiddleOfTyping = false
    fileprivate func updateUI() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result ?? 42
        graphButton.isEnabled = !brain.resultIsPending
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        if userIsInMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || !textCurrentlyInDisplay.contains(".") {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0"
            } else {
                display!.text =  digit
            }
            userIsInMiddleOfTyping = true
        }

    }

    var displayValue: Double {
        get {
            
            return Double(display.text!)!
        }
        set {
            
//            print("ctld dd")
            descriptionLabel.text = brain.getDescription()
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
//        if let result = brain.result {
//        }
        updateUI()
        
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInMiddleOfTyping == true else {
            brain.undo()
            updateUI()
            return
        }
        
        guard var number = display.text else {
            return
        }
        number = String(number.characters.dropLast(1))
        if number.isEmpty {
            number = "0"
            userIsInMiddleOfTyping = false
        }
        display.text = number
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        userIsInMiddleOfTyping = false
    }
    
   static func DLog(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let filename = file.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        print("ctl \(filename) : \(line) -> \(function)  - \(message)")
    }
    @IBAction func setVariable(_ sender: Any) {
        brain.variableValues[Constants.Math.variableName] = displayValue
        if userIsInMiddleOfTyping {
            userIsInMiddleOfTyping = false
        } else {
            brain.undo()
        }
        
        brain.program = brain.program
        updateUI()
    }
    
    @IBAction func getVariable() {
        brain.setOperand(Constants.Math.variableName)
        userIsInMiddleOfTyping = false
        updateUI()
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result!
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Graph":
                guard !brain.resultIsPending else {
                    NSLog(Constants.Error.partialResult)
                    return
                }
                
                var destinationVC = segue.destination
                if let nvc = destinationVC as? UINavigationController {
                    destinationVC = nvc.visibleViewController ?? destinationVC
                }
                
                if let vc = destinationVC as? GraphViewController {
                    vc.navigationItem.title = brain.description
                    vc.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues[Constants.Math.variableName] = Double(x)
                        self.brain.program = self.brain.program
                        return self.brain.result!
                    }
                }
            default:
                break
            }
        }
    }
}

