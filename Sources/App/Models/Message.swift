//
//  Message.swift
//  
//
//  Created by Samantha Gatt on 7/30/20.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Message: Content, SQLiteModel, Migration {
    var id: Int?
    var forum: Int
    var title: String
    var body: String
    var parent: Int
    var user: String
    var date: Date
}
