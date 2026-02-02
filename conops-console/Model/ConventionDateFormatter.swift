//
//  ConventionDateFormatter.swift
//  conops-console
//
//  Created by April White on 2/1/26.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation

/// Utility for formatting dates using a convention's timezone.
/// All dates in the database are stored in UTC, but should be displayed
/// in the convention's local timezone for user-facing views.
struct ConventionDateFormatter {

    /// The timezone to use for formatting dates
    let timeZone: TimeZone

    /// Creates a formatter using the convention's timezone.
    /// Falls back to the current timezone if the convention's timezone is invalid.
    init(convention: Convention) {
        if let tz = TimeZone(identifier: convention.timeZone) {
            self.timeZone = tz
        } else {
            self.timeZone = TimeZone.current
        }
    }

    /// Creates a formatter with an explicit timezone identifier.
    /// Falls back to the current timezone if the identifier is invalid.
    init(timeZoneIdentifier: String) {
        if let tz = TimeZone(identifier: timeZoneIdentifier) {
            self.timeZone = tz
        } else {
            self.timeZone = TimeZone.current
        }
    }

    // MARK: - Date Only Formatting

    /// Formats a date showing only the date portion (e.g., "Mar 15, 2026")
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Formats a date showing only the date in short format (e.g., "3/15/26")
    func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Date and Time Formatting

    /// Formats a date showing date and time (e.g., "Mar 15, 2026, 2:30 PM")
    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Formats a date showing date and time in short format (e.g., "3/15/26, 2:30 PM")
    func formatDateTimeShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Formats a date showing date and time with timezone (e.g., "Mar 15, 2026, 2:30:45 PM CDT")
    func formatDateTimeLong(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    // MARK: - Time Only Formatting

    /// Formats showing only the time (e.g., "2:30 PM")
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Custom Formatting

    /// Formats a date using a custom format string
    func format(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    // MARK: - Timezone Info

    /// Returns the timezone abbreviation (e.g., "CDT", "CST")
    func timeZoneAbbreviation(for date: Date = Date()) -> String {
        return timeZone.abbreviation(for: date) ?? timeZone.identifier
    }

    /// Returns the timezone's display name (e.g., "Central Daylight Time")
    var timeZoneDisplayName: String {
        return timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier
    }
}

// MARK: - Date Extension for Convenience

extension Date {
    /// Formats this date using the convention's timezone
    func formatted(using convention: Convention) -> ConventionFormattedDate {
        return ConventionFormattedDate(date: self, convention: convention)
    }
}

/// A wrapper that provides formatted date strings using a convention's timezone
struct ConventionFormattedDate {
    private let formatter: ConventionDateFormatter
    private let date: Date

    init(date: Date, convention: Convention) {
        self.date = date
        self.formatter = ConventionDateFormatter(convention: convention)
    }

    /// Date only (e.g., "Mar 15, 2026")
    var date_: String { formatter.formatDate(date) }

    /// Short date (e.g., "3/15/26")
    var dateShort: String { formatter.formatDateShort(date) }

    /// Date and time (e.g., "Mar 15, 2026, 2:30 PM")
    var dateTime: String { formatter.formatDateTime(date) }

    /// Short date and time (e.g., "3/15/26, 2:30 PM")
    var dateTimeShort: String { formatter.formatDateTimeShort(date) }

    /// Date, time, and timezone (e.g., "Mar 15, 2026, 2:30:45 PM CDT")
    var dateTimeLong: String { formatter.formatDateTimeLong(date) }

    /// Time only (e.g., "2:30 PM")
    var time: String { formatter.formatTime(date) }
}
