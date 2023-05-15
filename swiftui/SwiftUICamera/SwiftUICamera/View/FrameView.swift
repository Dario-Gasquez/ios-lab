//
//  FrameView.swift
//  SwiftUICamera
//
//  Created by Dario on 21/07/2022.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Camera Feed")


    var body: some View {
        if let anImage = image {
            GeometryReader { geometry in
                Image(anImage, scale: 1.0, orientation: .up, label: label)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .clipped()
            }
        } else {
            Color.black
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
