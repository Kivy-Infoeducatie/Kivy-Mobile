//
//  HealthKitViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation
import HealthKit

class HealthKitViewModel: ObservableObject {
    static let shared = HealthKitViewModel()
    
    private let storage = HKHealthStore()
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        storage.requestAuthorization(toShare: nil, read: typesToRead) { _, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Steps Count
    
    func readStepsCountToday(completion: @escaping (Double) -> Void) {
        let stepsCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        storage.execute(query)
    }
    
    func readStepsRecordsToday(completion: @escaping ([HKQuantitySample]) -> Void) {
        let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: stepsQuantityType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }
            
            completion(samples)
        }
        
        storage.execute(query)
    }
    
    // MARK: - Active Energy Burned
    
    func readActiveEnergyBurnedToday(completion: @escaping (Double) -> Void) {
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.kilocalorie()))
        }
        
        storage.execute(query)
    }
    
    func readActiveEnergyBurnedRecordsToday(completion: @escaping ([HKQuantitySample]) -> Void) {
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: energyType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }
            
            completion(samples)
        }
        
        storage.execute(query)
    }
    
    // MARK: - Distance Walking Running
    
    func readDistanceWalkingRunningToday(completion: @escaping (Double) -> Void) {
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.meter()))
        }
        
        storage.execute(query)
    }
    
    func readDistanceWalkingRunningRecordsToday(completion: @escaping ([HKQuantitySample]) -> Void) {
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: distanceType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }
            
            completion(samples)
        }
        
        storage.execute(query)
    }
    
    // MARK: - Helper Methods
    
    func groupRecordsByHalfHour(_ samples: [HKQuantitySample], unit: HKUnit) -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        
        let groupedSamples = Dictionary(grouping: samples) { sample in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: sample.startDate)
            let minute = components.minute ?? 0
            let roundedMinute = minute >= 30 ? 30 : 0
            
            return calendar.date(bySettingHour: components.hour ?? 0,
                                 minute: roundedMinute,
                                 second: 0,
                                 of: sample.startDate) ?? sample.startDate
        }
        
        let startOfDay = calendar.startOfDay(for: Date())
        var intervals: [(date: Date, value: Double)] = []
        
        for halfHourIndex in 0 ..< 48 {
            let intervalStart = calendar.date(byAdding: .minute,
                                              value: halfHourIndex * 30,
                                              to: startOfDay) ?? startOfDay
            
            let value = groupedSamples[intervalStart]?
                .reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) } ?? 0.0
            
            intervals.append((intervalStart, value))
        }
        
        return intervals.sorted { $0.date < $1.date }
    }
    
    func groupedCalories() -> [(date: Date, value: Double)] {
        var calories: [(date: Date, value: Double)] = []
        
        readActiveEnergyBurnedRecordsToday { samples in
            calories = self.groupRecordsByHalfHour(samples, unit: .kilocalorie())
        }
        
        return calories
    }
    
    func groupedSteps() -> [(date: Date, value: Double)] {
        var steps: [(date: Date, value: Double)] = []
        
        readStepsRecordsToday { samples in
            steps = self.groupRecordsByHalfHour(samples, unit: .count())
        }
        
        return steps
    }
    
    func groupedDistance() -> [(date: Date, value: Double)] {
        var distance: [(date: Date, value: Double)] = []
        
        readDistanceWalkingRunningRecordsToday { samples in
            distance = self.groupRecordsByHalfHour(samples, unit: .meter())
        }
        
        return distance
    }
}
