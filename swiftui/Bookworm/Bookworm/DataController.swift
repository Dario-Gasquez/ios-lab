//
//  DataController.swift
//  Bookworm
//
//  Created by Dario on 30/05/2022.
//

import CoreData

final class DataController: ObservableObject {

    init() {
        container.loadPersistentStores { description, error in
            if let anError = error {
                print("Core Data failed to load: \(anError.localizedDescription)")
            }
        }
    }

    let container = NSPersistentContainer(name: "Bookworm")
}
