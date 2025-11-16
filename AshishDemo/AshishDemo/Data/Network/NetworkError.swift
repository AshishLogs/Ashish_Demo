//
//  NetworkError.swift
//  AshishDemo
//
//  Created by Ashish Singh on 16/11/25.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL(String)
    case invalidResponse
    case decodingError(underlying: String)
    case networkError(underlying: String)
    case httpError(statusCode: Int, data: Data?)
    case cancelled
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let underlying):
            return "Failed to decode response: \(underlying)"
        case .networkError(let underlying):
            return "Network error: \(underlying)"
        case .httpError(let code, _):
            return "HTTP error: \(code)"
        case .cancelled:
            return "Request cancelled"
        case .timeout:
            return "Request timeout"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError, .timeout:
            return "Please check your internet connection and try again."
        case .httpError(let code, _):
            return code == 401 ? "Please sign in again." : "Please try again later."
        default:
            return "Please try again."
        }
    }
}

