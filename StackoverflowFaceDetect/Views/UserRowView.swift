//
//  UserRowView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    @ObservedObject var viewModel: UsersViewModel
    
    var body: some View {
        HStack {
            Group {
                if let imageData = viewModel.userImagesData[user.id] {
                    // Show the processed image and face detection result
                    Image(uiImage: imageData.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else if viewModel.processingUsers.contains(user.id) {
                    // Show a progress indicator for this specific user
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
                    // Show a placeholder until processing begins
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                Text("Reputation: \(user.reputation)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            // Face detection indicator
            if let imageData = viewModel.userImagesData[user.id] {
                Image(systemName: imageData.faceMetadata.hasFace ?
                      "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(imageData.faceMetadata.hasFace ?
                                   .green : .red)
            }
        }
    }
}
