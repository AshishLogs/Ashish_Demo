//
//  HoldingsAPI.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

protocol HoldingsAPIService {
    func fetchHoldings() async throws -> HoldingsResponseDTO
}

final class HoldingsAPI: HoldingsAPIService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchHoldings() async throws -> HoldingsResponseDTO {
        try await networkClient.request(endpoint: "", timeout: 30.0)
    }
}

