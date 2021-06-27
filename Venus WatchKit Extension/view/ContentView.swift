//
//  ContentView.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/3/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Aerobic(workoutManager: self.workoutManager)) {
                    HStack() {
                        Text("无氧")
                        Spacer()
                        Image(systemName: "play")
                    }
                }
                NavigationLink(destination: Text("Destination")) {
                    HStack() {
                        Text("有氧")
                        Spacer()
                        Image(systemName: "play")
                    }
                }.disabled(true)
            }
            .navigationTitle("运动类型")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WorkoutManager.default)
    }
}