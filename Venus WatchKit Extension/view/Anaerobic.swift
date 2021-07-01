//
//  Anaerobic.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/6/29.
//

import SwiftUI

struct Anaerobic: View {
    @ObservedObject var workoutManager: WorkoutManager
    @State var isAtMaxScale = false
    
    private let animation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    private let maxScale: CGFloat = 1.1
    
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 50))
                .offset(x: 0, y: -10.0)
                .scaleEffect(isAtMaxScale ? maxScale : 1)
            
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
                        Image(systemName: workoutManager.state == .running ? "speaker" : (workoutManager.state == .paused) ? "speaker.slash" : "speaker")
                    })
                    .disabled(workoutManager.state != .running && workoutManager.state != .paused)
                    
                    Button(action: {
                        if workoutManager.state == .notStarted || workoutManager.state == .ended {
                            workoutManager.startSession(activityType: .coreTraining, locationType: .indoor)
                            withAnimation (Animation.easeOut(duration: 1).repeatForever(autoreverses: true)) {
                                isAtMaxScale = true
                            }
                        } else if workoutManager.state == .running || workoutManager.state == .paused {
                            workoutManager.stopSession()
                            withAnimation (Animation.easeOut(duration: 1)) {
                                isAtMaxScale = false
                            }
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

struct Anaerobic_Previews: PreviewProvider {
    static var previews: some View {
        Anaerobic(workoutManager: DefaultWorkoutManager)
    }
}
