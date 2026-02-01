//
//  AttendeeTableMac.swift
//  Conops Console
//
//  Created by April White on 1/31/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    enum AttendeeSortKey: String {
        case badgeName
        case badgeNumber
        case minor
        case staff
        case dealer
        case shirtSize
        case membershipLevel
        case idName
        case currentBalance
    }

    struct AttendeeSortDescriptor: Equatable {
        var key: AttendeeSortKey
        var ascending: Bool

        func compare(_ lhs: Attendee, _ rhs: Attendee) -> Bool {
            let result: ComparisonResult
            switch key {
            case .badgeName:
                result = lhs.badgeName.localizedCaseInsensitiveCompare(rhs.badgeName)
            case .badgeNumber:
                if lhs.badgeNumber == rhs.badgeNumber {
                    result = .orderedSame
                } else {
                    result =
                        lhs.badgeNumber < rhs.badgeNumber ? .orderedAscending : .orderedDescending
                }
            case .minor:
                if lhs.minor == rhs.minor {
                    result = .orderedSame
                } else {
                    result = lhs.minor ? .orderedDescending : .orderedAscending
                }
            case .staff:
                if lhs.staff == rhs.staff {
                    result = .orderedSame
                } else {
                    result = lhs.staff ? .orderedDescending : .orderedAscending
                }
            case .dealer:
                if lhs.dealer == rhs.dealer {
                    result = .orderedSame
                } else {
                    result = lhs.dealer ? .orderedDescending : .orderedAscending
                }
            case .shirtSize:
                let lhsSize = lhs.shirtSize ?? ""
                let rhsSize = rhs.shirtSize ?? ""
                result = lhsSize.localizedCaseInsensitiveCompare(rhsSize)
            case .membershipLevel:
                if lhs.membershipLevel == rhs.membershipLevel {
                    result = .orderedSame
                } else {
                    result =
                        lhs.membershipLevel < rhs.membershipLevel
                        ? .orderedAscending : .orderedDescending
                }
            case .idName:
                result = lhs.idName.localizedCaseInsensitiveCompare(rhs.idName)
            case .currentBalance:
                if lhs.currentBalance == rhs.currentBalance {
                    result = .orderedSame
                } else {
                    result =
                        lhs.currentBalance < rhs.currentBalance
                        ? .orderedAscending : .orderedDescending
                }
            }

            if ascending {
                return result == .orderedAscending
            } else {
                return result == .orderedDescending
            }
        }
    }

    struct AttendeeTableMac: NSViewRepresentable {
        let attendees: [Attendee]
        let convention: Convention
        let onDoubleClick: (Attendee) -> Void
        let onContextMenu: (Attendee) -> NSMenu?

        @Binding var selectedAttendeeId: AttendeeIdentifier?
        @Binding var sortDescriptor: AttendeeSortDescriptor

        private func membershipLevelName(for id: MembershipLevelIdentifier) -> String {
            convention.membershipLevels.first { $0.id == id }?.shortName ?? ""
        }

        func makeNSView(context: Context) -> NSScrollView {
            let scrollView = NSScrollView()
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = false
            scrollView.autohidesScrollers = true

            let tableView = NSTableView()
            tableView.style = .inset
            tableView.usesAlternatingRowBackgroundColors = true
            tableView.allowsMultipleSelection = false
            tableView.allowsColumnReordering = false
            tableView.rowHeight = 24

            // Define columns with sort descriptors
            let badgeNameColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("badgeName"))
            badgeNameColumn.title = "Name"
            badgeNameColumn.width = 150
            badgeNameColumn.minWidth = 100
            badgeNameColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "badgeName", ascending: true)
            tableView.addTableColumn(badgeNameColumn)

            let badgeNumberColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("badgeNumber"))
            badgeNumberColumn.title = "#"
            badgeNumberColumn.width = 60
            badgeNumberColumn.minWidth = 40
            badgeNumberColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "badgeNumber", ascending: true)
            tableView.addTableColumn(badgeNumberColumn)

            let minorColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("minor"))
            minorColumn.title = "Minor"
            minorColumn.width = 60
            minorColumn.minWidth = 50
            minorColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "minor", ascending: false)
            tableView.addTableColumn(minorColumn)

            let staffColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("staff"))
            staffColumn.title = "Staff"
            staffColumn.width = 60
            staffColumn.minWidth = 50
            staffColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "staff", ascending: false)
            tableView.addTableColumn(staffColumn)

            let dealerColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("dealer"))
            dealerColumn.title = "Dealer"
            dealerColumn.width = 60
            dealerColumn.minWidth = 50
            dealerColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "dealer", ascending: false)
            tableView.addTableColumn(dealerColumn)

            let shirtSizeColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("shirtSize"))
            shirtSizeColumn.title = "Shirt"
            shirtSizeColumn.width = 70
            shirtSizeColumn.minWidth = 50
            shirtSizeColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "shirtSize", ascending: true)
            tableView.addTableColumn(shirtSizeColumn)

            let membershipLevelColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("membershipLevel"))
            membershipLevelColumn.title = "Level"
            membershipLevelColumn.width = 100
            membershipLevelColumn.minWidth = 60
            membershipLevelColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "membershipLevel", ascending: true)
            tableView.addTableColumn(membershipLevelColumn)

            let idNameColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("idName"))
            idNameColumn.title = "ID Name"
            idNameColumn.width = 180
            idNameColumn.minWidth = 120
            idNameColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "idName", ascending: true)
            tableView.addTableColumn(idNameColumn)

            let balanceColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("currentBalance"))
            balanceColumn.title = "Balance"
            balanceColumn.width = 80
            balanceColumn.minWidth = 60
            balanceColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "currentBalance", ascending: true)
            tableView.addTableColumn(balanceColumn)

            tableView.delegate = context.coordinator
            tableView.dataSource = context.coordinator

            // Double-click action
            tableView.doubleAction = #selector(Coordinator.handleDoubleClick(_:))
            tableView.target = context.coordinator

            // Set initial sort indicator
            if let column = tableView.tableColumn(
                withIdentifier: NSUserInterfaceItemIdentifier(sortDescriptor.key.rawValue))
            {
                tableView.sortDescriptors = [
                    NSSortDescriptor(
                        key: sortDescriptor.key.rawValue, ascending: sortDescriptor.ascending)
                ]
                tableView.highlightedTableColumn = column
            }

            scrollView.documentView = tableView

            context.coordinator.tableView = tableView

            return scrollView
        }

        func updateNSView(_ scrollView: NSScrollView, context: Context) {
            context.coordinator.attendees = attendees
            context.coordinator.convention = convention
            context.coordinator.onDoubleClick = onDoubleClick
            context.coordinator.onContextMenu = onContextMenu
            context.coordinator.parent = self

            guard let tableView = scrollView.documentView as? NSTableView else { return }

            // Update sort indicator if changed
            if let currentSort = tableView.sortDescriptors.first,
                currentSort.key != sortDescriptor.key.rawValue
                    || currentSort.ascending != sortDescriptor.ascending
            {
                tableView.sortDescriptors = [
                    NSSortDescriptor(
                        key: sortDescriptor.key.rawValue, ascending: sortDescriptor.ascending)
                ]
                if let column = tableView.tableColumn(
                    withIdentifier: NSUserInterfaceItemIdentifier(sortDescriptor.key.rawValue))
                {
                    tableView.highlightedTableColumn = column
                }
            }

            tableView.reloadData()

            // Update selection
            if let selectedId = selectedAttendeeId,
                let index = attendees.firstIndex(where: { $0.id == selectedId })
            {
                tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            } else {
                tableView.deselectAll(nil)
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(
                attendees: attendees,
                convention: convention,
                onDoubleClick: onDoubleClick,
                onContextMenu: onContextMenu,
                parent: self
            )
        }

        class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
            var attendees: [Attendee]
            var convention: Convention
            var onDoubleClick: (Attendee) -> Void
            var onContextMenu: (Attendee) -> NSMenu?
            var parent: AttendeeTableMac
            weak var tableView: NSTableView?

            init(
                attendees: [Attendee],
                convention: Convention,
                onDoubleClick: @escaping (Attendee) -> Void,
                onContextMenu: @escaping (Attendee) -> NSMenu?,
                parent: AttendeeTableMac
            ) {
                self.attendees = attendees
                self.convention = convention
                self.onDoubleClick = onDoubleClick
                self.onContextMenu = onContextMenu
                self.parent = parent
            }

            private func membershipLevelName(for id: MembershipLevelIdentifier) -> String {
                convention.membershipLevels.first { $0.id == id }?.shortName ?? ""
            }

            func numberOfRows(in tableView: NSTableView) -> Int {
                attendees.count
            }

            func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int)
                -> NSView?
            {
                guard row < attendees.count else { return nil }
                let attendee = attendees[row]

                let identifier = tableColumn?.identifier ?? NSUserInterfaceItemIdentifier("cell")
                let cellView: NSTextField

                if let existingView = tableView.makeView(withIdentifier: identifier, owner: self)
                    as? NSTextField
                {
                    cellView = existingView
                } else {
                    cellView = NSTextField()
                    cellView.identifier = identifier
                    cellView.isEditable = false
                    cellView.isBordered = false
                    cellView.drawsBackground = false
                    cellView.lineBreakMode = .byTruncatingTail
                }

                switch tableColumn?.identifier.rawValue {
                case "badgeName":
                    cellView.stringValue = attendee.badgeName
                    cellView.textColor = .labelColor
                case "badgeNumber":
                    cellView.stringValue = String(attendee.badgeNumber)
                    cellView.textColor = .labelColor
                case "minor":
                    if attendee.minor {
                        cellView.stringValue = "Minor"
                        cellView.textColor = .systemRed
                        cellView.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                    } else {
                        cellView.stringValue = ""
                        cellView.textColor = .labelColor
                    }
                case "staff":
                    if attendee.staff {
                        cellView.stringValue = "Staff"
                        cellView.textColor = .systemGreen
                        cellView.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                    } else {
                        cellView.stringValue = ""
                        cellView.textColor = .labelColor
                    }
                case "dealer":
                    if attendee.dealer {
                        cellView.stringValue = "Dealer"
                        cellView.textColor = .systemBlue
                        cellView.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                    } else {
                        cellView.stringValue = ""
                        cellView.textColor = .labelColor
                    }
                case "shirtSize":
                    cellView.stringValue = attendee.shirtSize ?? ""
                    cellView.textColor = .labelColor
                case "membershipLevel":
                    cellView.stringValue = membershipLevelName(for: attendee.membershipLevel)
                    cellView.textColor = .labelColor
                case "idName":
                    cellView.stringValue = attendee.idName
                    cellView.textColor = .labelColor
                case "currentBalance":
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    cellView.stringValue =
                        formatter.string(from: NSNumber(value: attendee.currentBalance)) ?? ""
                    cellView.textColor = .labelColor
                default:
                    cellView.stringValue = ""
                    cellView.textColor = .labelColor
                }

                return cellView
            }

            func tableViewSelectionDidChange(_ notification: Notification) {
                guard let tableView = notification.object as? NSTableView else { return }
                let selectedRow = tableView.selectedRow
                if selectedRow >= 0, selectedRow < attendees.count {
                    parent.selectedAttendeeId = attendees[selectedRow].id
                } else {
                    parent.selectedAttendeeId = nil
                }
            }

            func tableView(
                _ tableView: NSTableView,
                sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]
            ) {
                guard let sortDescriptor = tableView.sortDescriptors.first,
                    let key = sortDescriptor.key,
                    let sortKey = AttendeeSortKey(rawValue: key)
                else { return }

                parent.sortDescriptor = AttendeeSortDescriptor(
                    key: sortKey,
                    ascending: sortDescriptor.ascending
                )
            }

            @objc func handleDoubleClick(_ sender: NSTableView) {
                let clickedRow = sender.clickedRow
                guard clickedRow >= 0, clickedRow < attendees.count else { return }
                let attendee = attendees[clickedRow]
                onDoubleClick(attendee)
            }
        }
    }
#endif
