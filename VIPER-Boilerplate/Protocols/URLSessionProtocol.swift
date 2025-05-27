//
//  URLSessionProtocol.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 27/05/25.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(
        with request:URLRequest,
        completionHandler:@escaping (
            Data?,
            URLResponse?,
            Error?
        )-> Void
    )->URLSessionDataTaskProtocol
    
}
