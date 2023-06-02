//
//  PuzzleView.swift
//  MySudoku
//
//  Created by Tyler Higgs on 5/30/23.
//

import SwiftUI

class Coord {
    
    var row: Int
    var col: Int
    
    init(i: Int, j: Int) {
        self.row = i
        self.col = j
    }
    
}

struct PuzzleView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Binding var puzzling: Bool
    @State private var noteMode = false
    @State private var selectedBox: Coord? = nil
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        puzzling.toggle()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.iconOnly)
                            .padding([.leading, .bottom], 16)
                            .font(.system(size: 24))
                    }
                    Spacer()
                }
            }
            .frame(alignment: .topLeading)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<9) { i in
                    if i % 3 == 0 {
                        Divider().overlay(.black)
                    } else {
                        Divider()
                    }
                    GridRow {
                        HStack(spacing: 0) {
                            ForEach(0..<9) { j in
                                if j % 3 == 0 {
                                    Divider()
                                        .overlay(.black)
                                } else {
                                    Divider()
                                }
                                    Button {
                                        selectedBox = Coord(i: i, j: j)
                                        } label: {
                                            if unified[i][j] != 0 {
                                                Label("\(unified[i][j])", systemImage: "bolt.fill")
                                                    .labelStyle(.titleOnly)
                                                    .foregroundColor(grid[i][j] != 0 ? .black : fills[i][j] == solution[i][j] ? .blue : .red)
                                                    .font(.system(size: 30, design: .monospaced))
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            } else {
                                                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                                                    ForEach(0..<3) { k in
                                                        GridRow {
                                                            ForEach(0..<3) { l in
                                                                if candidates[i][j].contains("\(k * 3 + l + 1)") {
                                                                    Text("\(k * 3 + l + 1)")
                                                                        .font(.system(size: 10))
                                                                        .foregroundColor(.gray)
                                                                        .background(selectedNum == k * 3 + l + 1 ? MyColors.highlight : nil)
                                                                } else {
                                                                    Color.clear
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .aspectRatio(1, contentMode: .fit)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(grid[i][j] == selectedNum || fills[i][j] == selectedNum || isHighlightBox(i: i, j: j) ? MyColors.highlight : nil)
                                        .aspectRatio(1, contentMode: .fit)
                            }
                            Divider()
                                .overlay(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                Divider()
                    .overlay(.black)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(4)
            
            HStack {
                Button {
                    noteMode.toggle()
                } label: {
                    VStack {
                        Image(systemName: "pencil")
                            .foregroundColor(pencilColor)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                        Text("Pencil")
                            .foregroundColor(pencilColor)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
                    .background(noteMode ? Color("SelectedBackground") : nil)
                    .cornerRadius(10)

                }
            }
            HStack {
                ForEach(1..<10) { i in
                    Button {
                        guard let safeSelectedBox = selectedBox else {
                            let impact = UIImpactFeedbackGenerator(style: .rigid)
                            impact.impactOccurred()
                            return
                        }
                        if noteMode {
                            if !modelData.board.isSafe(i: safeSelectedBox.row, j: safeSelectedBox.col, n: i) {
                                let impact = UIImpactFeedbackGenerator(style: .rigid)
                                impact.impactOccurred()
                                return
                            }
                            let prevNotes = candidates[safeSelectedBox.row][safeSelectedBox.col]
                            if prevNotes.contains("\(i)") {
                                modelData.board.candidates[safeSelectedBox.row][safeSelectedBox.col] = prevNotes.filter {"\($0)" == "\(i)"}
                            } else {
                                modelData.board.candidates[safeSelectedBox.row][safeSelectedBox.col] = prevNotes + "\(i)"
                            }
                            Task {
                                do {
                                    try await modelData.save()
                                } catch {
                                    print("something went wrong saving")
                                    modelData.board.fills[safeSelectedBox.row][safeSelectedBox.col] = 0
                                }
                            }
                            return
                        }
                        modelData.board.fills[safeSelectedBox.row][safeSelectedBox.col] = fills[safeSelectedBox.row][safeSelectedBox.col] == i ? 0 : i
                        Task {
                            do {
                                try await modelData.save()
                            } catch {
                                print("something went wrong saving")
                                modelData.board.fills[safeSelectedBox.row][safeSelectedBox.col] = 0
                            }
                        }
                        
                    } label: {
                        VStack {
                            if noteMode {
                                Text("\(i)")
                                    .padding([.horizontal], 9)
                                    .foregroundColor(selectedNotes.contains("\(i)") ? .black : MyColors.lightGray)
                                .font(.system(size: 30))
                                Text("\(numLeft(num: i))")
                                    .foregroundColor(selectedNotes.contains("\(i)") ? .black : MyColors.lightGray)
                            } else {
                                Text("\(i)")
                                    .padding([.horizontal], 9)
                                    .foregroundColor(numLeft(num: i) == 0 ? MyColors.lightGray : .blue)
                                    .font(.system(size: 30))
                                Text("\(numLeft(num: i))")
                                    .foregroundColor(numLeft(num: i) == 0 ? MyColors.lightGray : .black)
                            }
                        }
                    }
                    .cornerRadius(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    }
                    .shadow(color: noteMode && !selectedNotes.contains("\(i)") ? Color.white : Color.gray.opacity(0.5), radius: 5, x: 0, y: 0)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var pencilColor: Color {
        noteMode ? .purple : .gray
    }
    
    private var grid: Array<Array<Int>> {
        modelData.board.grid
    }
    
    private var fills: Array<Array<Int>> {
        modelData.board.fills
    }
    
    private var candidates: Array<Array<String>> {
        modelData.board.candidates
    }
    
    private var solution: Array<Array<Int>> {
        modelData.board.solution
    }
    
    private var unified: Array<Array<Int>> {
        grid.enumerated().map {(i: Int, row: Array<Int>) in
            row.enumerated().map {(j: Int, num: Int) in
                num != 0 ? num : fills[i][j]
            }
        }
    }
    
    private func numLeft(num: Int) -> Int {
        return 9 - unified.reduce(0) {$0 + $1.filter {$0 == num}.count}
    }
    
    private var selectedNum: Int {
        if selectedBox == nil {
            return -1
        }
        let (i, j) = (selectedBox!.row, selectedBox!.col)
        return grid[i][j] != 0 ? grid[i][j] : fills[i][j] != 0 ? fills[i][j] : -1
    }
    
    private var selectedNotes: String {
        if selectedBox == nil {
            return ""
        }
        let (i, j) = (selectedBox!.row, selectedBox!.col)
        return unified[i][j] == 0 ? candidates[i][j] : ""
    }
    
    private func isHighlightBox(i: Int, j: Int) -> Bool {
        guard let safeSelectedBox = selectedBox else {
            return false
        }
        return unified[i][j] == 0 && selectedBox != nil && safeSelectedBox.col == j && safeSelectedBox.row == i
    }
}

struct Puzzle_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleView(puzzling: .constant(true))
            .environmentObject(ModelData())
    }
}