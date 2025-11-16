//
//  CurrencyFormatter.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

final class CurrencyFormatter: CurrencyFormatterProtocol {
    private let formatter: NumberFormatter
    
    init(locale: Locale = Locale(identifier: "en_IN")) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹ "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        self.formatter = formatter
    }
    
    func format(_ value: Double) -> String {
        guard value.isFinite else {
            return "₹ 0.00"
        }
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "₹ 0.00"
        if value < 0 {
            return formatted.replacingOccurrences(of: "₹ ", with: "-₹ ")
        }
        return formatted
    }
}

