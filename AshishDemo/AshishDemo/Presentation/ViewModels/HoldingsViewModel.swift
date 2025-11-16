//
//  HoldingsViewModel.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation
import Combine

@MainActor
final class HoldingsViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Holding]> = .idle
    
    private let fetchHoldingsUseCase: FetchHoldingsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    enum ViewState<T> {
        case idle
        case loading
        case loaded(T)
        case error(Error, retryAction: () -> Void)
    }
    
    init(fetchHoldingsUseCase: FetchHoldingsUseCase) {
        self.fetchHoldingsUseCase = fetchHoldingsUseCase
    }
    
    func loadHoldings() async {
        guard case .loading = state else {
            state = .loading
            await performLoad()
            return
        }
    }
    
    private func performLoad() async {
        do {
            let holdings = try await fetchHoldingsUseCase.execute()
            state = .loaded(holdings)
        } catch is CancellationError {
            return
        } catch {
            state = .error(error) { [weak self] in
                Task { @MainActor in
                    await self?.loadHoldings()
                }
            }
        }
    }
    
    func retry() async {
        state = .loading
        await performLoad()
    }
    
    func cancel() {
        fetchHoldingsUseCase.cancel()
    }
    
    deinit {
        fetchHoldingsUseCase.cancel()
    }
}

