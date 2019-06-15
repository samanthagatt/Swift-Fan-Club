//
//  Forum.swift
//  App
//
//  Created by Samantha Gatt on 6/14/19.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Forum: Content, SQLiteModel, Migration {
    
    var id: Int?
    var name: String
}
