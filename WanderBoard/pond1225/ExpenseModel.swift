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
    let expenseAmount : Double
    let category : String
    let memo : String
}

struct DailyExpenses {
    let date : Date
    let expenses : [Expense]
}

var dailyExpenses: [DailyExpenses] = []
