//
//  BoardTests.swift
//  BoardTests
//
//  Created by Tyler Higgs on 5/30/23.
//

import XCTest
@testable import MySudoku

final class BoardTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlacementValidity() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.

        var fiveFirst = Board()
        fiveFirst.grid[0][0] = 5
        
        XCTAssert(fiveFirst.isSafe(i: 0, j: 1, n: 1))
        
        XCTAssertFalse(fiveFirst.isSafe(i: 0, j: 4, n: 5), "5 in same row, expected isSafe to be false but was true")
        XCTAssertFalse(fiveFirst.isSafe(i: 4, j: 0, n: 5), "5 in same col, expected isSafe to be false but was true")
        XCTAssertFalse(fiveFirst.isSafe(i: 2, j: 2, n: 5), "5 in same box, expected isSafe to be false but was true")
        
        XCTAssert(fiveFirst.isSafe(i: 0, j: 4, n: 4), "Expected isSafe to be true, but was false with same number in row")
        XCTAssert(fiveFirst.isSafe(i: 4, j: 0, n: 4), "Expected isSafe to be true, but was false with same number in col")
        XCTAssert(fiveFirst.isSafe(i: 2, j: 2, n: 4), "Expected isSafe to be true, but was false with same number in box")
        
    }
    
    func testSolutionCreateFromEmpty() throws {
        var solved = Board()
        solved.fillPuzzle()
        for i in 0..<9 {
            for j in 0..<9 {
                XCTAssert(solved.grid[i][j] != 0)
                solved.grid[i][j] = 0
                XCTAssert(solved.isSafe(i: i, j: j, n: solved.solution[i][j]))
                solved.grid[i][j] = solved.solution[i][j]
            }
        }
        print(solved.solution)
    }
    
    func testPokeHoles() async throws {
        var puzzle = Board()
        puzzle.fillPuzzle()
        let n = 52
        let res = await puzzle.pokeHolesD(n: n, parallel: true)
        XCTAssert(res, "Response should be truthy")
        XCTAssert(puzzle.solutionExists(exampleGrid: puzzle.grid))
        var count = 0
        for row in puzzle.grid {
            count += (row.filter {$0 == 0}).count
        }
        XCTAssert(count == n, "There should be 30 slots left to fill in the grid")

//        puzzle2.fillPuzzle()
//        puzzle2.pokeHoles(n: 45)
//        count = 0
//        for row in puzzle2.grid {
//            count += (row.filter {$0 == 0}).count
//        }
//        XCTAssert(count == 45, "There should be 30 slots left to fill in the grid")
    }

}
