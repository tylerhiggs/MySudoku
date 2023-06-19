//
//  ContentView.swift
//  MySudoku
//
//  Created by Tyler Higgs on 5/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var puzzling = false
    @State private var loading = false
    @State private var menuOpen = false
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var experimentStore: ExperimentStore
    
    // For testing only
    @State private var parallelResult: String? = nil
    @State private var regularResult: String? = nil
    
    
    var body: some View {
        if puzzling && !loading {
            PuzzleView(puzzling: $puzzling)
                .environmentObject(modelData)
        } else {
            NavigationView {
                ZStack {
                    Image(systemName: "square.grid.3x3.middleleft.filled")
                        .resizable()
                        .frame(width: 96, height: 96)
                        .foregroundColor(.teal)
                    VStack {
                        Spacer()
                        VStack {
                            Button {
                                menuOpen = true
                            } label: {
                                Label("New Game", systemImage: "star.fill")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                            }
                            .background(.teal)
                            .cornerRadius(10)
                            .sheet(isPresented: $menuOpen) {
                                ZStack {
                                    if loading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                    VStack {
                                        Button {
                                            Task {
                                                await createPuzzle()
                                            }
                                        } label: {
                                            Text("Easy")
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .foregroundColor(.teal)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.teal, lineWidth: 1)
                                        }
                                        
                                        Button {
                                            Task {
                                                await createPuzzle(num: 47)
                                            }
                                        } label: {
                                            Text("Medium")
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .foregroundColor(.teal)
                                        }
                                        .disabled(loading)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.teal, lineWidth: 1)
                                        }
                                        
                                        Button {
                                            Task {
                                                await createPuzzle(num: 52)
                                            }
                                        } label: {
                                            Text("Hard")
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .foregroundColor(.teal)
                                        }
                                        .disabled(loading)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.teal, lineWidth: 1)
                                        }
                                        Button {
                                            Task {
                                                await createPuzzle(num: 56)
                                            }
                                        } label: {
                                            Text("Expert")
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .foregroundColor(.teal)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.teal, lineWidth: 1)
                                        }
                                    }
                                    .presentationDetents([.medium])
                                    .opacity(loading ? 0: 1)
                                    .padding()
                                }
                            }
                        }
                        Button {
                            puzzling.toggle()
                        } label: {
                            Label("Continue", systemImage: "star.fill")
                                .labelStyle(.titleOnly)
                                .foregroundColor(.purple)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.purple, lineWidth: 1)
                        }
                        
                        NavigationLink {
                            ExperimentView()
                                .environmentObject(modelData)
                                .environmentObject(experimentStore)
                        } label: {
                            Text("Experiment")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.purple)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func createPuzzle(num: Int = 30) async {
        print("creating puzzle")
        loading = true
        Task.detached {
            do {
                var newBoard = Board()
                await newBoard.buildPuzzle(n: num)
                await MainActor.run { [newBoard] in
                    self.modelData.board = newBoard
                    self.loading = false
                    puzzling.toggle()
                    menuOpen = false
                }
                try await modelData.save()
            } catch {
                print("something went wrong saving data")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
            .environmentObject(ExperimentStore())
    }
}
