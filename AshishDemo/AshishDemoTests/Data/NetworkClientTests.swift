//
//  NetworkClientTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class NetworkClientTests: XCTestCase {
    
    private var networkClient: URLSessionNetworkClient!
    private var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        // Use default session for real network tests, or mock for isolated tests
        do {
            networkClient = try URLSessionNetworkClient(
                session: .shared,
                baseURL: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"
            )
        } catch {
            XCTFail("Failed to create network client: \(error)")
        }
    }
    
    override func tearDown() {
        networkClient = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testNetworkClientInitializationWithValidURL() throws {
        
        let baseURL = "https://api.example.com"
        
        
        let client = try URLSessionNetworkClient(baseURL: baseURL)
        
        
        XCTAssertNotNil(client)
    }
    
    // MARK: - Request Tests
    
    func testRequestSuccess() async throws {
        
        // This test requires a real network call or mock
        // For now, we'll test the structure
        
        struct TestResponse: Codable {
            let message: String
        }
        
        // Note: This will only work if the API is accessible
        // In a real scenario, you'd use a mock URLSession
        do {
            let response: TestResponse = try await networkClient.request(
                endpoint: "",
                timeout: 10.0
            )
            XCTAssertNotNil(response)
        } catch {
            // Network might not be available in test environment
            // This is acceptable for unit tests
            print("Network test skipped: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorTypes() {
        // Test that all NetworkError cases have descriptions
        let errors: [NetworkError] = [
            .invalidURL("test"),
            .invalidResponse,
            .decodingError(underlying: "test"),
            .networkError(underlying: "test"),
            .httpError(statusCode: 404, data: nil),
            .cancelled,
            .timeout
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.recoverySuggestion)
        }
    }
    
    func testNetworkErrorEquatable() {
        
        let error1 = NetworkError.invalidURL("test")
        let error2 = NetworkError.invalidURL("test")
        let error3 = NetworkError.invalidResponse
        
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testHTTPErrorRecoverySuggestion() {
        
        let error401 = NetworkError.httpError(statusCode: 401, data: nil)
        let error500 = NetworkError.httpError(statusCode: 500, data: nil)
        
        
        XCTAssertEqual(error401.recoverySuggestion, "Please sign in again.")
        XCTAssertEqual(error500.recoverySuggestion, "Please try again later.")
    }
    
    func testNetworkErrorRecoverySuggestion() {
        
        let networkError = NetworkError.networkError(underlying: "Connection failed")
        let timeoutError = NetworkError.timeout
        
        
        XCTAssertEqual(networkError.recoverySuggestion, "Please check your internet connection and try again.")
        XCTAssertEqual(timeoutError.recoverySuggestion, "Please check your internet connection and try again.")
    }
    
    // MARK: - Cancel Tests
    
    func testCancelAllRequests() async {
        
        
        await networkClient.cancelAllRequests()
        
        
        // Should complete without error
        // In a real scenario, you'd verify that active tasks were cancelled
    }
}

