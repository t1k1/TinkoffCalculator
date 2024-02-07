//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Aleksey Kolesnikov on 25.01.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
            case .add:
                return number1 + number2
            case .substract:
                return number1 - number2
            case .multiply:
                return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.dividedByZero
                }
                return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

final class ViewController: UIViewController {
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if (label.text == "0" || label.text == "Ошибка") && buttonText != "," {
            label.text = buttonText
        } else if label.text == "Ошибка" && buttonText == "," {
            label.text = "0,"
        } else if buttonText == "pi" {
            guard let text = label.text,
                  let pi = Int(text) else {
                return
            }
            label.text = calculatePi(number: pi)
        } else {
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle,
              let buttonOperation = Operation(rawValue: buttonText),
              let labelText = label.text,
              let labelNumber = numberForamatter.number(from: labelText)?.doubleValue else {
            return
        }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard let labelText = label.text,
              let labelNumber = numberForamatter.number(from: labelText)?.doubleValue else {
            return
        }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            label.text = numberForamatter.string(from: NSNumber(value: result))
            
            let newCalculation = Calculation(
                expression: calculationHistory,
                result: result,
                date: NSDate() as Date
            )
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
        }
        
        calculationHistory.removeAll()
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet var historyButton: UIButton!
    
    lazy var numberForamatter: NumberFormatter = {
        let numberForamatter = NumberFormatter()
        
        numberForamatter.usesGroupingSeparator = false
        numberForamatter.locale = Locale(identifier: "ru_Ru")
        numberForamatter.numberStyle = .decimal
        
        return numberForamatter
    }()
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    let calculationHistoryStorage = CalculationHistoryStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistoryStorage.loadHistory()
    }
}

extension ViewController {
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index+1] else {
                break
            }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetLabelText() {
        label.text = "0"
    }
    
    func calculatePi(number n: Int) -> String {
        let π = Double.pi
        return String(format: "%.\(n)f", π).replacingOccurrences(of: ".", with: ",")
    }
}
