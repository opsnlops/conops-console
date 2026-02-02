//
//  ConopsServerClient.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2026 April's Creature Workshop. All rights reserved.
//

import Foundation
import OSLog

enum UrlType {
    case http
    case websocket
}

/// A client for our server!
///
/// When making changes, take care to ensure that everything is thread safe. There should be no shared context between anything.
final class ConopsServerClient: ConopsServerProtocol {

    let logger = Logger(
        subsystem: "furry.enterprises.ConopsConsole", category: "ConopsServerClient")

    // Generate the base URL based on the stored configuration
    func makeBaseURL(for type: UrlType) -> URL {
        let userDefaults = UserDefaults.standard
        let hostname = userDefaults.serverHostname
        let port = userDefaults.serverPort
        let useTLS = userDefaults.useTLS

        let scheme = type == .http ? (useTLS ? "https" : "http") : (useTLS ? "wss" : "ws")

        let connectionString = "\(scheme)://\(hostname):\(port)/api/v1"
        logger.debug("Using connection string: \(connectionString)")

        return URL(string: connectionString)!
    }

    func makeURL(for endpoint: String, queryItems: [URLQueryItem] = []) -> URL {
        // Use string concatenation instead of appendingPathComponent to avoid
        // unexpected behavior with path components
        let baseString = makeBaseURL(for: .http).absoluteString
        let separator = baseString.hasSuffix("/") ? "" : "/"
        let cleanEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        let fullURLString = baseString + separator + cleanEndpoint

        var components = URLComponents(string: fullURLString)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url ?? URL(string: fullURLString)!
    }

    // Fetch data from the server
    func fetchData<DTO: Decodable, Object>(
        _ endpoint: String,
        queryItems: [URLQueryItem] = [],
        dtoType: DTO.Type,
        returnType: Object.Type,
        transform: @escaping (DTO) -> Object
    ) async -> Result<Object, ServerError> {
        let url = makeURL(for: endpoint, queryItems: queryItems)


        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyAuthHeader(to: &request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            // Correctly passing dtoType and transform to handleResponse
            return handleResponse(
                data: data, response: response, dtoType: dtoType, transform: transform)
        } catch {
            return .failure(.serverError("Request error: \(error.localizedDescription)"))
        }
    }

    // Send data to the server
    func sendData<DTO: Decodable, Body: Encodable, Object>(
        _ endpoint: String,
        method: HTTPMethod,
        body: Body,
        dtoType: DTO.Type,
        returnType: Object.Type,
        transform: @escaping (DTO) -> Object
    ) async -> Result<Object, ServerError> {
        do {
            let url = makeURL(for: endpoint)

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let requestBody = try encoder.encode(body)

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody
            applyAuthHeader(to: &request)

            // Use performRequest with the correct parameters
            return await performRequest(
                request, dtoType: dtoType, returnType: returnType, transform: transform)
        } catch {
            return .failure(.serverError("Encoding error: \(error.localizedDescription)"))
        }
    }

