//
//  ViewController.swift
//  Demo
//
//  Created by Molnar Kristian on 5/24/17.
//  Copyright © 2017 Molnar Kristian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KeyboardDelegate {
  @IBOutlet weak var calculatorTextField: UITextField!

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let keyboardView = CalculatorInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
    keyboardView.delegate = self
    keyboardView.setTargedForKeyboard(target: self.calculatorTextField)
    calculatorTextField.inputView = keyboardView
    
  }

  func keyWasTapped(character: String) {
    // some reaction ro key pressing
  }
  
  func didUpdatedTextFieldResult(result: String) {
    self.calculatorTextField.text = String(result)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

