//
//  Move.swift
//  MySudoku
//
//  Created by Tyler Higgs on 6/14/23.
//

import Foundation

struct Move: Codable {
    var row: Int
    var col: Int
    var isNote: Bool
    var num: Int
    
    init(row i: Int, col j: Int, num n: Int, isNote note: Bool = false) {
        self.row = i
        self.col = j
        self.isNote = note
        self.num = n
    }
}

struct Stack<T> {
    private var items: Array<T> = []
    
    mutating func push(_ item: T) {
        self.items.append(item)
    }
    
    @discardableResult
    mutating func pop() -> T? {
        if items.isEmpty { return nil }
        return self.items.popLast()
    }
    
    func peek() -> T? {
        return items.last
    }
}
