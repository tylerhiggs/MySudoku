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
    @State private var forceChainMode = false
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
                    TimerView()
                        .environmentObject(modelData)
                        .padding()
                }
            }
            .frame(alignment: .topLeading)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<9) { i in
                    if i % 3 == 0 {
                        Divider().overlay(MyColors.darkLine)
                    } else {
                        Divider().overlay(MyColors.lightLine)
                    }
                    GridRow {
                        HStack(spacing: 0) {
                            ForEach(0..<9) { j in
                                if j % 3 == 0 {
                                    Divider()
                                        .overlay(MyColors.darkLine)
                                } else {
                                    Divider()
                                        .overlay(MyColors.lightLine)
                                }
                                    Button {
                                        selectedBox = Coord(i: i, j: j)
                                        } label: {
                                            if unified[i][j] != 0 {
                                                Label("\(unified[i][j])", systemImage: "bolt.fill")
                                                    .labelStyle(.titleOnly)
                                                    .foregroundColor(numberColor(i, j))
                                                    .font(.system(size: 30, design: .monospaced))
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            } else {
                                                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                                                    ForEach(0..<3) { k in
                                                        GridRow {
                                                            ForEach(0..<3) { l in
                                                                if showCandidate(i, j, k, l) {
                                                                    ZStack {
                                                                        if selectedNum == k * 3 + l + 1 {
                                                                            MyColors.highlight
                                                                        }
                                                                        Text("\(k * 3 + l + 1)")
                                                                            .font(.system(size: 10, design: .monospaced))
                                                                            .foregroundColor(MyColors.lightLine)
                                                                    }
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
                                        .background(boxBackground(i, j))
                                        .aspectRatio(1, contentMode: .fit)
                            }
                            Divider()
                                .overlay(MyColors.darkLine)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                Divider()
                    .overlay(MyColors.darkLine)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(4)
            
            HStack {
                Button {
                    modelData.board.candidates = [Array](repeating: [String](repeating: "123456789", count: 9), count: 9)
                    Task {
                        do {
                            try await modelData.save()
                        } catch {
                            print("there was an issue with auto saving notes")
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "pencil.and.outline")
                            .foregroundColor(.gray)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                            .frame(height: 44)
                        Text("Autofill")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .padding([.horizontal], 4)
                        Text("Notes")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
                    .cornerRadius(10)
                    .disabled(modelData.board.peek() == nil)

                }
                
                Button {
                    forceChainMode.toggle()
                } label: {
                    VStack {
                        Image(systemName: "link")
                            .foregroundColor(forceChainMode ? .green : .gray)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                            .frame(height: 44)
                        Text("Force")
                            .foregroundColor(forceChainMode ? .green : .gray)
                            .font(.system(size: 12))
                            .padding([.horizontal], 4)
                        Text("Chain")
                            .foregroundColor(forceChainMode ? .green : .gray)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
                    .cornerRadius(10)
                    .disabled(modelData.board.peek() == nil)

                }
                
                Button {
                    let _ = modelData.board.pop()
                    Task {
                        do {
                            try await modelData.save()
                        } catch {
                            print("there was an issue saving hint")
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.gray)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                            .frame(height: 44)
                        Text("Undo")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
                    .cornerRadius(10)
                    .disabled(modelData.board.peek() == nil)

                }
                Button {
                    noteMode.toggle()
                } label: {
                    VStack {
                        Image(systemName: "pencil")
                            .foregroundColor(pencilColor)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                            .frame(height: 44)
                        Text("Pencil")
                            .foregroundColor(pencilColor)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
                    .background(noteMode ? MyColors.lightGray : nil)
                    .cornerRadius(10)

                }
                Button {
                    guard let safeSelectedBox = selectedBox else {
                        let impact = UIImpactFeedbackGenerator(style: .rigid)
                        impact.impactOccurred()
                        return
                    }
                    let (i, j) = (safeSelectedBox.row, safeSelectedBox.col)
                    if fills[i][j] != 0 {
                        let impact = UIImpactFeedbackGenerator(style: .rigid)
                        impact.impactOccurred()
                        return
                    }
                    modelData.board.fills[i][j] = solution[i][j]
                    Task {
                        do {
                            try await modelData.save()
                        } catch {
                            print("there was an issue saving hint")
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 28))
                            .padding([.vertical], 1)
                            .padding([.top], 4)
                            .frame(height: 44)
                        Text("Hint")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 12))
                            .padding([.bottom], 8)
                            .padding([.horizontal], 4)
                    }
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
                            let prevNotes = candidates[safeSelectedBox.row][safeSelectedBox.col]
                            if prevNotes.contains("\(i)") {
                                let newMove = Move(row: safeSelectedBox.row, col: safeSelectedBox.col, num: i, isNote: true)
                                modelData.board.push(newMove)
                            } else {
                                if !modelData.board.isSafe(i: safeSelectedBox.row, j: safeSelectedBox.col, n: i) {
                                    let impact = UIImpactFeedbackGenerator(style: .rigid)
                                    impact.impactOccurred()
                                    return
                                }
                                let newMove = Move(row: safeSelectedBox.row, col: safeSelectedBox.col, num: i, isNote: true)
                                modelData.board.push(newMove)
                            }
                            Task {
                                do {
                                    try await modelData.save()
                                } catch {
                                    print("something went wrong saving")
                                    modelData.board.candidates[safeSelectedBox.row][safeSelectedBox.col] = prevNotes
                                }
                            }
                            return
                        }
                        modelData.board.push(Move(row: safeSelectedBox.row, col: safeSelectedBox.col, num: i, isForceChain: forceChainMode))
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
                            .fill(Color.white.opacity(0.7))
                    }
                    .shadow(color: noteMode && !selectedNotes.contains("\(i)") || !noteMode && numLeft(num: i) == 0 ? Color.white : Color.gray.opacity(0.5), radius: 5, x: 0, y: 0)
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
    
    private var forceChainAttempt: Array<Array<Int>> {
        modelData.board.forceChainAttempt
    }
    
    private var unified: Array<Array<Int>> {
        grid.enumerated().map {(i: Int, row: Array<Int>) in
            row.enumerated().map {(j: Int, num: Int) in
                num != 0 ? num : fills[i][j] != 0 || !forceChainMode ? fills[i][j] : forceChainAttempt[i][j]
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
        return unified[i][j] != 0 ? unified[i][j] : -1
    }
    
    private var selectedNotes: String {
        if selectedBox == nil {
            return ""
        }
        let (i, j) = (selectedBox!.row, selectedBox!.col)
        return unified[i][j] == 0 ? candidates[i][j].filter {
            guard let safeNum = Int("\($0)") else {
                return false
            }
            return modelData.board.isSafe(i: i, j: j, n: safeNum)
            
        } : ""
    }
    
    private func isHighlightBox(i: Int, j: Int) -> Bool {
        guard let safeSelectedBox = selectedBox else {
            return false
        }
        return unified[i][j] == 0 && selectedBox != nil && safeSelectedBox.col == j && safeSelectedBox.row == i
    }
    
    private func numberColor(_ i: Int, _ j: Int) -> Color {
        if grid[i][j] != 0 {
            return MyColors.darkLine
        } else if fills[i][j] != 0 {
            return fills[i][j] != solution[i][j] ? Color.red : Color.blue
        } else {
            return Color.green
        }
    }
    
    private func showCandidate(_ i: Int, _ j: Int, _ k: Int, _ l: Int) -> Bool {
        candidates[i][j].contains("\(k * 3 + l + 1)") && modelData.board.isSafe(i: i, j: j, n: k * 3 + l + 1)
    }
    
    private func boxBackground(_ i: Int, _ j: Int) -> Color? {
        unified[i][j] == selectedNum || isHighlightBox(i: i, j: j) ? MyColors.highlight : nil
    }
}

struct Puzzle_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleView(puzzling: .constant(true))
            .environmentObject(ModelData())
            .preferredColorScheme(.dark)
    }
}
