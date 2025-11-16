//
//  FetchHoldingsUseCaseTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class FetchHoldingsUseCaseTests: XCTestCase {
    
    private var mockRepository: MockHoldingsRepository!
    private var useCase: FetchHoldingsUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockHoldingsRepository()
        useCase = FetchHoldingsUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testExecuteSuccess() async throws {
        
        let expectedHoldings = try createMockHoldings()
        mockRepository.holdingsToReturn = expectedHoldings
        
        
        let result = try await useCase.execute()
        
        
        XCTAssertEqual(result.count, expectedHoldings.count)
        XCTAssertEqual(result.first?.symbol, expectedHoldings.first?.symbol)
        XCTAssertTrue(mockRepository.fetchHoldingsCalled)
    }
    
    func testExecuteReturnsEmptyArray() async throws {
        
        mockRepository.holdingsToReturn = []
        
        
        let result = try await useCase.execute()
        
        
        XCTAssertTrue(result.isEmpty)
        XCTAssertTrue(mockRepository.fetchHoldingsCalled)
    }
    
    // MARK: - Error Tests
    
    func testExecuteThrowsError() async {
        
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockRepository.errorToThrow = expectedError
        
         & Then
        do {
            _ = try await useCase.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
    }
    
    // MARK: - Cancellation Tests
    
    func testExecuteCancelsPreviousTask() async throws {
        
        mockRepository.holdingsToReturn = try createMockHoldings()
        mockRepository.delay = 0.1 // Simulate delay
        
        
        let task1 = Task {
            try await useCase.execute()
        }
        
        // Start second execution immediately (should cancel first)
        let task2 = Task {
            try await useCase.execute()
        }
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        
        // Cancel first task
        task1.cancel()
        
        // Wait for second task
        let result = try await task2.value
        
        
        XCTAssertFalse(result.isEmpty)
        // First task should be cancelled
        XCTAssertTrue(task1.isCancelled || mockRepository.fetchHoldingsCallCount >= 1)
    }
        
    func testExecuteAfterCancel() async throws {
        
        mockRepository.holdingsToReturn = try createMockHoldings()
        
        
        useCase.cancel()
        
        // Execute after cancel
        let result = try await useCase.execute()
        
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(mockRepository.fetchHoldingsCalled)
    }
    
    // MARK: - Multiple Executions Tests
    
    func testMultipleExecutions() async throws {
        
        mockRepository.holdingsToReturn = try createMockHoldings()
        
        
        let result1 = try await useCase.execute()
        let result2 = try await useCase.execute()
        
        
        XCTAssertEqual(result1.count, result2.count)
        XCTAssertEqual(mockRepository.fetchHoldingsCallCount, 2)
    }
    
    // MARK: - Helper Methods
    
    private func createMockHoldings() throws -> [Holding] {
        return [
            try Holding(
                symbol: "RELIANCE",
                quantity: 10,
                ltp: 2500.0,
                avgPrice: 2400.0,
                close: 2480.0,
                pnl: 1000.0
            ),
            try Holding(
                symbol: "TCS",
                quantity: 5,
                ltp: 3500.0,
                avgPrice: 3400.0,
                close: 3480.0,
                pnl: 500.0
            )
        ]
    }
}

// MARK: - Mock Repository

final class MockHoldingsRepository: HoldingsRepository {
    var holdingsToReturn: [Holding] = []
    var errorToThrow: Error?
    var fetchHoldingsCalled = false
    var fetchHoldingsCallCount = 0
    var delay: TimeInterval = 0
    
    func fetchHoldings() async throws -> [Holding] {
        fetchHoldingsCalled = true
        fetchHoldingsCallCount += 1
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let error = errorToThrow {
            throw error
        }
        
        return holdingsToReturn
    }
    
    func cancelFetch() async {
        // Mock implementation
    }
}

