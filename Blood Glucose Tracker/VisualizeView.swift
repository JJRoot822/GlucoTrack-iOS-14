//
//  VisualizeView.swift
//  Blood Glucose Tracker
//
//  Created by Josh Root on 12/22/20.
//

import SwiftUI

struct VisualizeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BGLMeasurement.dateMeasured, ascending: true)],
        animation: .default)
    private var items: FetchedResults<BGLMeasurement>
    
    @State private var color: Color = .blue
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                ColorPicker("Data Color", selection: $color)
                    .padding(.top, 15)
                Spacer()
                ScrollView(.horizontal) {
                    HStack(alignment: .bottom, spacing: 15) {
                        ForEach(items, id: \.id) { measurement in
                            VStack(spacing: 3) {
                                Text("\(measurement.level)")
                                VStack(spacing: 10) {
                                    Capsule()
                                        .frame(width: 45, height: CGFloat(Double(Int(measurement.level)) * 0.5))
                                        .foregroundColor(color)
                                    Text("\(dateFormatter.string(from: measurement.dateMeasured!))")
                                    Text("\(timeFormatter.string(from: measurement.dateMeasured!))")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle(Text("Visualize Data"))
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

struct VisualizeView_Previews: PreviewProvider {
    static var previews: some View {
        VisualizeView()
    }
}
