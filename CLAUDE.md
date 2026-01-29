# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Conops Console is a SwiftUI client for the Conops convention management API. It runs on macOS and iOS, providing attendee registration, convention configuration, and real-time sync with a backend server.

**Operational Context**: This application is used in high-pressure situations—staff registering attendees with a long line of people waiting. The app must never crash. Stability and reliability are paramount. When making changes, prefer boring-but-safe over flashy-but-cool.

## Build and Run

This is an Xcode project (no Swift Package Manager). Open `Conops Console.xcodeproj` in Xcode.

- **Build**: Cmd+B or `xcodebuild -project "Conops Console.xcodeproj" -scheme "Conops Console"`
- **Run**: Cmd+R in Xcode
- **Test**: Cmd+U or `xcodebuild test -project "Conops Console.xcodeproj" -scheme "Conops Console"`

## Code Formatting

Format with swift-format using the project's `swift-format.json` configuration:
```bash
swift-format format --configuration swift-format.json -i <file>
```

Key style rules: 4-space indentation, 100 character line length, ordered imports, trailing commas in collections.

## Architecture

**MVVM with Repository Pattern**

```
Controller/           # Business logic, state management, API layer
├── AppState.swift    # Global @StateObject for app-wide state
├── SessionManager    # Auth lifecycle, logout
├── FullSync.swift    # Orchestrates data sync (full or incremental)
├── SyncCache.swift   # Local cache management
└── Server/           # API client layer
    ├── ConopsServerClient.swift    # HTTP client implementation
    ├── ConopsServerProtocol.swift  # Protocol interface for mocking
    ├── AuthStore.swift             # Keychain token storage
    ├── ConopsEventStream.swift     # SSE real-time updates
    ├── ConventionMethods.swift     # Convention API extension
    └── AttendeeMethods.swift       # Attendee API extension

Model/                # Data models
├── Convention.swift  # @Model for SwiftData persistence
├── Attendee.swift    # @Model for SwiftData persistence
├── DTO/              # Plain Codable structs for API serialization
└── Types.swift       # Type aliases and enums

View/                 # SwiftUI views organized by feature
├── TopContentView.swift  # Main navigation root
├── Attendee/         # Attendee list, forms, editing
├── Convention/       # Convention management views
├── Auth/             # Login UI
├── Dashboard/        # Analytics with Charts framework
└── Settings/         # App settings
```

## Key Patterns

**DTO Mapping**: Local `@Model` classes (Convention, Attendee) have corresponding DTOs for API serialization. Convert with `Model.fromDTO()` and instance `.toDTO()` methods.

**Server Client Extensions**: API methods are organized by domain in separate files that extend `ConopsServerClient`:
- `ConventionMethods.swift` - convention CRUD
- `AttendeeMethods.swift` - attendee CRUD

**Type Aliases**: Use `ConventionIdentifier`, `AttendeeIdentifier`, `MembershipLevelIdentifier` (all `Int`) for clarity.

**SwiftData Models**: Convention and Attendee use `@Model` macro with `@Relationship(deleteRule: .cascade)` for parent-child relationships.

## Server Communication

- API client uses generic `fetchData<T>()` and `sendData<T, R>()` methods
- Auth tokens stored in Keychain via `AuthStore.shared`
- Server-Sent Events (SSE) on `/api/v1/events` for real-time updates; server sends ping every 15 seconds
- Sync supports incremental (since `lastSyncTime`) and full refresh modes

## Platform Conditionals

The app uses `#if os(macOS)` and `#if os(iOS)` for platform-specific UI (e.g., macOS Settings window, different table implementations).
