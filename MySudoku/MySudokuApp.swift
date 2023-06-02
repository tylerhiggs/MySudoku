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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}
