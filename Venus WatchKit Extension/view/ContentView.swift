//
//  ContentView.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/3/11.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        NavigationView {
            List(["有氧", "无氧"], id: \.self) { item in
                NavigationLink(
                    destination: Text("Destination")) {
                    VStack {
                        Text(item)
                    }
                }
            }
            .navigationTitle("运动类型")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HealthManager.default)
    }
}
