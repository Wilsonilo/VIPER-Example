//
//  UserEntity.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 23/05/25.
//

/// Model

protocol AnyUserEntity: Codable {
    var name:String { get }
}

struct UserEntity:AnyUserEntity {
    let name:String
}
