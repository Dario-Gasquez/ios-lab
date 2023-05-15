//
//  PicturePreview.swift
//  statusBarTest
//
//  Created by Dario on 05/09/2022.
//

import SwiftUI

struct PicturePreview: View {
    var body: some View {
        Text("Picture Preview View")
            .statusBar(hidden: false)
    }
}

struct PicturePreview_Previews: PreviewProvider {
    static var previews: some View {
        PicturePreview()
    }
}
