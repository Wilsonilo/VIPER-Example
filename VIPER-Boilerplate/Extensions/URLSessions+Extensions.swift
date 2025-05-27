//
//  URLSessions+Extensions.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 27/05/25.
//

import Foundation

/// Adopt our protocol instead of subclassing (deprecated from iOS 13)
extension URLSession:URLSessionProtocol {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> any URLSessionDataTaskProtocol {
        return dataTask(
            with: request,
            completionHandler: completionHandler
        ) as URLSessionDataTask
    }
    
    /// Standard configuration if we want to init a session with some config
    static func withStandardConfiguration() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
}
