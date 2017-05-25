# Demo



### Installing

Drag and Drop CalculatorInputView.xib and CalculatorInputView.swift file to your proj



```
class ViewController: UIViewController, KeyboardDelegate { ...

let keyboardView = CalculatorInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
keyboardView.delegate = self
keyboardView.setTargedForKeyboard(target: self.calculatorTextField)
calculatorTextField.inputView = keyboardView


func keyWasTapped(character: String) {
// some reaction to key pressing
}

func didUpdatedTextFieldResult(result: String) {
self.calculatorTextField.text = result
}
```

