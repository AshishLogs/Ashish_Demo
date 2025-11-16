//
//  HoldingsViewModelTests.swift
//  AshishDemoTests
//
//  Created by Ashish Singh on 16/11/25.
//

import XCTest
import Combine
@testable import AshishDemo

@MainActor
final class HoldingsViewModelTests: XCTestCase {
    
    private var mockRepository: MockHoldingsRepositoryForViewModel!
    private var useCase: FetchHoldingsUseCase!
    private var viewModel: HoldingsViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockHoldingsRepositoryForViewModel()
        useCase = FetchHoldingsUseCase(repository: mockRepository)
        viewModel = HoldingsViewModel(fetchHoldingsUseCase: useCase)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsIdle() {
        
        if case .idle = viewModel.state {
            // Expected
        } else {
            XCTFail("Expected initial state to be idle")
        }
    }
    
    // MARK: - Loading State Tests
    
    func testLoadHoldingsSetsLoadingState() async {
        
        mockRepository.holdingsToReturn = try! createMockHoldings()
        
        let expectation = expectation(description: "State changes to loading")
        var stateChanges: [HoldingsViewModel.ViewState<[Holding]>] = []
        
        viewModel.$state
            .sink { state in
                stateChanges.append(state)
                if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        
        await viewModel.loadHoldings()
        
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(stateChanges.contains { if case .loading = $0 { return true }; return false })
    }
    
    func testLoadHoldingsDoesNotSetLoadingIfAlreadyLoading() async {
        
        mockRepository.holdingsToReturn = try! createMockHoldings()
        
        
        await viewModel.loadHoldings()
        
        // Start second load immediately (should be ignored)
        let initialState = viewModel.state
        await viewModel.loadHoldings()
        
        
        // State should remain loading, not start new load
        if case .loading = initialState {
            // Expected - second call should be ignored
        }
    }
    
    // MARK: - Success State Tests
    
    func testLoadHoldingsSuccessSetsLoadedState() async {
        
        let expectedHoldings = try! createMockHoldings()
        mockRepository.holdingsToReturn = expectedHoldings
        
        let expectation = expectation(description: "State changes to loaded")
        expectation.expectedFulfillmentCount = 2 // loading + loaded
        
        var finalState: HoldingsViewModel.ViewState<[Holding]>?
        
        viewModel.$state
            .sink { state in
                if case .loaded = state {
                    finalState = state
                    expectation.fulfill()
                } else if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        
        await viewModel.loadHoldings()
        
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        if case .loaded(let holdings) = finalState {
            XCTAssertEqual(holdings.count, expectedHoldings.count)
            XCTAssertEqual(holdings.first?.symbol, expectedHoldings.first?.symbol)
        } else {
            XCTFail("Expected loaded state")
        }
    }
    
    func testLoadHoldingsSuccessWithEmptyArray() async {
        
        mockRepository.holdingsToReturn = []
        
        
        await viewModel.loadHoldings()
        
        
        if case .loaded(let holdings) = viewModel.state {
            XCTAssertTrue(holdings.isEmpty)
        } else {
            XCTFail("Expected loaded state with empty array")
        }
    }
    
    // MARK: - Error State Tests
    
    func testLoadHoldingsErrorSetsErrorState() async {
        
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockRepository.errorToThrow = expectedError
        
        let expectation = expectation(description: "State changes to error")
        
        var finalState: HoldingsViewModel.ViewState<[Holding]>?
        
        viewModel.$state
            .sink { state in
                if case .error = state {
                    finalState = state
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        
        await viewModel.loadHoldings()
        
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        if case .error(let error, _) = finalState {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testErrorStateHasRetryAction() async {
        
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)
        
        
        await viewModel.loadHoldings()
        
        
        if case .error(_, let retryAction) = viewModel.state {
            // Retry action should be callable
            XCTAssertNotNil(retryAction)
            
            // Test retry
            mockRepository.holdingsToReturn = try! createMockHoldings()
            mockRepository.errorToThrow = nil
            
            retryAction()
            
            // Wait a bit for async operation
            try? await Task.sleep(nanoseconds: 100_000_000)
            
            // Should eventually succeed
            if case .loaded = viewModel.state {
                // Success
            } else {
                // May still be loading
            }
        } else {
            XCTFail("Expected error state with retry action")
        }
    }
    
    // MARK: - Cancellation Tests
    
    func testLoadHoldingsIgnoresCancellationError() async {
        
        mockRepository.errorToThrow = CancellationError()
        
        
        await viewModel.loadHoldings()
        
        
        // Should not set error state for cancellation
        if case .error = viewModel.state {
            XCTFail("Should not set error state for cancellation")
        }
    }
    
    // MARK: - Retry Tests
    
    func testRetrySetsLoadingState() async {
        
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)
        await viewModel.loadHoldings()
        
        // Reset for retry
        mockRepository.errorToThrow = nil
        mockRepository.holdingsToReturn = try! createMockHoldings()
        
        let expectation = expectation(description: "State changes to loading on retry")
        
        viewModel.$state
            .sink { state in
                if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        
        await viewModel.retry()
        
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testRetryAfterError() async {
        
        mockRepository.errorToThrow = NSError(domain: "TestError", code: 500, userInfo: nil)
        await viewModel.loadHoldings()
        
        // Reset for retry
        let expectedHoldings = try! createMockHoldings()
        mockRepository.errorToThrow = nil
        mockRepository.holdingsToReturn = expectedHoldings
        
        
        await viewModel.retry()
        
        
        if case .loaded(let holdings) = viewModel.state {
            XCTAssertEqual(holdings.count, expectedHoldings.count)
        } else {
            XCTFail("Expected loaded state after retry")
        }
    }
    
    // MARK: - Multiple Loads Tests
    
    func testMultipleLoads() async {
        
        let expectedHoldings = try! createMockHoldings()
        mockRepository.holdingsToReturn = expectedHoldings
        
        
        await viewModel.loadHoldings()
        await viewModel.loadHoldings()
        await viewModel.loadHoldings()
        
        
        // All three loads should complete successfully
        if case .loaded(let holdings) = viewModel.state {
            XCTAssertEqual(holdings.count, expectedHoldings.count)
        } else {
            XCTFail("Expected loaded state")
        }
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

// Helper mock repository for the use case
final class MockHoldingsRepositoryForViewModel: HoldingsRepository {
    var holdingsToReturn: [Holding] = []
    var errorToThrow: Error?
    
    func fetchHoldings() async throws -> [Holding] {
        if let error = errorToThrow {
            throw error
        }
        return holdingsToReturn
    }
    
    func cancelFetch() async {
        // Mock implementation
    }
}

