//
//  MySudokuApp.swift
//  MySudoku
//
//  Created by Tyler Higgs on 5/25/23.
//

import SwiftUI

@main
struct MySudokuApp: App {
    @StateObject private var modelData = ModelData()
    @StateObject private var experimentStore = ExperimentStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .environmentObject(experimentStore)
        }
    }
}
