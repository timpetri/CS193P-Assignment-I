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
    
    @IBOutlet var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    

    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            
            let currentlyInDisplay = display.text!
            
            if "." != digit || !currentlyInDisplay.contains(".") {
            display.text = currentlyInDisplay + digit
            }
        } else {
            
            switch digit {
                case ".":
                    display.text = "0."
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
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue).beautifyNumbers()
        }
        
    }
    
    private var brain = CalculatorBrain()
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        
        if let description = brain.description {
            descriptionDisplay.text = description.beautifyNumbers() + (brain.resultIsPending ? "..." : "=")
        } else {
            descriptionDisplay.text = " "
        }
        
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain = CalculatorBrain()
        displayValue = 0
        descriptionDisplay.text = " "
        userIsInTheMiddleOfTyping = false
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
    func replace(pattern: String, with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSMakeRange(0, self.characters.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
    
    func beautifyNumbers() -> String {
        // [^0-9]|$ - not followed by other numbers or at the end of string
        
        return self.replace(pattern: "\\.0([^0-9]|$)", with: "$1")
    }
}

