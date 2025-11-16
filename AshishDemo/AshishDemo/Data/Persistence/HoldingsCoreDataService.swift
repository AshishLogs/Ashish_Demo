//
//  HoldingsCoreDataService.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation
import CoreData

protocol HoldingsCoreDataServiceProtocol: AnyObject {
    func saveHoldings(_ holdings: [Holding]) async throws
    func fetchHoldings() async throws -> [Holding]
    func deleteAllHoldings() async throws
}

final class HoldingsCoreDataService: HoldingsCoreDataServiceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
    
    func saveHoldings(_ holdings: [Holding]) async throws {
        try await coreDataManager.performBackgroundTask { context in
            // Delete existing holdings
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HoldingEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            
            // Insert new holdings
            for holding in holdings {
                let entity = HoldingEntity(context: context)
                entity.id = holding.id
                entity.symbol = holding.symbol
                entity.quantity = Int32(holding.quantity)
                entity.ltp = holding.ltp
                entity.avgPrice = holding.avgPrice
                entity.close = holding.close
                entity.pnl = holding.pnl
                entity.lastUpdated = Date()
            }
        }
    }
    
    func fetchHoldings() async throws -> [Holding] {
        try await coreDataManager.performBackgroundTask { context in
            let fetchRequest = HoldingEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]
            
            let entities = try context.fetch(fetchRequest)
            return try entities.compactMap { entity in
                guard let symbol = entity.symbol,
                      let id = entity.id else {
                    return nil
                }
                return try Holding(
                    symbol: symbol,
                    quantity: Int(entity.quantity),
                    ltp: entity.ltp,
                    avgPrice: entity.avgPrice,
                    close: entity.close,
                    pnl: entity.pnl
                )
            }
        }
    }
    
    func deleteAllHoldings() async throws {
        try await coreDataManager.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HoldingEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
    }
}

