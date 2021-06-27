//
//  Aerobic.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/5/3.
//

import SwiftUI
import HealthKit

struct Aerobic: View {
    @ObservedObject var workoutManager: WorkoutManager
    
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 50))
                .offset(x: 0, y: -10.0)
            
            Text("\(workoutManager.heartRate)")
                .foregroundColor(.white)
                .offset(x: 0, y: -10.0)
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        if workoutManager.state == .running { // can pause workoutSession only if it is running
                            workoutManager.pause()
                        } else if workoutManager.state == .paused { // can resume workoutSeesion only if it is paused
                            workoutManager.resume()
                        }
                    }, label: {
                        Image(systemName: workoutManager.state == .running ? "pause" : (workoutManager.state == .paused) ? "play" : "pause")
                    })
                    .disabled(workoutManager.state != .running && workoutManager.state != .paused)
                    
                    Button(action: {
                        if workoutManager.state == .notStarted || workoutManager.state == .ended {
                            workoutManager.startSession(activityType: .coreTraining, locationType: .indoor)
                        } else if workoutManager.state == .running || workoutManager.state == .paused {
                            workoutManager.stopSession()
                        }
                    }, label: {
                        Image(systemName: workoutManager.state == .running ? "stop" : (workoutManager.state == .stopped || workoutManager.state == .notStarted || workoutManager.state == .ended) ? "play" : "stop" )
                    })
                    .disabled(workoutManager.state != .notStarted && workoutManager.state != .running && workoutManager.state != .paused && workoutManager.state != .ended)
                    
                }
            }
        }
    }
}

struct Aerobic_Previews: PreviewProvider {
    static var previews: some View {
        Aerobic(workoutManager: WorkoutManager.default)
    }
}