    // Perform a network request
    private func performRequest<DTO: Decodable, Object>(
        _ request: URLRequest,
        dtoType: DTO.Type,
        returnType: Object.Type,
        transform: @escaping (DTO) -> Object
    ) async -> Result<Object, ServerError> {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return handleResponse(
                data: data, response: response, dtoType: dtoType, transform: transform)
        } catch {
            return .failure(.serverError("Request error: \(error.localizedDescription)"))
        }
    }

    // Handle the server response
    private func handleResponse<DTO: Decodable, Object>(
        data: Data,
        response: URLResponse,
        dtoType: DTO.Type,
        transform: (DTO) -> Object
    ) -> Result<Object, ServerError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Response is not of type HTTPURLResponse")
            return .failure(.serverError("Invalid response"))
        }

        let statusCode = httpResponse.statusCode
        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
        logger.debug("HTTP status code: \(statusCode), Content-Type: \(contentType)")

        // Check for non-success status codes before trying to parse JSON
        if statusCode < 200 || statusCode >= 300 {
            let bodyString = String(data: data, encoding: .utf8) ?? "(empty or binary)"
            logger.error(
                "HTTP error \(statusCode): \(bodyString.prefix(500), privacy: .public)")

            // Try to parse as API error response if it's JSON
            if contentType.contains("application/json"),
               let serverStatus = try? JSONDecoder().decode(
                ServerStatus<EmptyDTO>.self, from: data)
            {
                let message = serverStatus.message ?? "HTTP \(statusCode)"
                return .failure(.apiError(statusCode, message))
            }

            // Handle HTML error pages (WAF, proxy errors, etc.)
            if contentType.contains("text/html") {
                let friendlyMessage = extractHtmlErrorMessage(from: bodyString, statusCode: statusCode)
                return .failure(.apiError(statusCode, friendlyMessage))
            }

            return .failure(.apiError(statusCode, "HTTP \(statusCode): \(bodyString.prefix(200))"))
        }

        // Verify we're getting JSON before trying to parse
        if !contentType.contains("application/json") && !data.isEmpty {
            let bodyPreview = String(data: data, encoding: .utf8)?.prefix(200) ?? "(binary)"
            logger.warning("Unexpected Content-Type '\(contentType)': \(bodyPreview)")
        }

        let decoder = JSONDecoder()

        // Custom date-decoding strategy
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let iso8601StandardFormatter = ISO8601DateFormatter()
            iso8601StandardFormatter.formatOptions = [.withInternetDateTime]

            let iso8601FractionalFormatter = ISO8601DateFormatter()
            iso8601FractionalFormatter.formatOptions = [
                .withInternetDateTime, .withFractionalSeconds,
            ]

            // Date-only formatter for YYYY-MM-DD format (used by birthday, convention start/end dates)
            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
            dateOnlyFormatter.timeZone = TimeZone(identifier: "UTC")

            // Try fractional first, then standard ISO8601, then date-only
            if let date = iso8601FractionalFormatter.date(from: dateString)
                ?? iso8601StandardFormatter.date(from: dateString)
                ?? dateOnlyFormatter.date(from: dateString)
            {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string does not match expected ISO8601 formats."
            )
        }

        do {
            // Decode the server response
            let serverStatus = try decoder.decode(ServerStatus<DTO>.self, from: data)

            // Validate the server status
            guard serverStatus.status == "success" else {
                let errorMessage = serverStatus.message ?? "Unknown server error"
                logger.error("Server error response: \(errorMessage, privacy: .public)")
                if let bodyString = String(data: data, encoding: .utf8) {
                    logger.warning("Server error body: \(bodyString, privacy: .public)")
                }

                if serverStatus.detailed_status == "validation_error" {
                    if let validationStatus = try? decoder.decode(
                        ServerStatus<[ApiValidationError]>.self,
                        from: data
                    ),
                        let validationErrors = validationStatus.data,
                        validationErrors.isEmpty == false
                    {
                        let details =
                            validationErrors
                            .map { "\($0.field): \($0.message)" }
                            .joined(separator: "\n")
                        let message =
                            (validationStatus.message ?? errorMessage)
                            + "\n" + details
                        return .failure(.serverError(message))
                    }
                }

                return .failure(.serverError(errorMessage))
            }

            if serverStatus.data == nil, DTO.self == EmptyDTO.self {
                let object = transform(EmptyDTO() as! DTO)
                return .success(object)
            }

            // Ensure data exists
            guard let payload = serverStatus.data else {
                return .failure(.serverError("Missing data in response"))
            }

            // Transform the data
            let object = transform(payload)
            return .success(object)
        } catch let decodingError as DecodingError {
            // Provide detailed decoding error messages
            let errorMessage = decodeErrorMessage(from: decodingError)
            logger.error("Decoding error: \(errorMessage, privacy: .public)")
            if let bodyString = String(data: data, encoding: .utf8) {
                logger.warning("Decoding error body: \(bodyString, privacy: .public)")
            }
            return .failure(.serverError(errorMessage))
        } catch {
            // Catch-all for unexpected errors
            logger.error(
                "Unexpected decoding error: \(error.localizedDescription, privacy: .public)")
            if let bodyString = String(data: data, encoding: .utf8) {
                logger.warning("Unexpected error body: \(bodyString, privacy: .public)")
            }
            return .failure(.serverError("Unexpected error"))
        }
    }

    // Decode JSON decoding errors
    private func decodeErrorMessage(from decodingError: DecodingError) -> String {
        switch decodingError {
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type): \(context.debugDescription) - \(context.codingPath)"
        case .valueNotFound(let type, let context):
            return
                "Value not found for \(type): \(context.debugDescription) - \(context.codingPath)"
        case .keyNotFound(let key, let context):
            return
                "Key '\(key.stringValue)' not found: \(context.debugDescription) - \(context.codingPath)"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription) - \(context.codingPath)"
        @unknown default:
            return "Unknown decoding error"
        }
    }

    // Extract a user-friendly message from HTML error pages
    private func extractHtmlErrorMessage(from html: String, statusCode: Int) -> String {
        // Try to extract <title> content
        if let titleRange = html.range(of: "<title>"),
           let titleEndRange = html.range(of: "</title>", range: titleRange.upperBound..<html.endIndex) {
            let title = String(html[titleRange.upperBound..<titleEndRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !title.isEmpty && title.count < 100 {
                return "\(title) (HTTP \(statusCode))"
            }
        }

        // Fallback to generic messages based on status code
        switch statusCode {
        case 401: return "Authentication required"
        case 403: return "Access denied by server security"
        case 404: return "Resource not found"
        case 429: return "Too many requests - please wait"
        case 500: return "Server error"
        case 502: return "Bad gateway - server may be down"
        case 503: return "Service unavailable"
        case 504: return "Gateway timeout"
        default: return "Server returned error page (HTTP \(statusCode))"
        }
    }

    private func applyAuthHeader(to request: inout URLRequest) {
        guard let token = AuthStore.shared.token else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    func requestAuthToken(
        conventionShortName: String,
        username: String,
        password: String
    ) async -> Result<AuthTokenResponse, ServerError> {
        let payload = AuthTokenRequest(
            conventionShortName: conventionShortName,
            username: username,
            password: password
        )

        return await sendData(
            "auth/token",
            method: .post,
            body: payload,
            dtoType: AuthTokenResponse.self,
            returnType: AuthTokenResponse.self
        ) { $0 }
    }

    func getActiveConventionsPublic() async -> Result<[PublicConventionDTO], ServerError> {
        return await fetchData(
            "conventions/active",
            dtoType: [PublicConventionDTO].self,
            returnType: [PublicConventionDTO].self
        ) { $0 }
    }
}
