//
//  UserRowView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import SwiftUICore
import SwiftUI


struct UserRowView: View {
    let user: User
    @ObservedObject var viewModel: UsersViewModel
    
    var body: some View {
        HStack {
            Group {
                if let imageData = viewModel.userImagesData[user.id] {
                    Image(uiImage: imageData.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            }
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                Text("Reputation: \(user.reputation)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            faceDetectionIcon

        }
    }
    // Computed property to handle the face detection icon logic
    private var faceDetectionIcon: some View {
        let hasFace = viewModel.userImagesData[user.id]?.faceMetadata.hasFace ?? false
        return Image(systemName: hasFace ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(hasFace ? .green : .red)
    }
}
