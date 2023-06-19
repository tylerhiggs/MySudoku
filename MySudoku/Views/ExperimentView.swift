//
//  ExperimentView.swift
//  MySudoku
//
//  Created by Tyler Higgs on 6/17/23.
//

import SwiftUI
import UIKit

struct ExperimentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var experimentStore: ExperimentStore
    @State var loading: Bool = false
    @State var numHoles: String = ""
    @State var numTrials: String = ""
    var body: some View {
        VStack {
            Text("Experiment")
                .font(.title)
            TextField("Holes to poke", text: $numHoles)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Trials for each", text: $numTrials)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding([.bottom, .horizontal])
            Button {
                if let numHolesInt = Int(numHoles), let numTrialsInt = Int(numTrials) {
                    Task.detached {
                        await runExperiment(numHoles: numHolesInt, trials: numTrialsInt)
                    }
                }
            } label: {
                if !loading {
                    Text("Run Experiment")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                        }
                } else {
                    ProgressView()
                }
                
            }
            Text(resultsTitle)
                .font(.title2)
                .padding()
            Text(prevParallelResults)
            Text(prevSequentialResults)
        }
        
    }
    
    private var resultsTitle: String {
        if let safeExperiment = experimentStore.recentExperiment {
            return "Most recent results with \(safeExperiment.numHoles) holes and \(safeExperiment.numTrials) trials:"
        } else {
            return ""
        }
    }
    
    private var prevParallelResults: String {
        if let safeExperiment = experimentStore.recentExperiment {
            return "Parallel Result: \(safeExperiment.parallelResult)"
        } else {
            return ""
        }
    }
    
    private var prevSequentialResults: String {
        if let safeExperiment = experimentStore.recentExperiment {
            return "Sequential Result: \(safeExperiment.sequentialResult)"
        } else {
            return ""
        }
    }
    
    private func runExperiment(numHoles: Int, trials: Int) async {
        UIApplication.shared.isIdleTimerDisabled = true
        let clockp = ContinuousClock()
        loading = true
        let parallelResult = await String(describing: clockp.measure {
            for _ in 0..<trials {
                var board = Board()
                await board.buildPuzzle(n: numHoles, parallel: true)
            }
        })
        
        let clock = ContinuousClock()
        
        let result = await String(describing: clock.measure {
            for _ in 0..<trials {
                var board = Board()
                await board.buildPuzzle(n: numHoles, parallel: false)
            }
        })
        let newExperiment = ExperimentData(sequentialResult: result, parallelResult: parallelResult, numHoles: numHoles, numTrials: trials)
        experimentStore.recentExperiment = newExperiment
        do {
            try experimentStore.save()
        } catch {
            print("Failed to store experiment data")
        }
        UIApplication.shared.isIdleTimerDisabled = false
        loading = false
    }
}

struct ExperimentView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentView()
            .environmentObject(ModelData())
            .environmentObject(ExperimentStore())
    }
}
