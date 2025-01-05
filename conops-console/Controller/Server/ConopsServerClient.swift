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

/**
 A client for our server!

 When making changes, take care to ensure that everything is thread safe. There should be no shared context between anything.
 */
class ConopsServerClient : ConopsServerProtocol {

    let logger = Logger(subsystem: "furry.enterprises.ConopsConsole", category: "ConopsServerClient")

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
    func fetchData<T: Decodable>(_ endpoint: String, returnType: T.Type) async -> Result<T, ServerError> {
        let url = makeBaseURL(for: .http).appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return await performRequest(request, returnType: returnType)
    }

    // Send data to the server
    func sendData<T: Decodable, U: Encodable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: U,
        returnType: T.Type
    ) async -> Result<T, ServerError> {
        do {
            let url = makeBaseURL(for: .http).appendingPathComponent(endpoint)
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(body)

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody

            return await performRequest(request, returnType: returnType)
        } catch {
            return .failure(.serverError("Encoding error: \(error.localizedDescription)"))
        }
    }

    // Perform a network request
    private func performRequest<T: Decodable>(
        _ request: URLRequest,
        returnType: T.Type
    ) async -> Result<T, ServerError> {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return handleResponse(data: data, response: response, returnType: returnType)
        } catch {
            return .failure(.serverError("Request error: \(error.localizedDescription)"))
        }
    }

    // Handle the server response
    private func handleResponse<T: Decodable>(
        data: Data,
        response: URLResponse,
        returnType: T.Type
    ) -> Result<T, ServerError> {
        guard response is HTTPURLResponse else {
            logger.error("Response is not of type HTTPURLResponse")
            return .failure(.serverError("Invalid response"))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let rawJSON = String(data: data, encoding: .utf8) {
            logger.debug("Raw JSON response: \(rawJSON)")
        }

        do {
            let serverStatus = try decoder.decode(ServerStatus<T>.self, from: data)
            logger.debug("Successfully decoded ServerStatus: \(String(describing: serverStatus))")

            switch serverStatus.status {
            case "success":
                if let result = serverStatus.data {
                    logger.debug("Decoding succeeded with data: \(String(describing: result))")
                    return .success(result)
                } else {
                    logger.warning("Success response but data is nil")
                    return .failure(.serverError("Expected data but received nil"))
                }

            case "error":
                logger.warning("Error response: \(serverStatus.message ?? "No message")")
                return .failure(.serverError(serverStatus.message ?? "Unknown error"))

            default:
                logger.warning("Unknown status: \(serverStatus.status)")
                return .failure(.serverError("Unknown status"))
            }
        }
        catch let decodingError as DecodingError {
            let errorMessage = decodeErrorMessage(from: decodingError)
            logger.error("Decoding error: \(errorMessage)")
            return .failure(.serverError(errorMessage))
        }
        catch {
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
            return "Value not found for \(type): \(context.debugDescription) - \(context.codingPath)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found: \(context.debugDescription) - \(context.codingPath)"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription) - \(context.codingPath)"
        @unknown default:
            return "Unknown decoding error"
        }
    }
}
