//
//  Board.swift
//  MySudoku
//
//  Created by Tyler Higgs on 5/25/23.
//

import Foundation

extension Array {
    func parallelForEach(_ body: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) { i in
            body(self[i])
        }
    }
}

struct Board: Codable {
    var grid: Array<Array<Int>>
    var candidates: Array<Array<String>>
    var fills: Array<Array<Int>>
    var solution: Array<Array<Int>>
    
    init() {
        self.grid = [Array](repeating: [Int](repeating: 0, count: 9), count: 9)
        self.candidates = [Array](repeating: [String](repeating: "", count: 9), count: 9)
        self.fills = [Array](repeating: [Int](repeating: 0, count: 9), count: 9)
        self.solution = [Array](repeating: [Int](repeating: 0, count: 9), count: 9)
    }
    
    mutating func buildPuzzle(n: Int = 30) {
        self.fillPuzzle()
        let _ = self.pokeHolesD(n: n)
    }
    
    func rowSafe(i: Int, n: Int) -> Bool {
        return !self.grid[i].contains(n) && !self.fills[i].contains(n)
    }
    
    func colSafe(j: Int, n: Int) -> Bool {
        return !(self.grid.map { $0[j] }).contains(n) && !(self.fills.map { $0[j] }).contains(n)
    }
    
    func boxSafe(i: Int, j: Int, n: Int) -> Bool {
        let startI = i - i % 3
        let startJ = j - j % 3
        for row in startI..<(startI + 3) {
            for col in startJ..<(startJ + 3) {
                if self.grid[row][col] == n || self.fills[row][col] == n {
                    return false
                }
            }
        }
        return true
    }
    
    func isSafe(i: Int, j: Int, n: Int) -> Bool {
        return rowSafe(i: i, n: n) && colSafe(j: j, n: n) && boxSafe(i: i, j: j, n: n)
    }
    
    private func rowSafe(mat: Array<Array<Int>>, i: Int, n: Int) -> Bool {
        return !mat[i].contains(n)
    }
    
    private func colSafe(mat: Array<Array<Int>>, j: Int, n: Int) -> Bool {
        return !(mat.map { $0[j] }).contains(n)
    }
    
    private func boxSafe(mat: Array<Array<Int>>, i: Int, j: Int, n: Int) -> Bool {
        let startI = i - i % 3
        let startJ = j - j % 3
        for row in startI..<(startI + 3) {
            for col in startJ..<(startJ + 3) {
                if mat[row][col] == n {
                    return false
                }
            }
        }
        return true
    }
    
    private func isSafe(mat: Array<Array<Int>>, i: Int, j: Int, n: Int) -> Bool {
        return rowSafe(mat: mat, i: i, n: n) && colSafe(mat: mat, j: j, n: n) && boxSafe(mat: mat, i: i, j: j, n: n)
    }
    
    
    static func copyMatrix(mat: Array<Array<Int>>) -> Array<Array<Int>> {
        return mat.map {$0.map {$0}}
    }
    
    /**
     Helper function for the `fillPuzzle` function will populate rows below `i` and `j` and across for row `i` in `self.solution`
     
     - Parameters:
        - i: Row of next box to try to fill
        - j: Column of next box to try to fill
        - t: number of seconds between 1970 and the start of the puzzle filling (if current time - t gets too large, we might need to abandon the attempt)
     */
    mutating func fillAt(i: Int = 0, j: Int = 0, t: TimeInterval) -> Bool {
        if NSDate().timeIntervalSince1970 - t > 1 {
            return false
        }
        if i >= 9 {
            return true
        }
        let nextJ = (j + 1) % 9 // col
        let nextI = nextJ != 0 ? i : i + 1 // row
        let options = Array(1...9).shuffled()
        for option in options {
            if isSafe(i: i, j: j, n: option) {
                self.solution[i][j] = option
                self.grid[i][j] = option
                if fillAt(i: nextI, j: nextJ, t: t) {
                    return true
                } else {
                    self.solution[i][j] = 0
                    self.grid[i][j] = 0
                }
            }
        }
        return false
    }
    
    
    mutating func fillPuzzle() {
        let timestamp = NSDate().timeIntervalSince1970
        var complete = false
        while !complete {
            complete = fillAt(t: timestamp)
        }
        self.grid = Board.copyMatrix(mat: self.solution) // TODO: delete
    }
    
