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
    var body: some View {
        if puzzling && !loading {
            PuzzleView(puzzling: $puzzling)
                .environmentObject(modelData)
        } else {
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
                                            await createPuzzle(num: 52)
                                        }
                                    } label: {
                                        Text("Hard")
                                    }
                                    .disabled(loading)
                                    Button {
                                        Task {
                                            await createPuzzle(num: 47)
                                        }
                                    } label: {
                                        Text("Medium")
                                    }
                                    Button {
                                        Task {
                                            await createPuzzle()
                                        }
                                    } label: {
                                        Text("Easy")
                                    }
                                }
                                .presentationDetents([.medium])
                                .opacity(loading ? 0: 1)
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
                }
            }
            .padding()
        }
    }
    
    private func createPuzzle(num: Int = 30) async {
        loading = true
        Task.detached {
            do {
                var newBoard = Board()
                newBoard.buildPuzzle(n: num)
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
    }
}
