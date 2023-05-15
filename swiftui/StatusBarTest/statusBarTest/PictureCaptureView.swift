//
//  PictureCaptureView.swift
//  HealthCoach
//
//  Created by Dario on 25/07/2022.
//

import SwiftUI
import SwiftyBeaver

struct PictureCaptureView: View {

    @Environment(\.presentationMode) var presentationMode
    @Binding var hideParentStatusBar: Bool

    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                Color.green.edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    NavigationLink("hidden (or not so hidden) nav. link", isActive: $isNavlinkActive) {
                        PicturePreview()
                    }

                    Button("close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

//                NoCameraAccessView()
            }
            .statusBar(hidden: false)
            .fullScreenCover(isPresented: $viewModel.showPhotoPicker) {
                viewModel.photoPickerView()
            }
        }
        .onDisappear(perform: {
            print("PictureCaptureView onDisappear -----")
            // NOTE: this works on iOS 14.0.1 with a glitch (status bar showing/hiding can be seen on presenting this view). On iOS 15.5 does not work as expected (but in that os version (and newer?) we do not need to resort to this hack
            hideParentStatusBar = false
        })
        .onAppear(perform: {
            print("PictureCaptureView onAppear -----")
            hideParentStatusBar = true
        })
    }


    // MARK: - Private Section -
    private enum Constants {
        static let popupAutohideTimeInSeconds = 3.0
        static let closeButtonImageName = "CrossIcon"
        static let uploadSuccessMessage = "Your meal was successfully posted!"
        static let uploadingMessage = "Uploading ..."
    }

    @StateObject private var viewModel = PictureCaptureViewModel()

    @State private var didChoosePicture = false
    @State private var showViewModelErrorPopup = false
    @State private var showUploadErrorPopup = false
    @State private var showUploadSucceededPopup = false
    @State private var isUploadingPicture = false
    @State private var isNavlinkActive = false

    private var closeButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(Constants.closeButtonImageName)
        }
        .padding([.top, .leading, .trailing])
    }
}




struct PictureViewerView_Previews: PreviewProvider {
    static var previews: some View {
        PictureCaptureView(hideParentStatusBar: .constant(true))
    }
}
