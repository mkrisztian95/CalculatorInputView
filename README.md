# Project Title

One Paragraph of project description goes here

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them



### Installing

Drag and Drop CalculatorInputView.xib and CalculatorInputView.swift file to your proj



```
class ViewController: UIViewController, KeyboardDelegate { ...

let keyboardView = CalculatorInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
keyboardView.delegate = self
keyboardView.setTargedForKeyboard(target: self.calculatorTextField)
calculatorTextField.inputView = keyboardView


func keyWasTapped(character: String) {
// some reaction ro key pressing
}

func didUpdatedTextFieldResult(result: String) {
self.calculatorTextField.text = String(result)
}
```

