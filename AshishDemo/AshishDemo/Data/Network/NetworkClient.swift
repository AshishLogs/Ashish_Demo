//
//  NetworkClient.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

protocol NetworkClient: AnyObject {
    func request<T: Decodable>(
        endpoint: String,
        timeout: TimeInterval
    ) async throws -> T
    func cancelAllRequests() async
}

final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private var activeTasks: [URLSessionDataTask] = []
    private let taskQueue = DispatchQueue(label: "com.holdings.network.tasks")
    
    init(
        session: URLSession = .shared,
        baseURL: String = AppConstants.API.baseURL,
        decoder: JSONDecoder = JSONDecoder()
    ) throws {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL(baseURL)
        }
        self.baseURL = url
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable>(
        endpoint: String,
        timeout: TimeInterval = 30.0
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                throw NetworkError.decodingError(underlying: decodingError.localizedDescription)
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            if error.code == .cancelled {
                throw NetworkError.cancelled
            } else if error.code == .timedOut {
                throw NetworkError.timeout
            } else {
                throw NetworkError.networkError(underlying: error.localizedDescription)
            }
        } catch {
            throw NetworkError.networkError(underlying: error.localizedDescription)
        }
    }
    
    func cancelAllRequests() async {
        taskQueue.sync {
            activeTasks.forEach { $0.cancel() }
            activeTasks.removeAll()
        }
    }
}

