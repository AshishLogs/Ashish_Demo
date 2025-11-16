//
//  HoldingsRepository.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

protocol HoldingsRepository: AnyObject {
    func fetchHoldings() async throws -> [Holding]
    func cancelFetch() async
}

