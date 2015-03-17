import Foundation

extension NSDate {

    func startDateOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: self)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)

        return startOfMonth
    }

    func endDateOfMonth() -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        if let plusOneMonthDate = self.dateByAddingMonths(1) {
            let plusOneMonthDateComponents = calendar.components(
                .CalendarUnitYear | .CalendarUnitMonth, fromDate: plusOneMonthDate
            )
            return calendar.dateFromComponents(plusOneMonthDateComponents)?.dateByAddingTimeInterval(-1)
        }
        
        return nil
    }

    private func dateByAddingMonths(monthsToAdd: Int) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        let months = NSDateComponents()
        months.month = monthsToAdd

        return calendar.dateByAddingComponents(months, toDate: self, options: nil)
    }

}