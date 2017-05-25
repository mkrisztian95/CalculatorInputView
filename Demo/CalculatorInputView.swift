//
//  CalculatorInputView.swift
//  Demo
//
//  Created by Molnar Kristian on 5/24/17.
//  Copyright © 2017 Molnar Kristian. All rights reserved.
//

import UIKit

//protocol user for communication with the view controller
protocol KeyboardDelegate: class {
  func keyWasTapped(character: String)
  func didUpdatedTextFieldResult(result: String)
}

//
private class CalculatorBrain {

  class func getresult(expression:String) -> String {
    let text:String = expression
      .replacingOccurrences(of: "x", with: " * ")
      .replacingOccurrences(of: "÷", with: " / ")
      .replacingOccurrences(of: ",", with: "")
    
    let result = NSExpression(format: text).expressionValue(with: nil, context: nil) as! NSNumber
    
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 4
    formatter.allowsFloats = true
    formatter.numberStyle = .decimal
    formatter.decimalSeparator = "."
    
    return formatter.string(from: result)!
    
  }

}


class CalculatorInputView: UIView {
  @IBOutlet weak var doneButton: UIButton!
  
  //the array of possible operators
  private let operatorArray = ["+", "-", "x", "÷"]
  
  //keyboardDelegate to inform Controller anout changes
  weak var delegate: KeyboardDelegate?
  
  //the tracked textfield's object
  fileprivate weak var targetTextField:UITextField!
  
  // MARK: - initalizing the Calculator View
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeSubviews()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeSubviews()
  }
  
  
  func initializeSubviews() {
    let xibFileName = "CalculatorInputView" // xib extention not included
    let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
    self.addSubview(view)
    view.frame = self.bounds
  }
 
  // MARK: - actions with buttons on calculator
  
  //full clrear (Button C) tapped
  @IBAction func clearTapped(_ sender: Any) {
    self.targetTextField.text = ""
  }
  
  //"backSpace" tapped
  @IBAction func deleteAction() {
    guard !(self.targetTextField.text?.isEmpty)! else {
      return
    }
    if let selectedRange = targetTextField.selectedTextRange {
      let cursorPosition = targetTextField.offset(from: targetTextField.beginningOfDocument, to: selectedRange.start)
      self.targetTextField.text?.remove(at: (self.targetTextField.text?.index((self.targetTextField.text?.startIndex)!, offsetBy: cursorPosition - 1))!)
      
    }
    
  }
  
  //some operand or operator tapped
  @IBAction func keyTapped(sender: UIButton) {
    
    self.doneButton.setTitle("=", for: .normal)
    //the caption of the button that was tapped
    guard let tappedCaption = sender.titleLabel!.text else {
      return
    }
    self.delegate?.keyWasTapped(character: tappedCaption)
    
    //the actual text whitin the textField
    var text:String = targetTextField.text!
    
    //is selected some range in the
    if let selectedRange = targetTextField.selectedTextRange {
      //getting the actual position of the cursor
      let cursorPosition = targetTextField.offset(from: targetTextField.beginningOfDocument, to: selectedRange.start)
      
      
      //if firstSymbol is an operator
      if text.isEmpty && tappedCaption.isAnOperator() {
        return
      }
      
      
      //if first symbol is a decimal separator
      if text.isEmpty && tappedCaption.isDecimalSeparator() {
        return
      }
      
      //if changed first char
      if !text.isEmpty && cursorPosition == 0 && tappedCaption.isAnOperator() {
        self.targetTextField.text = tappedCaption == "-" ?  "\(tappedCaption)\(text)" : text
        return
      }
      
      //if the symbol is a decimal separator and an operator was tapped
      if !text.isEmpty && Character(text[cursorPosition - 1]).isDecimalSeparator() && tappedCaption.isAnOperator()  {
        return
      }
      
      //if an operattor war tapped and before them is existing an other operator
      if !text.isEmpty && Character(text[cursorPosition - 1]).isAnOperator() && tappedCaption.isAnOperator(){
        self.targetTextField.text = text.replacingCharacters(in: text.getrange(cursorPosition - 1, length: 1)!, with: tappedCaption)
        return
      }
      
      //if an operattor war tapped and after them is existing an other operator
      if  cursorPosition < text.characters.count {
        if !text.isEmpty && Character(text[cursorPosition]).isAnOperator() && tappedCaption.isAnOperator()  {
          self.targetTextField.text = text.replacingCharacters(in: text.getrange(cursorPosition, length: 1)!, with: tappedCaption)
          return
        }
      }
      
      //if the tapped caption is a decimal separator, checking the validity of the numbers after placyng one more decimal separator
      if tappedCaption.isDecimalSeparator() {
        text.insert(Character(tappedCaption), at: (self.targetTextField.text?.index((self.targetTextField.text?.startIndex)!, offsetBy: cursorPosition))!)
        
        if !isCorrectlyPlacedDecimalSeparator(numbers: text.getNumbersFromString()) {
          return
        }
        
      }
      
      // if triple  zero tapped
      if tappedCaption == "000" {
        for item in tappedCaption.characters {
          self.targetTextField.text?.insert(item, at: (self.targetTextField.text?.index((self.targetTextField.text?.startIndex)!, offsetBy: cursorPosition))!)
        }
      } else {
        self.targetTextField.text?.insert(Character(tappedCaption), at: (self.targetTextField.text?.index((self.targetTextField.text?.startIndex)!, offsetBy: cursorPosition))!)
      }
      
      //checking the last symbol of our's textfield
      if self.targetTextField.text?.characters.last == "." || self.targetTextField.text?.characters.last == "0" { return }
      
      //formatting the text if everything went rigth
      let formattedNumbers:[String] = longNumberFormatter(numbers: targetTextField.getNumbersFromTextField())
      let operators = getAllOperatorsFromText(text: self.targetTextField.text!)
      self.targetTextField.text = getFormattedText(operators: operators, numbers: formattedNumbers)
      
      
    }
    
    
  }
  
  
  //Done Button was Tapped
  @IBAction func countAction(_ sender: Any) {
    guard self.doneButton.title(for: .normal) != "DONE" else {
      self.targetTextField.resignFirstResponder()
      return
    }
   
    guard !(self.targetTextField.text?.isEmpty)! else {
      return
    }
    
    if (targetTextField.text?.characters.last?.isAnOperator())! || (targetTextField.text?.characters.last?.isDecimalSeparator())! {
      targetTextField.text?.characters.removeLast()
    }
    delegate?.didUpdatedTextFieldResult(result: CalculatorBrain.getresult(expression: self.targetTextField.text!))
    self.doneButton.setTitle("DONE", for: .normal)
    
  }
  
  // MARK: - additional provate functions
  
  //method for checking the issue connected with multy decimal separators
  private func isCorrectlyPlacedDecimalSeparator(numbers:[String]) -> Bool {
    for item in numbers {
      if item.components(separatedBy: ".").count > 2 {
        return false
      }
    }
    
    return true
  }
  
  // formatting long numbers
  private func longNumberFormatter(numbers:[String]) -> [String] {
    var formattedNumbersArray:[String] = []
    for item:String in numbers {
      if item != "" || item.contains(".") {
       let fv = NSNumber(value: Double(item)!)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 10  
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formattedNumbersArray.append(formatter.string(from: fv)!)
      } else {
        formattedNumbersArray.append(item)
      }
    }
    
    return formattedNumbersArray
  }
  
  //separating all operators
  private func getAllOperatorsFromText(text:String) -> [String] {
    var resultArray:[String] = []
    for item in text.characters {
      if item.isAnOperator() {
        resultArray.append(String(item))
      }
    }
    return resultArray
  }
  
  //formatting the
  private func getFormattedText(operators:[String], numbers:[String]) -> String {
    var res = ""
    var i = 0
    for item in numbers {
      var oper = ""
      if operators.indices.contains(i) {
        oper = operators[i]
      }
      res = "\(res)\(item)\(oper)"
      i = i + 1
    }
    return res
  }
  
  
}

