//
//  HealthManager.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/3/31.
//

import Foundation
import HealthKit

let DefaultHealthManager = WorkoutManager.default

class WorkoutManager: NSObject, ObservableObject {
    
    static let `default` = WorkoutManager()
    
    let healthStore: HKHealthStore?
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    var latestSpeakTime: Date?
    
    @Published var heartRate: Int = 0 // latest heartrate
    
    @Published var state: HKWorkoutSessionState = HKWorkoutSessionState.notStarted
    
    override init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            let typesToShare: Set = [
                HKQuantityType.workoutType()
            ]

            // The quantity types to read from the health store.
            let typesToRead: Set = [
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]

            // Request authorization for those quantity types.
            healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                // Handle errors here.
            }
        } else {
            healthStore = nil
        }
    }
    
    func startSession(activityType: HKWorkoutActivityType, locationType: HKWorkoutSessionLocationType) -> Void {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = locationType
        
        guard let healthStore = healthStore else {
            return
        }
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            session?.delegate = self
            builder?.delegate = self
            
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date(), completion: { (success, error) in
                guard success else {
                    print("-- start workoutSession error \(String(describing: error))")
                    // TODO Handle errors.
                    return
                }
                // TODO Indicate that the session has started.
                print("-- start workouSession success")
            })
        } catch {
            return
        }
    }
    
    func stopSession() -> Void {
        if session?.state != .stopped && session?.state != .running  {return}
        session?.end()
        builder?.endCollection(withEnd: Date()) { (success, error) in
            
            guard success else {
                // TODO Handle errors.
                return
            }
            
            self.builder?.finishWorkout { (workout, error) in
                
                guard workout != nil else {
                    // TODO Handle errors.
                    return
                }
                
                DispatchQueue.main.async() {
                    // Update the user interface.
                    // TODO notificate user workout is stopped
                }
            }
        }
    }
    
    func pause() -> Void {
        if session?.state == .running {
            session?.pause()
        }
    }
    
    func resume() -> Void {
        if session?.state == .paused {
            session?.resume()
        }
    }
    
    func recovery() -> Void {
        healthStore?.recoverActiveWorkoutSession(completion: { session, error in
            guard let _ = error else {
                // TODO 恢复失败
                return
            }
            self.session = session
            self.builder = session?.associatedWorkoutBuilder()
            self.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore!, workoutConfiguration: session?.workoutConfiguration)
            session?.delegate = self
            self.builder?.delegate = self
            
            session?.startActivity(with: Date())
            self.builder?.beginCollection(withStart: Date(), completion: { (success, error) in
                guard success else {
                    // TODO Handle errors.
                    print("-- recovery workoutSession error \(String(describing: error))")
                    return
                }
                // TODO Indicate that the session has started.
                print("-- recovery workoutSession success")
            })
        })
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            print(type)
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            // Calculate statistics for the type.
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            
            if quantityType == HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) {
                let mostRecentQuantity = statistics?.mostRecentQuantity()?.doubleValue(for: HKUnit.hertz())
                print("statistic \(String(describing: mostRecentQuantity))")
                if let hr = mostRecentQuantity {
                    DispatchQueue.main.async() { [self] in
                        let changedHeartrate = self.heartRate - Int(ceil(hr * 60))
                        
                        // call speak when changed heartrate more than 10 or last speak time more than 10 seconds
                        if ((latestSpeakTime?.timeIntervalSince1970 ?? 0) + 10) < Date().timeIntervalSince1970 || (abs(changedHeartrate) > 10) {
                            DefaultPlayerManager.speak(text: "心率 \(Int(ceil(hr * 60)))")
                            latestSpeakTime = Date()
                        }
                        // Update the user interface.
                        self.heartRate = Int(ceil(hr * 60))
                        
                    }
                }
            }
            
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        let lastEvent = workoutBuilder.workoutEvents.last
        print("-- workoutBuilder collect Event \(String(describing: lastEvent))")
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate  {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("-- workoutSession change state from \(fromState.rawValue) to \(toState.rawValue)")
        DispatchQueue.main.async { [self] in
            state = toState
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("-- workoutSession didFailWithError \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print("-- workoutSession didGenerate event \(event)")
    }
}
