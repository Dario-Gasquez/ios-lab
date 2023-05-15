//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Dario on 30/05/2022.
//

import SwiftUI

@main
struct BookwormApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }

    @StateObject private var dataController = DataController()
}
