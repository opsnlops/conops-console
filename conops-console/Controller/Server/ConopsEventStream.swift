import Foundation
import OSLog

@MainActor
final class ConopsEventStream {
    private let logger = Logger(
        subsystem: "furry.enterprises.CreatureConsole", category: "EventStream")
    private var task: Task<Void, Never>?
    private let reconnectDelay: UInt64 = 3_000_000_000
    private var currentEventName: String?

    var onEvent: ((String) -> Void)?

    func start() {
        stop()
        let url = ConopsServerClient().makeURL(for: "events")
        logger.info("Starting SSE request to \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.timeoutInterval = .infinity
        if let token = AuthStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            logger.warning("Starting SSE without an auth token")
        }

        task = Task { [weak self] in
            guard let self else { return }
            let session = self.makeStreamingSession()

            while !Task.isCancelled {
                do {
                    let (bytes, response) = try await session.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self.logger.error("SSE response was not HTTP")
                        break
                    }

                    let contentType =
                        httpResponse.value(forHTTPHeaderField: "Content-Type") ?? "<missing>"
                    self.logger.info(
                        "SSE response status \(httpResponse.statusCode), content-type \(contentType, privacy: .public)"
                    )

                    guard (200...299).contains(httpResponse.statusCode) else {
                        let errorBody = await self.readErrorBody(from: bytes)
                        self.logger.error(
                            "SSE connection failed (status \(httpResponse.statusCode)): \(errorBody, privacy: .public)"
                        )
                        await self.sleepBeforeReconnect()
                        continue
                    }

                    self.logger.info("SSE connected to \(url.absoluteString)")
                    for try await line in bytes.lines {
                        guard !Task.isCancelled else { break }
                        let sample = line.prefix(200)
                        self.logger.info("SSE line received: \(sample, privacy: .public)")
                        self.handleLine(line)
                    }

                    self.logger.info("SSE stream ended")
                } catch {
                    guard !Task.isCancelled else { return }
                    self.logger.error(
                        "SSE disconnected: \(error.localizedDescription, privacy: .public)")
                    await self.sleepBeforeReconnect()
                }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    private func handleLine(_ line: String) {
        if line.isEmpty {
            currentEventName = nil
            return
        }
        if line.hasPrefix(":") {
            logger.info("SSE ping received")
            return
        }
        if line.hasPrefix("event:") {
            currentEventName = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(
                in: .whitespaces)
            return
        }
        guard line.hasPrefix("data:") else { return }
        let payload = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(
            in: .whitespaces)
        if currentEventName == "ping" {
            logger.info("SSE ping received")
            return
        }
        if !payload.isEmpty {
            let sample = payload.prefix(200)
            logger.info("SSE event payload received: \(sample, privacy: .public)")
            Task { @MainActor in
                self.onEvent?(payload)
            }
        }
    }

    private func makeStreamingSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = .infinity
        configuration.timeoutIntervalForResource = .infinity
        return URLSession(configuration: configuration)
    }

    private func readErrorBody(from bytes: URLSession.AsyncBytes) async -> String {
        do {
            var lines: [String] = []
            for try await line in bytes.lines {
                lines.append(line)
                if lines.joined().count > 2048 {
                    break
                }
            }
            return lines.joined(separator: "\n")
        } catch {
            return "<failed to read error body>"
        }
    }

    private func sleepBeforeReconnect() async {
        do {
            try await Task.sleep(nanoseconds: reconnectDelay)
        } catch {
            return
        }
    }
}
