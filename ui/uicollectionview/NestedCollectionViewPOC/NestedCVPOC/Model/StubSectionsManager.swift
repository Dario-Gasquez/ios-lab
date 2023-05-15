//
//  StubSectionsManager.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/22/20.
//

import Foundation

final class StubSectionsManager {
    static func generateSections() -> [Section] {
        let sections = Bundle.main.decode([Section].self, from: "Sections.json")
        var indexedSections = [Section]()

        for index in 0 ..< sections.count {
            let section = sections[index]
            indexedSections.append(Section(type: section.type, title: section.title, items: section.items, sectionIndex: index))
        }

        return indexedSections
    }
}
