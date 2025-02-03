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
    @StateObject private var imageLoader = ImageLoader()
    @State private var hasFace = false
    
    var body: some View {
        HStack {
            Group {
                if let image = imageLoader.image {
                    Image(uiImage: image)
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
            
            Image(systemName: hasFace ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(hasFace ? .green : .red)
        }
        // In UserRowView
        .task {
            await imageLoader.loadImage(from: user.profileImage)
            guard let image = imageLoader.image else { return }
            
            // Add loading indicator
            let metadata = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let result = FaceDetector.shared.detectFaceFeatures(in: image)
                    continuation.resume(returning: result)
                }
            }
            
            await MainActor.run {
                hasFace = metadata.hasFace
            }
        }
    }
}