// MARK: - Character Extension

fileprivate extension Character {
  //checking is the selected character is an operator from keyboard
  func isAnOperator() -> Bool {
    let operatorArray:[Character] = ["+", "-", "x", "÷"]
    if operatorArray.contains(self) {
      return true
    }
    return false
  }
  
  //checking if a character is a decimal separator from our keyboard
  func isDecimalSeparator() -> Bool {
    return self == "." ? true : false
  }
}

// MARK: - String Extension


fileprivate extension String {
 
  //getting numbers array from string
  func getNumbersFromString() -> [String] {
    return (self.replacingOccurrences(of: "+", with: ":")
      .replacingOccurrences(of: "x", with: ":")
      .replacingOccurrences(of: "-", with: ":")
      .replacingOccurrences(of: "÷", with: ":")
      .replacingOccurrences(of: ",", with: "").components(separatedBy: ":"))
  }
  
  
  func isAnOperator() -> Bool {
    let operatorArray:[String] = ["+", "-", "x", "÷"]
    if operatorArray.contains(self) {
      return true
    }
    return false
  }
  
  func isDecimalSeparator() -> Bool {
    return self == "." ? true : false
  }
  
  subscript (i: Int) -> Character {
    return self[index(startIndex, offsetBy: i)]
  }
  
  subscript (i: Int) -> String {
    return String(self[i] as Character)
  }
  
  subscript (r: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: r.lowerBound)
    let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
    return self[Range(start ..< end)]
  }
  
  
  func getrange(_ from: Int, length: Int) -> Range<String.Index>? {
    guard let fromU16 = utf16.index(utf16.startIndex, offsetBy: from, limitedBy: utf16.endIndex), fromU16 != utf16.endIndex else {
      return nil
    }
    let toU16 = utf16.index(fromU16, offsetBy: length, limitedBy: utf16.endIndex) ?? utf16.endIndex
    guard let from = String.Index(fromU16, within: self),
      let to = String.Index(toU16, within: self) else { return nil }
    return from ..< to
  }
}

// MARK: - CalculatorInputView Extension

extension CalculatorInputView {
  //setting up target textview user for viewcontroller
  func setTargedForKeyboard(target:UITextField) {
    self.targetTextField = target
  }
}

// MARK: - UITextField Extension

fileprivate extension UITextField {
  func getNumbersFromTextField() -> [String] {
    return (self.text?.replacingOccurrences(of: "+", with: ":")
      .replacingOccurrences(of: "x", with: ":")
      .replacingOccurrences(of: "-", with: ":")
      .replacingOccurrences(of: "÷", with: ":")
      .replacingOccurrences(of: ",", with: "").components(separatedBy: ":"))!
  }
}


