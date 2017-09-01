//
//  ViewController.swift
//  CalculatorV2
//
//  Created by Tim Petri on 8/6/17.
//  Copyright © 2017 Tim Petri. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet weak var descriptionDisplay: UILabel!
    
    @IBOutlet weak var memoryDisplay: UILabel!
    
    @IBOutlet var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBOutlet weak var decimalSeparatorButton: UIButton!
    
    private let decimalSeparator = NumberFormatter().decimalSeparator!
    
    private var variables = Dictionary<String, Double>() {
        didSet {
            memoryDisplay.text = variables.flatMap{$0+":\($1)"}.joined(separator: ", ").beautifyNumbers()
        }
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            
            let currentlyInDisplay = display.text!
            
            if decimalSeparator != digit || !currentlyInDisplay.contains(decimalSeparator) {
            display.text = currentlyInDisplay + digit
            }
        } else {
            
            switch digit {
                case decimalSeparator:
                    display.text = "0" + decimalSeparator
                case "0":
                    if "0" == display.text {
                        return
                    }
                    fallthrough
                default:
                    display.text = digit
                }
                userIsInTheMiddleOfTyping = true
            }
    }
    
    var displayValue: Double {
        get {
            return (NumberFormatter().number(from: display.text!)?.doubleValue)!
            //return Double(display.text!)!
        }
        set {
            display.text = String(newValue).beautifyNumbers()
        }
        
    }
    

    
    private var brain = CalculatorBrain()
    
    private func displayResult() {
        let evaluated = brain.evaluate(using: variables)
        if let result = evaluated.result {
            displayValue = result
        }
        
        if "" != evaluated.description {
            descriptionDisplay.text = evaluated.description.beautifyNumbers() + (evaluated.isPending ? "..." : "=")
        } else {
            descriptionDisplay.text = " "
        }

    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayResult()
    }
    
    @IBAction func storeToMemory(_ sender: UIButton) {
        variables["M"] = displayValue
        userIsInTheMiddleOfTyping = false
        displayResult()
    }
    
    @IBAction func callMemory(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        userIsInTheMiddleOfTyping = false
        displayResult()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain = CalculatorBrain()
        displayValue = 0
        descriptionDisplay.text = " "
        memoryDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        variables = Dictionary<String, Double>()
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        
        // swift will only execute the if body if all assignments are properly completed
        if userIsInTheMiddleOfTyping, var text = display.text {
            text.remove(at: text.index(before: text.endIndex))
            if text.isEmpty || "0" == text { // second cond ensures no trailing 0s
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = text
        }
    }
    
    private func adjustButtonLayout (for view: UIView, isPortrait:Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            } else if subview.tag == 2 {
                subview.isHidden = !isPortrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(UIColor.black, forState: .highlighted)
                button.setTitleColor(UIColor.white, for: .highlighted)
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
        
        decimalSeparatorButton.setTitle(decimalSeparator, for: .normal)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: state)
    }
}

extension String {
    
    static let DecimalDigits = 6
    
    func replace(pattern: String, with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSMakeRange(0, self.characters.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
    
    func beautifyNumbers() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = String.DecimalDigits
        
        var text = self as NSString
        var numbers = [String]()
        let regex = try! NSRegularExpression(pattern: "[.0-9]+", options: .caseInsensitive)
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, text.length))
        numbers = matches.map { text.substring(with:$0.range) }
        
        for number in numbers {
            text = text.replacingOccurrences(
                of: number,
                with: formatter.string(from: NSNumber(value: Double(number)!))!
            ) as NSString
        }

        return text as String
        
        // - old
        // [^0-9]|$ - not followed by other numbers or at the end of string
        //return self.replace(pattern: "\\.0([^0-9]|$)", with: "$1")
    }
}

