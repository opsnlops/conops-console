//
//  ConopsServerClient.swift
//  conops-console
//
//  Created by April White on 1/4/25.
//  Copyright © 2025 April's Creature Workshop. All rights reserved.
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
class ConopsServerClient: ConopsServerProtocol {

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

    // Fetch data from the server
    func fetchData<DTO: Decodable, Object>(
        _ endpoint: String,
        dtoType: DTO.Type,
        returnType: Object.Type,
        transform: @escaping (DTO) -> Object
    ) async -> Result<Object, ServerError> {
        let url = makeBaseURL(for: .http).appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
            let url = makeBaseURL(for: .http).appendingPathComponent(endpoint)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let requestBody = try encoder.encode(body)

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody

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
        guard response is HTTPURLResponse else {
            logger.error("Response is not of type HTTPURLResponse")
            return .failure(.serverError("Invalid response"))
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

            // Try fractional first, fallback to standard ISO8601
            if let date = iso8601FractionalFormatter.date(from: dateString)
                ?? iso8601StandardFormatter.date(from: dateString)
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
                return .failure(.serverError(errorMessage))
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
            logger.error("Decoding error: \(errorMessage)")
            return .failure(.serverError(errorMessage))
        } catch {
            // Catch-all for unexpected errors
            logger.error("Unexpected decoding error: \(error.localizedDescription)")
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
}
