//
//  ModelData.swift
//  MySudoku
//
//  Created by Tyler Higgs on 5/25/23.
//

import Foundation
import Combine

@MainActor
final class ModelData: ObservableObject {
    @Published var board: Board = Board()
    var timer = Timer()
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            Task {
                await MainActor.run {
                    self.board.progressTime += 1
                }
                if await self.board.progressTime % 10 == 0 {
                    do {
                        try await self.save()
                    } catch {
                        print("problem saving time")
                    }
                }
            }
        }
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
        .appendingPathComponent("BoardData.data")
    }
    
    init() {
        Task {
            await load()
        }
    }
        
    func load() async {
        let task = Task {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                var b = Board()
                await b.buildPuzzle()
                return b
            }
            let b = try JSONDecoder().decode(Board.self, from: data)
            return b
        }
        do {
            let b = try await task.value
            await MainActor.run {
                self.board = b
            }
            print("loaded board")
        } catch {
            print("there was an error")
            var b = Board()
            await b.buildPuzzle()
            self.board = b
        }
        
    }
    
    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(self.board)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
            print("just wrote data to the file")
        }
        _ = try await task.value
    }
    
    
}
