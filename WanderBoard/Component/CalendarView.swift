//
//  CalendarView.swift
//  WanderBoard
//
//  Created by David Jang on 6/14/24.
//

//import SwiftUI
//import HorizonCalendar
//
//struct CalendarView: View {
//    @Binding var startDate: Date?
//    @Binding var endDate: Date?
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        CalendarRepresentable(startDate: $startDate, endDate: $endDate, onDismiss: { dismiss() })
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(.systemBackground))
//            .edgesIgnoringSafeArea(.all)
//    }
//}
//
//// SwiftUI Preview 환경 설정
//struct CalendarView_Previews: PreviewProvider {
//    @State static var startDate: Date? = Date() // 더미 시작 날짜
//    @State static var endDate: Date? = Date().addingTimeInterval(86400 * 5) // 더미 종료 날짜 (5일 후)
//
//    static var previews: some View {
//        CalendarView(startDate: $startDate, endDate: $endDate)
//    }
//}
//
//
//
//struct CalendarRepresentable: UIViewRepresentable {
//    @Binding var startDate: Date?
//    @Binding var endDate: Date?
//    var onDismiss: () -> Void
//
//    func makeUIView(context: Context) -> CalendarView {
//        let calendarView = CalendarView(initialContent: makeContent())
//        return calendarView
//    }
//
//    func updateUIView(_ uiView: CalendarView, context: Context) {
//        uiView.setContent(makeContent())
//    }
//
//    private func makeContent() -> CalendarViewContent {
//        let calendar = Calendar.current
//        let visibleStartDate = calendar.date(from: DateComponents(year: 2020, month: 1, day: 1))!
//        let visibleEndDate = calendar.date(from: DateComponents(year: 2022, month: 12, day: 31))!
//
//        return CalendarViewContent(
//            calendar: calendar,
//            visibleDateRange: visibleStartDate...visibleEndDate,
//            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
//            .withDayItemModelProvider(for: DayRange) { day in
//                var dayConfig = DayConfiguration()
//                let date = calendar.startOfDay(for: day.date)
//                let isSelected = (self.startDate == date || (self.startDate != nil && self.endDate != nil && date >= self.startDate! && date <= self.endDate!))
//                if isSelected {
//                    dayConfig.backgroundColor = .red
//                }
//                return dayConfig
//            }
//    }
//}

// DayConfiguration와 같은 누락된 구조체나 클래스는 HorizonCalendar 라이브러리 내에 정의되어 있어야 합니다.

