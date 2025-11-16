//
//  DependencyContainer.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation
import CoreData
import UIKit

protocol DependencyContainerProtocol {
    @MainActor func makeHoldingsViewController() -> HoldingsViewController
}

final class DependencyContainer: DependencyContainerProtocol {
    private let networkClient: NetworkClient
    private let currencyFormatter: CurrencyFormatterProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    init(
        networkClient: NetworkClient? = nil,
        currencyFormatter: CurrencyFormatterProtocol? = nil,
        coreDataManager: CoreDataManagerProtocol? = nil
    ) {
        if let networkClient = networkClient {
            self.networkClient = networkClient
        } else {
            do {
                self.networkClient = try URLSessionNetworkClient()
            } catch {
                fatalError("Failed to create network client: \(error)")
            }
        }
        self.currencyFormatter = currencyFormatter ?? CurrencyFormatter()
        
        if let coreDataManager = coreDataManager {
            self.coreDataManager = coreDataManager
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("AppDelegate not found")
            }
            self.coreDataManager = CoreDataManager(persistentContainer: appDelegate.persistentContainer)
        }
    }
    
    @MainActor func makeHoldingsViewController() -> HoldingsViewController {
        let apiService = HoldingsAPI(networkClient: networkClient)
        let coreDataService = HoldingsCoreDataService(coreDataManager: coreDataManager)
        let repository = HoldingsRepositoryImpl(apiService: apiService, coreDataService: coreDataService)
        let useCase = FetchHoldingsUseCase(repository: repository)
        let viewModel = HoldingsViewModel(fetchHoldingsUseCase: useCase)
        return HoldingsViewController(viewModel: viewModel)
    }
}

extension DependencyContainer {
    static let shared = DependencyContainer()
}

