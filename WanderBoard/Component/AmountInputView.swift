//
//  AmountInputView.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import SwiftUI

struct AmountInputView: View {
    @State private var amount: String = ""
    var onAmountEntered: ((Double) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    private let buttons: [[String]] = [
        //        ["1", "2", "3", "back"],
        //        ["4", "5", "6", "0"],
        //        ["7", "8", "9", "00"]
        
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["00", "0", "back"]
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(formatAmount(amount.isEmpty ? "0" : amount))
                    .font(.system(size: 24, weight: .bold))
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .trailing)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(50)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            
            ForEach(buttons, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            buttonTapped(button)
                        }) {
                            if button == "back" {
                                Image(systemName: "arrow.backward")
                                    .frame(width: 100, height: 60)
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(50)
                                    .font(.system(size: 20, weight: .semibold))
                            } else if button == "00" {
                                Text(button)
                                    .frame(width: 100, height: 60)
                                    .background(Color.mint)
                                    .foregroundColor(.white)
                                    .cornerRadius(50)
                                    .font(.system(size: 20, weight: .semibold))
                            } else {
                                Text(button)
                                    .frame(width: 100, height: 60)
                                    .background(Color.babygray)
                                    .foregroundColor(.black)
                                    .cornerRadius(50)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Button(action: {
                if let enteredAmount = Double(amount) {
                    onAmountEntered?(enteredAmount)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(!amount.isEmpty ? Color.black : Color("babygray"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(amount.isEmpty)
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func buttonTapped(_ button: String) {
        if button == "back" {
            if !amount.isEmpty {
                amount.removeLast()
            }
        } else {
            amount.append(button)
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        if let number = Double(amount) {
            return numberFormatter.string(from: NSNumber(value: number)) ?? amount
        }
        return amount
    }
}

struct AmountInputView_Previews: PreviewProvider {
    static var previews: some View {
        AmountInputView()
    }
}