    func solutionExistsAt( gridCopy: inout Array<Array<Int>>, i: Int = 0, j: Int = 0, t: TimeInterval) -> Bool {
        if NSDate().timeIntervalSince1970 - t > 1 {
            return false
        }
        if i >= 9 {
            return true
        }
        let nextJ = (j + 1) % 9 // col
        let nextI = nextJ != 0 ? i : i + 1 // row
        if gridCopy[i][j] != 0 {
            return solutionExistsAt(gridCopy: &gridCopy, i: nextI, j: nextJ, t: t)
        }
        let options = Array(1...9).shuffled()
        for option in options {
            if isSafe(mat: gridCopy, i: i, j: j, n: option) {
                gridCopy[i][j] = option
                if solutionExistsAt(gridCopy: &gridCopy, i: nextI, j: nextJ, t: t) {
                    return true
                } else {
                    gridCopy[i][j] = 0
                }
            }
        }
        return false
    }
    
    func solutionExists(exampleGrid: Array<Array<Int>>) -> Bool {
        let timestamp = NSDate().timeIntervalSince1970
        var gridCopy = Board.copyMatrix(mat: exampleGrid)
        var complete = false
        complete = solutionExistsAt(gridCopy: &gridCopy, t: timestamp)
        return complete
    }
    
    func multiplePossibleSolutions() -> Bool {
        var gridCopy = Board.copyMatrix(mat: self.grid)
        for i in 0..<9 {
            for j in 0..<9 {
                if gridCopy[i][j] == 0 {
                    for k in 1...9 {
                        if self.solution[i][j] == k || !self.isSafe(i: i, j: j, n: k){
                            continue
                        }
                        gridCopy[i][j] = k
                        if solutionExists(exampleGrid: gridCopy) {
                            return true
                        }
                        gridCopy[i][j] = 0
                    }
                }
            }
        }
        return false
    }
    
    /**
     For use in parallelized `multiplePossibleSolutionsP` where the grid we are checking is self.grid
     plus a `value` at row `i` and col `j`
     */
    func solutionExistsP(i: Int, j: Int, value: Int) -> Bool {
        let timestamp = NSDate().timeIntervalSince1970
        var gridCopy = Board.copyMatrix(mat: self.grid)
        gridCopy[i][j] = value
        var complete = false
        complete = solutionExistsAt(gridCopy: &gridCopy, t: timestamp)
        return complete
    }

    /**
     Parallelized
     */
    func multiplePossibleSolutionsP() -> Bool {
        var ret = false
        Array(0..<81).parallelForEach { i in
            let col = i % 9
            let row = (i - col) / 9
            for k in 0..<9 {
                if self.solution[row][col] == k || !self.isSafe(i: row, j: col, n: k){
                    continue
                }
                if solutionExistsP(i: row, j: col, value: k) {
                    ret = true
                }
            }
        }
        return ret
    }
    
    /**
     Needs to poke `n` more holes in `self.grid` recursively and should always complete
     in a reasonable amount of time. Return `true` if hole poking was recursively successful.
     */
    mutating func pokeHolesD(n: Int, parallel: Bool = false) -> Bool {
        print("pokeHolesD(n: \(n))")
        if n == 0 {
            return true
        }
        let options = Array(0..<81).shuffled()
        for option in options {
            let randRow = Int(option / 9)
            let randCol = option % 9
            if self.grid[randRow][randCol] == 0 {
                // hole already poked here
                continue
            }
            // try to poke hole
            self.grid[randRow][randCol] = 0
            // let noSolutionExists = !solutionExists(exampleGrid: self.grid) not need???
            let severalPossibleSolutions = parallel ? multiplePossibleSolutionsP() : multiplePossibleSolutions()
            if severalPossibleSolutions {
                // we have created an invalid board reset
                print("found multiple possible solutions")
                self.grid[randRow][randCol] = self.solution[randRow][randCol]
                continue
            }
            if pokeHolesD(n: n - 1) {
                return true
            }
            self.grid[randRow][randCol] = self.solution[randRow][randCol]
        }
        return false
    }
    
    mutating func pokeHoles(n: Int) {
        var removed = Set<Int>()
        var removedStack: Array<Int> = []
        let stuckThreshold = 60
        var stuckCount = 0
        while removed.count < n {
            let rand = Int.random(in: 0..<81)
            print("Attempting to remove \(removed.count)")
            let randRow = Int(rand / 9)
            let randCol = rand % 9
            if removed.contains(rand) {
                continue
            }
            
            self.grid[randRow][randCol] = 0
            let severalPossibleSolutions = multiplePossibleSolutions()
            if severalPossibleSolutions {
                self.grid[randRow][randCol] = self.solution[randRow][randCol]
                stuckCount += 1
                if stuckCount > stuckThreshold {
                    stuckCount = 0
                    // go back, I think we are stuck
                    let randomRemove = Int.random(in: 0..<removedStack.count)
                    let undo = removedStack[randomRemove]
                    removedStack.remove(at: randomRemove)
                    let uRow = Int(undo / 9)
                    let uCol = undo % 9
                    self.grid[uRow][uCol] = self.solution[uRow][uCol]
                    removed.remove(undo)
                }
                continue
            }
            removed.insert(rand)
            removedStack.append(rand)
        }
    }
    
}
