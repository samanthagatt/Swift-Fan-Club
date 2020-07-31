//
//  File.swift
//  
//
//  Created by Samantha Gatt on 7/31/20.
//

import Foundation

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Optional<Any>, defaultString: @autoclosure () -> String) {
        if let value = value {
            appendLiteral("\(value)")
        } else {
            appendLiteral(defaultString())
        }
    }
    mutating func appendInterpolation(_ starting: String, _ value: Optional<Any>) {
        if let value = value {
            appendLiteral("\(starting)\(value)")
        }
    }
}
