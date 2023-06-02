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
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        if loading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else if puzzling {
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
                        Menu {
                            Button {
                                print("hard")
                                loading.toggle()
                                var newBoard = Board()
                                newBoard.buildPuzzle(n: 52)
                                modelData.board = newBoard
                                Task {
                                    do {
                                        try await modelData.save()
                                    } catch {
                                        print("something went wrong saving data")
                                    }

                                }
                                puzzling.toggle()
                                loading.toggle()
                            } label: {
                                Text("Hard")
                            }
                            Button {
                                print("medium")
                                loading = true
                                var newBoard = Board()
                                newBoard.buildPuzzle(n: 47)
                                modelData.board = newBoard
                                Task {
                                    do {
                                        print("entering the task")
                                        try await modelData.save()
                                    } catch {
                                        print("something went wrong saving data")
                                    }

                                }
                                puzzling.toggle()
                                loading = false
                            } label: {
                                Text("Medium")
                            }
                            Button {
                                print("easy")
                                loading = true
                                var newBoard = Board()
                                newBoard.buildPuzzle()
                                modelData.board = newBoard
                                Task {
                                    do {
                                        print("entering the task")
                                        try await modelData.save()
                                    } catch {
                                        print("something went wrong saving data")
                                    }

                                }
                                puzzling.toggle()
                                loading = false
                            } label: {
                                Text("Easy")
                            }
                        } label: {
                            Label("New Game", systemImage: "star.fill")
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                        }
                        .background(.teal)
                        .cornerRadius(10)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
