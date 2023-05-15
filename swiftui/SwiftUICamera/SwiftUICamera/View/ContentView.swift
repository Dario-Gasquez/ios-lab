//
//  ContentView.swift
//  SwiftUICamera
//
//  Created by Dario on 21/07/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            FrameView(image: viewModel.videoFrame)
                .edgesIgnoringSafeArea(.all)

            ErrorView(error: viewModel.error)

            ControlView(comicSelected: $viewModel.isComicFilterEnabled, monoSelected: $viewModel.isMonoFilterEnabled, crystalSelected: $viewModel.isCrystalFilterEnabled)
        }
    }

    // MARK: - Private Section -
    @StateObject private var viewModel = ContentViewModel()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
