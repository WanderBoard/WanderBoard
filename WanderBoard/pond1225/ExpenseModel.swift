//
//  ExpenseModel.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/3/24.
//

import Foundation


struct Expense {
    let date : Date
    let expenseContent : String
    let expenseAmount : Int
    let category : String
    let memo : String
    let imageName: String
}

struct DailyExpenses {
    let date : Date
    
    //spendingListVC의 @objc func didReceiveNewExpenseData에서 모델의 expenses를 let으로 하니 고정값을 변하게 하는 것이 불가능 하다고 오류떠서 let에서 var로 수정함.
    var expenses : [Expense]
}

var dailyExpenses: [DailyExpenses] = []
var expenses: [Expense] = []
