//
//  HoldingsRepositoryImplTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
@testable import AshishDemo

final class HoldingsRepositoryImplTests: XCTestCase {
    
    private var mockAPIService: MockHoldingsAPIService!
    private var mockCoreDataService: MockHoldingsCoreDataService!
    private var repository: HoldingsRepositoryImpl!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockHoldingsAPIService()
        mockCoreDataService = MockHoldingsCoreDataService()
        repository = HoldingsRepositoryImpl(
            apiService: mockAPIService,
            coreDataService: mockCoreDataService
        )
    }
    
    override func tearDown() {
        repository = nil
        mockCoreDataService = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    // MARK: - API Success Tests
    
    func testFetchHoldingsAPISuccess() async throws {
        
        let expectedHoldings = try createMockHoldings()
        let responseDTO = createMockResponseDTO(holdings: expectedHoldings)
        mockAPIService.responseToReturn = responseDTO
        
        
        let result = try await repository.fetchHoldings()
        
        
        XCTAssertEqual(result.count, expectedHoldings.count)
        XCTAssertEqual(result.first?.symbol, expectedHoldings.first?.symbol)
        XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
        XCTAssertTrue(mockCoreDataService.saveHoldingsCalled)
        XCTAssertEqual(mockCoreDataService.savedHoldings?.count, expectedHoldings.count)
    }
    
    func testFetchHoldingsSavesToCoreData() async throws {
        
        let expectedHoldings = try createMockHoldings()
        let responseDTO = createMockResponseDTO(holdings: expectedHoldings)
        mockAPIService.responseToReturn = responseDTO
        
        
        _ = try await repository.fetchHoldings()
        
        
        XCTAssertTrue(mockCoreDataService.saveHoldingsCalled)
        XCTAssertEqual(mockCoreDataService.savedHoldings?.count, expectedHoldings.count)
    }
    
    // MARK: - API Failure with Cache Tests
    
    func testFetchHoldingsAPIFailureUsesCache() async throws {
        
        let cachedHoldings = try createMockHoldings()
        mockAPIService.errorToThrow = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        mockCoreDataService.holdingsToReturn = cachedHoldings
        
        
        let result = try await repository.fetchHoldings()
        
        
        XCTAssertEqual(result.count, cachedHoldings.count)
        XCTAssertEqual(result.first?.symbol, cachedHoldings.first?.symbol)
        XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
        XCTAssertTrue(mockCoreDataService.fetchHoldingsCalled)
        XCTAssertFalse(mockCoreDataService.saveHoldingsCalled)
    }
    
    func testFetchHoldingsAPIFailureWithEmptyCacheThrowsError() async {
        
        mockAPIService.errorToThrow = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        mockCoreDataService.holdingsToReturn = []
        
         & Then
        do {
            _ = try await repository.fetchHoldings()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
            XCTAssertTrue(mockCoreDataService.fetchHoldingsCalled)
        }
    }
    
    func testFetchHoldingsAPIFailureWithNilCacheThrowsError() async {
        
        mockAPIService.errorToThrow = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        mockCoreDataService.errorToThrow = NSError(domain: "CoreDataError", code: 1, userInfo: nil)
        
         & Then
        do {
            _ = try await repository.fetchHoldings()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
            XCTAssertTrue(mockCoreDataService.fetchHoldingsCalled)
        }
    }
    
    // MARK: - Mapping Error Tests
    
    func testFetchHoldingsMappingErrorFallsBackToCache() async throws {
        
        let cachedHoldings = try createMockHoldings()
        // Create invalid DTO that will cause mapping to fail
        let invalidDTO = HoldingsResponseDTO(
            data: HoldingsDataDTO(
                userHolding: [
                    UserHoldingDTO(
                        symbol: "INVALID",
                        quantity: -1, // Invalid quantity
                        ltp: 0.0, // Invalid price
                        avgPrice: 0.0,
                        close: 0.0
                    )
                ]
            )
        )
        mockAPIService.responseToReturn = invalidDTO
        mockCoreDataService.holdingsToReturn = cachedHoldings
        
        
        let result = try await repository.fetchHoldings()
        
        
        XCTAssertEqual(result.count, cachedHoldings.count)
        XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
        XCTAssertTrue(mockCoreDataService.fetchHoldingsCalled)
    }
            
    // MARK: - Core Data Save Failure Tests
    
    func testFetchHoldingsContinuesWhenSaveFails() async throws {
        
        let expectedHoldings = try createMockHoldings()
        let responseDTO = createMockResponseDTO(holdings: expectedHoldings)
        mockAPIService.responseToReturn = responseDTO
        mockCoreDataService.errorToThrow = NSError(domain: "CoreDataError", code: 1, userInfo: nil)
        
        
        let result = try await repository.fetchHoldings()
        
        
        // Should still return holdings even if save fails
        XCTAssertEqual(result.count, expectedHoldings.count)
        XCTAssertTrue(mockAPIService.fetchHoldingsCalled)
        XCTAssertTrue(mockCoreDataService.saveHoldingsCalled)
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
    
    private func createMockResponseDTO(holdings: [Holding]) -> HoldingsResponseDTO {
        let userHoldings = holdings.map { holding in
            UserHoldingDTO(
                symbol: holding.symbol,
                quantity: holding.quantity,
                ltp: holding.ltp,
                avgPrice: holding.avgPrice,
                close: holding.close
            )
        }
        return HoldingsResponseDTO(
            data: HoldingsDataDTO(userHolding: userHoldings)
        )
    }
}

// MARK: - Mock API Service

final class MockHoldingsAPIService: HoldingsAPIService {
    var responseToReturn: HoldingsResponseDTO?
    var errorToThrow: Error?
    var fetchHoldingsCalled = false
    var delay: TimeInterval = 0
    
    func fetchHoldings() async throws -> HoldingsResponseDTO {
        fetchHoldingsCalled = true
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let response = responseToReturn else {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        
        return response
    }
}

// MARK: - Mock Core Data Service

final class MockHoldingsCoreDataService: HoldingsCoreDataServiceProtocol {
    var holdingsToReturn: [Holding] = []
    var savedHoldings: [Holding]?
    var errorToThrow: Error?
    var fetchHoldingsCalled = false
    var saveHoldingsCalled = false
    
    func saveHoldings(_ holdings: [Holding]) async throws {
        saveHoldingsCalled = true
        savedHoldings = holdings
        
        if let error = errorToThrow {
            throw error
        }
    }
    
    func fetchHoldings() async throws -> [Holding] {
        fetchHoldingsCalled = true
        
        if let error = errorToThrow {
            throw error
        }
        
        return holdingsToReturn
    }
    
    func deleteAllHoldings() async throws {
        // Mock implementation
    }
}

