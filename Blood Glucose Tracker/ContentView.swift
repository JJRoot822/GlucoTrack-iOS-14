//
//  ContentView.swift
//  Blood Glucose Tracker
//
//  Created by Josh Root on 12/21/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BGLMeasurement.dateMeasured, ascending: true)],
        animation: .default)
    private var items: FetchedResults<BGLMeasurement>

    @State private var level: Int16 = 70
    @State private var dateMeasured: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 5) {
                    Text("\(level) mg/dL")
                        .accessibility(hidden: true)
                    Stepper("", onIncrement: { level += 1 }, onDecrement: { level -= 1 })
                }
                .accessibilityElement()
                .accessibility(label: Text("Blood Sugar Level: \(level) mg/dL"))
                .accessibility(value: Text("\(level) miligrams per deciliter"))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: level += 1
                    case .decrement: level -= 1
                    @unknown default:
                        fatalError("Something Went Wrong!")
                    }
                }
                .accessibilityAction(named: Text("Reset Glucose Level")) {
                    level = 0
                }
                VStack(alignment: .leading) {
                    DatePicker("Date", selection: $dateMeasured)
                        .accentColor(.green)
                }
                List {
                    ForEach(items, id: \.id) { measurement in
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(getIconColor(level: measurement.level, min: 70, max: 130))
                                .accessibility(hidden: true)
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("\(measurement.level)mg/dL")
                            }
                            .frame(width: 120)
                            
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(dateMeasuredFormatter.string(from: measurement.dateMeasured!))")
                                Text("\(timeMeasuredFormatter.string(from: measurement.dateMeasured!))")
                            }
                        }
                        .padding(.all, 3)
                    }
                    .onDelete(perform: deleteItems)
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationBarItems(trailing:
                HStack(spacing: 20) {
                    #if os(iOS)
                        EditButton()
                            .accentColor(.green)
                    #endif
                    
                    Button(action: addItem, label: {
                        Image(systemName: "plus.circle")
                    })
                    .accessibility(label: Text("Add"))
                    .accentColor(.green)
                }
            )
            .navigationTitle(Text("Measurements"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func getIconColor(level: Int16, min: Int, max: Int) -> Color {
        if (level >= min && level <= max) {
            return .green
        } else if ((level < min && level >= min - 10) || (level > max && level <= max + 10)) {
                return .yellow
        } else if ((level < min - 10 && level >= min - 20) || (level > max + 10 && level <= max + 20)) {
            return .orange
        } else if (level < min - 20 || level > max + 20) {
            return .red
        } else {
            return Color(.label)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = BGLMeasurement(context: viewContext)
            
            newItem.id = UUID()
            newItem.level = level
            newItem.dateMeasured = dateMeasured
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateMeasuredFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

private let timeMeasuredFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
