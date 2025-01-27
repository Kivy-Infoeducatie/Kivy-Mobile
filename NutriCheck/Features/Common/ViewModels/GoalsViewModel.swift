//
//  GoalsViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation

class GoalsViewModel: ObservableObject {
    static let shared = GoalsViewModel()
    
    @Published private(set) var activeEnergyGoal: Double = 300
    @Published private(set) var stepsGoal: Double = 10000
    @Published private(set) var distanceGoal: Double = 5000
    
    private let activeEnergyGoalKey = "active_energy_goal"
    private let stepsGoalKey = "steps_goal"
    private let distanceGoalKey = "distance_goal"
    private let storage = UserDefaults.standard
    
    private init() {
        loadState()
    }
    
    func updateActiveEnergyGoal(_ goal: Double) {
        activeEnergyGoal = goal
        storage.set(goal, forKey: activeEnergyGoalKey)
    }
    
    func updateStepsGoal(_ goal: Double) {
        stepsGoal = goal
        storage.set(goal, forKey: stepsGoalKey)
    }
    
    func updateDistanceGoal(_ goal: Double) {
        distanceGoal = goal
        storage.set(goal, forKey: distanceGoalKey)
    }
    
    private func loadState() {
        if storage.double(forKey: activeEnergyGoalKey) == 0 {
            storage.set(300, forKey: activeEnergyGoalKey)
        }
        if storage.double(forKey: stepsGoalKey) == 0 {
            storage.set(10000, forKey: stepsGoalKey)
        }
        if storage.double(forKey: distanceGoalKey) == 0 {
            storage.set(5000, forKey: distanceGoalKey)
        }
        
        activeEnergyGoal = storage.double(forKey: activeEnergyGoalKey)
        stepsGoal = storage.double(forKey: stepsGoalKey)
        distanceGoal = storage.double(forKey: distanceGoalKey)
    }
}
