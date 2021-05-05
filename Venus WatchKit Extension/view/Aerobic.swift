//
//  Aerobic.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/5/3.
//

import SwiftUI

struct Aerobic: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        Text("\(healthManager.heartRate ?? 0)")
    }
}

struct Aerobic_Previews: PreviewProvider {
    static var previews: some View {
        Aerobic().environmentObject(HealthManager.default)
    }
}
