import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var shortFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }

    var timeFormatted: String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: self)
    }

    var dayOfWeekShort: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: self)
    }

    var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: self)
    }
}
