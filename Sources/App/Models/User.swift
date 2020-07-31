//
//  User.swift
//  
//
//  Created by Samantha Gatt on 7/31/20.
//

import Foundation
import Vapor
import FluentSQLite
import Fluent

struct User: Content, SQLiteModel, Migration {
    var id: Int?
    var username: String
    var password: String
}
