//
//  HoldingsRepositoryImpl.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

final class HoldingsRepositoryImpl: HoldingsRepository {
    private let apiService: HoldingsAPIService
    private let coreDataService: HoldingsCoreDataServiceProtocol
    private var currentTask: Task<[Holding], Error>?
    
    init(
        apiService: HoldingsAPIService,
        coreDataService: HoldingsCoreDataServiceProtocol
    ) {
        self.apiService = apiService
        self.coreDataService = coreDataService
    }
    
    func fetchHoldings() async throws -> [Holding] {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else {
                throw CancellationError()
            }
            
            do {
                // Try to fetch from API first
                let response = try await self.apiService.fetchHoldings()
                let holdings = try HoldingsMapper.map(response.data.userHolding)
                
                // Save to Core Data for offline access
                try? await self.coreDataService.saveHoldings(holdings)
                
                return holdings
            } catch {
                // If API fails, try to fetch from Core Data
                if let cachedHoldings = try? await self.coreDataService.fetchHoldings(),
                   !cachedHoldings.isEmpty {
                    return cachedHoldings
                }
                // If no cached data, throw the original error
                throw error
            }
        }
        
        do {
            let result = try await currentTask?.value ?? []
            currentTask = nil
            return result
        } catch let cancellationError as CancellationError {
            currentTask = nil
            throw cancellationError
        }
    }
    
    func cancelFetch() async {
        currentTask?.cancel()
        currentTask = nil
    }
}

