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
        List {
            ForEach(["有氧", "无氧"], id: \.self) { (value) in
                
                Button(action: {
                    print("\(value) tapped")
                }, label: {
                    Text(value)
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HealthManager.default)
    }
}
