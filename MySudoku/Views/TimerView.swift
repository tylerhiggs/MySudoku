//
//  TimerView.swift
//  MySudoku
//
//  Created by Tyler Higgs on 6/15/23.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        Text("\(twoDidgitsOrMore(i: hours)) : \(twoDidgitsOrMore(i: minutes)) : \(twoDidgitsOrMore(i: seconds))")
            .onAppear(perform: modelData.startTimer)
            .onDisappear(perform: modelData.stopTimer)
    }
    
    private var totalSeconds: Int {
        modelData.board.progressTime
    }
    
    private var hours: Int {
        self.totalSeconds / 3600
    }
    
    private var minutes: Int {
        (
            self.totalSeconds / 60
        ) % 60
    }
    
    private var seconds: Int {
        self.totalSeconds % 60
    }
    
    private func twoDidgitsOrMore(i: Int) -> String {
        return i < 10 ? "0" + "\(i)" : "\(i)"
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(ModelData())
    }
}
