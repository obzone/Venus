//
//  HealthManager.swift
//  Venus WatchKit Extension
//
//  Created by 邵业程 on 2021/3/31.
//

import Foundation
import HealthKit

let DefaultHealthManager = HealthManager.default

class HealthManager: NSObject, ObservableObject {
    
    static let `default` = HealthManager()
    
    let healthStore: HKHealthStore?
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    @Published var heartRate: Int?
    
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
                    // TODO Handle errors.
                    return
                }
                // TODO Indicate that the session has started.
            })
        } catch {
            return
        }
    }
    
    func stopSession() -> Void {
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
                }
            }
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
                    return
                }
                // TODO Indicate that the session has started.
            })
        })
    }
}

extension HealthManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        
    }
}
