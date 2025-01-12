//
//  NetworkError.swift
//  CardliftKit
//
//  Created by Ray Nirola on 12/01/25.
//

enum NetworkError: Error {
    case networkError(Error)
    case noData
    case decodingError(Error)
}
