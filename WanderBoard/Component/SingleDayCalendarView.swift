//
//  SingleDayCalendarView.swift
//  WanderBoard
//
//  Created by David Jang on 6/20/24.
//

import SwiftUI

struct SingleDayCalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showingDatePicker = false

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter

    var onDateSelected: ((Date) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    init(onDateSelected: ((Date) -> Void)? = nil) {
        self.onDateSelected = onDateSelected
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
    }

    var body: some View {
        VStack {
            HStack {
                Text(dateFormatter.string(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: { showingDatePicker.toggle() }) {
                    Image(systemName: showingDatePicker ? "chevron.down" : "chevron.right")
                        .foregroundColor(.black)
                }
            }
            .padding()

            if showingDatePicker {
                DatePicker("", selection: $currentMonth, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: currentMonth) { _ in
                        showingDatePicker = false
                    }
            } else {
                HStack(spacing: -28) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption2)
                            .foregroundColor(Color("darkgray"))
                    }
                }
                .padding(.bottom, 5)

                let days = generateDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                        Text(date != nil ? "\(calendar.component(.day, from: date!))" : "")
                            .frame(width: 30, height: 30)
                            .background(getBackgroundColor(for: date))
                            .foregroundColor(getTextColor(for: date))
                            .cornerRadius(15)
                            .onTapGesture {
                                if let date = date {
                                    selectedDate = date
                                }
                            }
                    }
                }
                .padding()
                .gesture(DragGesture().onEnded { value in
                    if value.translation.width < 0 {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    } else if value.translation.width > 0 {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                })
            }

            Spacer()

            Button(action: {
                if let selectedDate = selectedDate {
                    onDateSelected?(selectedDate)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("선택")
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(selectedDate != nil ? Color.black : Color("babygray"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedDate == nil)
            .padding(.horizontal)
        }
        .padding()
        .onChange(of: showingDatePicker) { _ in
            if !showingDatePicker {
                currentMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth), month: calendar.component(.month, from: currentMonth))) ?? Date()
            }
        }
    }

    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let _ = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        var days: [Date?] = []
        for dayOffset in 0..<(daysInMonth + firstWeekday - 1) {
            if dayOffset < firstWeekday - 1 {
                days.append(nil)
            } else {
                let day = dayOffset - (firstWeekday - 2)
                days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth))
            }
        }
        return days
    }

    private func getBackgroundColor(for date: Date?) -> Color {
        guard let date = date else { return Color.clear }

        if let selectedDate = selectedDate, calendar.isDate(date, inSameDayAs: selectedDate) {
            return Color.yellow
        }

        return Color.clear
    }

    private func getTextColor(for date: Date?) -> Color {
        guard let date = date else { return Color.clear }

        if let selectedDate = selectedDate, calendar.isDate(date, inSameDayAs: selectedDate) {
            return Color.black
        }

        return Color.primary
    }
}

struct SingleDayCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SingleDayCalendarView()
    }
}
