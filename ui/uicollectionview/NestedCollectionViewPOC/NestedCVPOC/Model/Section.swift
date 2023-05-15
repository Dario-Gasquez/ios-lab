//
//  Section.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/22/20.
//



struct Section: Decodable {
    enum SectionType: String, Decodable {
        case ranking
        case result
    }

    let type: SectionType
    let title: String
    let items: [Item]
    var sectionIndex: Int?
}


struct Item: Decodable {
    let name: String?
    let imageFilename: String?
}
