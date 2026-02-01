import Charts
import SwiftData
import SwiftUI

struct DashboardView: View {
    struct AttendancePoint: Identifiable {
        let dayOffset: Int
        let count: Int

        var id: Int { dayOffset }
    }

    struct AttendanceSeriesPoint: Identifiable {
        let dayOffset: Int
        let count: Int
        let series: String

        var id: String { "\(series)-\(dayOffset)" }
    }

    struct LevelCount: Identifiable {
        let id: MembershipLevelIdentifier
        let name: String
        let count: Int
    }

    struct ShirtSizeCount: Identifiable {
        let id: String
        let name: String
        let requested: Int
        let remaining: Int
    }

    let conventionId: ConventionIdentifier
    private let compareConventionId: ConventionIdentifier

    @Query private var conventions: [Convention]
    @Query private var attendees: [Attendee]
    @Query private var compareAttendees: [Attendee]
    @Query private var compareConventions: [Convention]

    init(conventionId: ConventionIdentifier, compareConventionId: ConventionIdentifier?) {
        self.conventionId = conventionId
        self.compareConventionId = compareConventionId ?? -1
        let selectedConventionId = conventionId
        let selectedCompareId = self.compareConventionId
        _conventions = Query(
            filter: #Predicate<Convention> { convention in
                convention.id == selectedConventionId
            })
        _attendees = Query(
            filter: #Predicate<Attendee> { attendee in
                attendee.conventionId == selectedConventionId && attendee.active == true
            })
        _compareAttendees = Query(
            filter: #Predicate<Attendee> { attendee in
                attendee.conventionId == selectedCompareId && attendee.active == true
            })
        _compareConventions = Query(
            filter: #Predicate<Convention> { convention in
                convention.id == selectedCompareId
            })
    }

    private var registrationsCount: Int {
        activeAttendees.count
    }

    private var checkedInCount: Int {
        activeAttendees.filter { $0.checkInTime != nil }.count
    }

    private var currentConvention: Convention? {
        conventions.first
    }

    private var levelCounts: [LevelCount] {
        guard let convention = currentConvention else { return [] }
        let counts = Dictionary(grouping: activeAttendees, by: \Attendee.membershipLevel)
            .mapValues { $0.count }

        return convention.membershipLevels.sorted().map { level in
            LevelCount(
                id: level.id,
                name: level.shortName,
                count: counts[level.id, default: 0]
            )
        }
    }

    private var shirtSizeCounts: [ShirtSizeCount] {
        guard let convention = currentConvention else { return [] }
        let requestedCounts = Dictionary(grouping: activeAttendees, by: \Attendee.shirtSize)
            .mapValues { $0.count }

        return convention.shirtSizes.sorted().map { size in
            let requested = requestedCounts[size.size, default: 0]
            let remaining = max(Int(size.initialInventory) - requested, 0)
            return ShirtSizeCount(
                id: size.size,
                name: size.size,
                requested: requested,
                remaining: remaining
            )
        }
    }

    private var shirtSizePalette: [Color] {
        ChartPalette.seriesColors(count: shirtSizeCounts.count)
    }

    private var attendanceSeries: [AttendancePoint] {
        guard let convention = currentConvention else { return [] }
        return attendanceSeries(for: convention, attendees: activeAttendees, limitToToday: true)
    }

    private var compareAttendanceSeries: [AttendancePoint] {
        guard let compareConvention = compareConventions.first else { return [] }
        return attendanceSeries(
            for: compareConvention, attendees: compareAttendees, limitToToday: false)
    }

    private var attendanceChartData: [AttendanceSeriesPoint] {
        guard let convention = currentConvention else { return [] }
        var points: [AttendanceSeriesPoint] = []
        if let compareConventionShortName {
            points.append(
                contentsOf: compareAttendanceSeries.map {
                    AttendanceSeriesPoint(
                        dayOffset: $0.dayOffset, count: $0.count, series: compareConventionShortName
                    )
                })
        }
        points.append(
            contentsOf: attendanceSeries.map {
                AttendanceSeriesPoint(
                    dayOffset: $0.dayOffset, count: $0.count, series: convention.shortName)
            })
        return points
    }

    private var attendanceSeriesNames: [String] {
        guard let convention = currentConvention else { return [] }
        var names = [convention.shortName]
        if let compareConventionShortName {
            names.append(compareConventionShortName)
        }
        return names
    }

    private var compareConventionShortName: String? {
        compareConventions.first?.shortName
    }

    private var activeAttendees: [Attendee] {
        attendees.filter { $0.active }
    }

    private func attendanceSeries(
        for convention: Convention,
        attendees: [Attendee],
        limitToToday: Bool
    ) -> [AttendancePoint] {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: convention.preRegStartDate)
        let endDate =
            limitToToday
            ? min(calendar.startOfDay(for: convention.endDate), calendar.startOfDay(for: Date()))
            : calendar.startOfDay(for: convention.endDate)

        guard startDate <= endDate else { return [] }

        let dailyCounts = Dictionary(
            grouping: attendees,
            by: { attendee in
                let day = calendar.startOfDay(for: attendee.registrationDate)
                return calendar.dateComponents([.day], from: startDate, to: day).day ?? 0
            }
        )
        .mapValues { $0.count }

        var points: [AttendancePoint] = []
        var runningTotal = 0
        var currentDate = startDate
        var dayOffset = 0

        while currentDate <= endDate {
            runningTotal += dailyCounts[dayOffset, default: 0]
            points.append(AttendancePoint(dayOffset: dayOffset, count: runningTotal))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
            dayOffset += 1
        }

        return points
    }

    var body: some View {
        if let convention = currentConvention {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    statCards

                    attendanceSection

                    registrationsAndShirts
                }
                .padding(24)
            }
            .navigationTitle(convention.longName)
        } else {
            ContentUnavailableView(
                "Convention data unavailable",
                systemImage: "chart.bar.xaxis",
                description: Text("Syncing conventions...")
            )
        }
    }

    private var statCards: some View {
        HStack(spacing: 16) {
            StatCard(title: "Registrations", value: registrationsCount)
            StatCard(title: "Checked-In", value: checkedInCount)
        }
    }

    private var attendanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance")
                .font(.headline)

            Chart(attendanceChartData) { point in
                LineMark(
                    x: .value("Day", point.dayOffset),
                    y: .value("Registrations", point.count)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(by: .value("Series", point.series))
                .opacity(opacity(for: point.series))
                .zIndex(zIndex(for: point.series))

                PointMark(
                    x: .value("Day", point.dayOffset),
                    y: .value("Registrations", point.count)
                )
                .symbolSize(16)
                .foregroundStyle(by: .value("Series", point.series))
                .opacity(opacity(for: point.series))
                .zIndex(zIndex(for: point.series))
            }
            .chartForegroundStyleScale(
                range: ChartPalette.seriesColors(count: attendanceSeriesNames.count)
            )
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(minHeight: 220)
        }
    }

    private var registrationsAndShirts: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Registrations by Level")
                        .font(.headline)

                    Chart(levelCounts) { item in
                        BarMark(
                            x: .value("Registrations", item.count),
                            y: .value("Level", item.name)
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("Level", item.name))
                        .annotation(position: .trailing) {
                            Text(item.count, format: .number)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .chartForegroundStyleScale(
                        range: ChartPalette.seriesColors(count: levelCounts.count)
                    )
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(minHeight: 220)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Shirt Sizes")
                        .font(.headline)

                    Chart(shirtSizeCounts) { item in
                        SectorMark(
                            angle: .value("Requested", item.requested),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Size", item.name))
                    }
                    .chartForegroundStyleScale(range: shirtSizePalette)
                    .frame(minHeight: 220)

                    shirtSizeLegend
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Shirt Sizes Remaining")
                    .font(.headline)

                Chart(shirtSizeCounts) { item in
                    BarMark(
                        x: .value("Remaining", item.remaining),
                        y: .value("Size", item.name)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Size", item.name))
                    .annotation(position: .trailing) {
                        Text(item.remaining, format: .number)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }
                .chartForegroundStyleScale(
                    range: ChartPalette.seriesColors(count: shirtSizeCounts.count)
                )
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(minHeight: 220)
            }
        }
    }

    private var shirtSizeLegend: some View {
        let columns = [GridItem(.adaptive(minimum: 120), alignment: .leading)]

        let legendItems = Array(zip(shirtSizeCounts, shirtSizePalette))

        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(Array(legendItems.enumerated()), id: \.element.0.id) { _, item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.1)
                        .frame(width: 10, height: 10)
                    Text("\(item.0.name): \(item.0.requested)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func opacity(for series: String) -> Double {
        guard let compareConventionShortName else { return 1.0 }
        return series == compareConventionShortName ? 0.55 : 1.0
    }

    private func zIndex(for series: String) -> Double {
        guard let compareConventionShortName else { return 0 }
        return series == compareConventionShortName ? 0 : 1
    }
}

private struct StatCard: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value, format: .number)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statCardBackground)
        )
    }

    private var statCardBackground: Color {
        #if os(macOS)
            return Color(nsColor: .windowBackgroundColor)
        #else
            return Color(.secondarySystemBackground)
        #endif
    }
}

#Preview(traits: .modifier(ConventionPreviewModifier())) {
    DashboardView(conventionId: ConventionIdentifier(), compareConventionId: nil)
}
