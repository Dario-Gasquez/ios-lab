//
//  ContentView.swift
//  statusBarTest
//
//  Created by Dario on 05/09/2022.
//

import SwiftUI

struct ContentView: View {

    @State private var hideStatusBar = false

    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()
            VStack {
                picMyMealButton
//                Spacer().frame(height: 20)
//                wearableConnectionView
//                Spacer().frame(height: 20)
//                connectWearableButton
                Spacer()
            }
            .padding([.top, .leading, .trailing], 10.0)
        }
        .statusBar(hidden: hideStatusBar)
        .fullScreenCover(item: $activeSheet) { activeSheet in
            switch activeSheet {
            case .connectWearable:
                PictureCaptureView(hideParentStatusBar: $hideStatusBar)
            case .pictureViewer:
                PictureCaptureView(hideParentStatusBar: $hideStatusBar)
            }
        }
    }


    private enum ActiveSheet: Identifiable {
        case connectWearable
        case pictureViewer

        var id: Int { hashValue }
    }

    private enum Constants {
        static let cornerRadius: CGFloat = 15
    }

    @State private var activeSheet: ActiveSheet?


    private var picMyMealButton: some View {
        Button {
            activeSheet = .pictureViewer
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Pic my Meal").font(.headline)
                }
                Text("Take a picture of your meal and see how it does with your health.").font(.subheadline)
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color.blue, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
