//
//  ContentView.swift
//  Calcu1at0r
//
//  Created by 獨鈷青空 on 2024/07/30.
//

import SwiftUI

struct ContentView: View {
    @State private var firstText: String = "0"
    @State private var secondText: String = ""
    @State private var displayText: String = "0"
    @State private var type: Int = 0
    
    // ボタンのタイトルを保持する2次元配列
    let buttons: [[String]] = [
        ["AC", "±", "×", "÷"],
        ["1",".","-","+"],
        ["0","="]
    ]
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack(spacing: 10) {
                // 表示部分
                HStack {
                    Spacer()
                    Text(displayText)
                        .font(.system(size: self.buttonHeight() / 1.1))
                        .padding()
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                
                // ボタン部分
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                self.didTapButton(button: button)
                            }) {
                                Text(button)
                                    .font(.system(size: self.buttonHeight() / 2.2))
                                    .frame(width: self.buttonWidth(button: button), height: self.buttonHeight())
                                    .background(self.buttonColor(button: button))
                                    .foregroundColor(.white)
                                    .cornerRadius(self.buttonHeight() / 2)
                            }
                        }
                    }
                }
            }
            .padding(.all, 10)
        }
    }
    
    // ボタンの幅を計算するメソッド
    func buttonWidth(button: String) -> CGFloat {
        if button == "0" || button == "=" {
            return (UIScreen.main.bounds.width - 50) / 2
        }
        return (UIScreen.main.bounds.width - 60) / 4
    }
    
    // ボタンの高さを計算するメソッド
    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - 60) / 4
    }
    
    // ボタンの背景色を設定するメソッド
    func buttonColor(button: String) -> Color {
        if ["AC", "±","÷", "×", "-", "+", "="].contains(button) {
            return .cyan
        } else {
            return .gray
        }
    }
    
    func binaryToDouble(_ binaryString: String) -> Double? {
        guard let pointIndex = binaryString.firstIndex(of: ".") else {
            if let int = Int(binaryString, radix: 2) {
                return Double(int)
            }
            return nil
        }

        let integerPart = String(binaryString[..<pointIndex])
        let fractionalPart = String(binaryString[binaryString.index(after: pointIndex)...])

        let integer = Double(Int(integerPart, radix: 2) ?? 0)
        var fraction = 0.0

        for (index, digit) in fractionalPart.enumerated() {
            if digit == "1" {
                fraction += 1 / pow(2.0, Double(index + 1))
            }
        }

        return integer + fraction
    }

    
    func decimalToBinary(_ number: Double) -> String {
        // 整数部分
        let integerPart = Int(number)
        let integerBinaryString = String(integerPart, radix: 2)
        
        // 小数部分
        var fractionalPart = number - Double(integerPart)
        var fractionalBinaryString = ""
        
        while fractionalPart > 0 {
            fractionalPart *= 2
            if fractionalPart >= 1 {
                fractionalBinaryString.append("1")
                fractionalPart -= 1
            } else {
                fractionalBinaryString.append("0")
            }
            
            // 必要に応じてループを制限（ここでは20桁に制限）
            if fractionalBinaryString.count > 20 {
                break
            }
        }
        
        let binaryString = fractionalBinaryString.isEmpty ? integerBinaryString : "\(integerBinaryString).\(fractionalBinaryString)"
        
        // 文字列をDouble型に変換
        return binaryString
    }

    func calculate(type: Int) {
        outerIf: if let firstValue = binaryToDouble(firstText), let secondValue = binaryToDouble(secondText) {
            switch type {
            case 1://除法
                if secondValue == 0 {
                    displayText = "error"
                    break outerIf
                } else {
                    firstText = decimalToBinary(firstValue / secondValue)
                }
            case 2://乗法
                firstText = decimalToBinary(firstValue * secondValue)
            case 3://減法
                firstText = decimalToBinary(firstValue - secondValue)
            case 4://加法
                firstText = decimalToBinary(firstValue + secondValue)
            default:
                break outerIf
            }
            // 結果が整数の場合、".0"を消去
            if let firstValue = Double(firstText) {
                if floor(firstValue) == firstValue {
                    firstText = String(Int(firstValue))
                }
            }
            displayText = firstText
            secondText = ""
            self.type = 0
        }
    }
    // ボタンが押された時の処理
    func didTapButton(button: String) {

        if displayText == "error" {
            firstText = "0"
            secondText = ""
            displayText = "0"
            type = 0
        }
        switch button {
        case "AC":
            firstText = "0"
            secondText = ""
            displayText = "0"
            type = 0
        case "+":
            calculate(type: type)// type == 0の場合skipされる
            type = 4
        case "-":
            calculate(type: type)
            type = 3
        case "×":
            calculate(type: type)
            type = 2
        case "÷":
            calculate(type: type)
            type = 1
        case "=":
            calculate(type: type)

        case ".":// 数字が少数でない場合のみ追加を許可
            if type == 0 {
                if !firstText.contains(".") {
                    if firstText == "" {
                        firstText = "0."
                    } else {
                        firstText += "."
                    }
                }
                displayText = firstText
            } else {
                if !secondText.contains(".") {
                    if secondText == "" {
                        secondText = "0."
                    } else {
                        secondText += "."
                    }
                }
                displayText = secondText
            }
        case "±":
            if type == 0 {
                if var firstValue = Double(firstText) {
                    firstValue = -1 * firstValue
                    // 結果が整数の場合、".0"を消去
                    if floor(firstValue) == firstValue {
                            firstText = String(Int(firstValue))
                    } else {
                        firstText = String(firstValue)
                    }
                    displayText = firstText
                }
            } else {
                if var secondValue = Double(secondText) {
                    secondValue = -1 * secondValue
                    if floor(secondValue) == secondValue {
                        secondText = String(Int(secondValue))
                    } else {
                        secondText = String(secondValue)
                    }
                    displayText = secondText
                }
            }
        default: // 0,1の処理
            if type == 0 {
                if firstText == "0" {
                    firstText = button
                } else {
                    firstText += button
                }
                displayText = firstText
            } else {
                if secondText == "0" {
                    secondText = button
                } else {
                    secondText += button
                }
                displayText = secondText
            }
        }
    }
}

// 誤差の改善:skip
//クリアボタンの実装:skip
//負の数の入力:skip
//2進数への処理変更、表示はそのままで計算する際に一度10進数にしてから計算し、再度2進数に戻す。
//%の扱い: delete
//演算子を押すと色が変わる:skip
//大きい数の処理: skip
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
