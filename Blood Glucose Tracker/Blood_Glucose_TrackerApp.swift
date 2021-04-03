//
//  Blood_Glucose_TrackerApp.swift
//  Blood Glucose Tracker
//
//  Created by Josh Root on 12/21/20.
//

import SwiftUI

@main
struct Blood_Glucose_TrackerApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        UITabBar.appearance().barTintColor = UIColor(named: "barBackground")
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Image(systemName: "doc.text.below.ecg.fill")
                        Text("Measurements Data")
                    }
                    .tag(0)
                VisualizeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Visualize Measurement Data")
                    }
                    .tag(1)
            }
            .accentColor(.green)
        }
    }
}
