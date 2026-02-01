//
//  AttendeeTableMac.swift
//  Conops Console
//
//  Created by April White on 1/31/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    enum AttendeeSortKey: String {
        case badgeName
        case badgeNumber
        case firstName
        case lastName
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
            case .firstName:
                result = lhs.firstName.localizedCaseInsensitiveCompare(rhs.firstName)
            case .lastName:
                result = lhs.lastName.localizedCaseInsensitiveCompare(rhs.lastName)
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
        let onDoubleClick: (Attendee) -> Void
        let onContextMenu: (Attendee) -> NSMenu?

        @Binding var selectedAttendeeId: AttendeeIdentifier?
        @Binding var sortDescriptor: AttendeeSortDescriptor

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

            let firstNameColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("firstName"))
            firstNameColumn.title = "First Name"
            firstNameColumn.width = 150
            firstNameColumn.minWidth = 100
            firstNameColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "firstName", ascending: true)
            tableView.addTableColumn(firstNameColumn)

            let lastNameColumn = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("lastName"))
            lastNameColumn.title = "Last Name"
            lastNameColumn.width = 150
            lastNameColumn.minWidth = 100
            lastNameColumn.sortDescriptorPrototype = NSSortDescriptor(
                key: "lastName", ascending: true)
            tableView.addTableColumn(lastNameColumn)

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
            context.coordinator.onDoubleClick = onDoubleClick
            context.coordinator.onContextMenu = onContextMenu
            context.coordinator.parent = self

            guard let tableView = scrollView.documentView as? NSTableView else { return }

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
                onDoubleClick: onDoubleClick,
                onContextMenu: onContextMenu,
                parent: self
            )
        }

        class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
            var attendees: [Attendee]
            var onDoubleClick: (Attendee) -> Void
            var onContextMenu: (Attendee) -> NSMenu?
            var parent: AttendeeTableMac
            weak var tableView: NSTableView?

            init(
                attendees: [Attendee],
                onDoubleClick: @escaping (Attendee) -> Void,
                onContextMenu: @escaping (Attendee) -> NSMenu?,
                parent: AttendeeTableMac
            ) {
                self.attendees = attendees
                self.onDoubleClick = onDoubleClick
                self.onContextMenu = onContextMenu
                self.parent = parent
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
                case "badgeNumber":
                    cellView.stringValue = String(attendee.badgeNumber)
                case "firstName":
                    cellView.stringValue = attendee.firstName
                case "lastName":
                    cellView.stringValue = attendee.lastName
                default:
                    cellView.stringValue = ""
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
