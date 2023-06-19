//
//  ExperimentStore.swift
//  MySudoku
//
//  Created by Tyler Higgs on 6/17/23.
//

import Foundation
import Combine

struct ExperimentData: Codable {
    var sequentialResult: String
    var parallelResult: String
    var numHoles: Int
    var numTrials: Int
}

@MainActor
final class ExperimentStore: ObservableObject {
    @Published var recentExperiment: ExperimentData? = nil
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
        .appendingPathComponent("Experiment.data")
    }
    
    init() {
        load()
    }
        
    func load() {
        do {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return
            }
            let e = try JSONDecoder().decode(ExperimentData.self, from: data)
            self.recentExperiment = e
        } catch {
            print("there was an error")
        }
        
    }
    
    func save() throws {
        let data = try JSONEncoder().encode(self.recentExperiment)
        let outfile = try Self.fileURL()
        try data.write(to: outfile)
    }
    
    
}

