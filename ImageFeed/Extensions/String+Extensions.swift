import Foundation

extension String {
    private static let dateFormatter = ISO8601DateFormatter()
    func toDateFromISO8601() -> Date? { String.dateFormatter.date(from: self) }
}
