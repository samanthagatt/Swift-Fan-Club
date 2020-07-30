//
//  File.swift
//  
//
//  Created by Samantha Gatt on 7/29/20.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Forum: Content, SQLiteModel, Migration {
    var id: Int?
    var name: String
}
