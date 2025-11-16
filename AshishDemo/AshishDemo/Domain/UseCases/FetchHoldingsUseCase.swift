//
//  FetchHoldingsUseCase.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

final class FetchHoldingsUseCase {
    private let repository: HoldingsRepository
    private var currentTask: Task<[Holding], Error>?
    
    init(repository: HoldingsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Holding] {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else {
                throw CancellationError()
            }
            return try await self.repository.fetchHoldings()
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
    
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}

