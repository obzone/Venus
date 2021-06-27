//
//  HostingController.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/3/11.
//

import WatchKit
import Foundation
import SwiftUI
import HealthKit

class HostingController: WKHostingController<AnyView> {
    var workoutManager = WorkoutManager.default
    
    override var body: AnyView {
        print("-- recreate app")
        return AnyView(ContentView().environmentObject(self.workoutManager))
    }
}
