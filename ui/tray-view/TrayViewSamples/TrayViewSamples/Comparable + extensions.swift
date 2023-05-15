//
//  Comparable + extensions.swift
//  TrayViewSamples
//
//  Created by Dario on 5/25/20.
//

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
