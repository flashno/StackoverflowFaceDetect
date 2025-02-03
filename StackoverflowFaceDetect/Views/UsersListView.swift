//
//  UsersListView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import SwiftUICore
import SwiftUI


struct UsersListView: View {
    @StateObject private var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    List(viewModel.users) { user in
                        NavigationLink {
                            UserDetailView(user: user)
                        } label: {
                            UserRowView(user: user)
                        }
                    }
                }
            }
            .navigationTitle("Top Users")
        }
        .task { await viewModel.fetchUsers() }
    }
}

struct UserRowView: View {
    let user: User
    @StateObject private var imageLoader = ImageLoader()
    @State private var hasFace = false
    
    var body: some View {
        HStack {
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
        .task {
            await imageLoader.loadImage(from: user.profileImage)
            if let image = imageLoader.image {
                let metadata = FaceDetector.shared.detectFaceFeatures(in: image)
                hasFace = metadata.hasFace
            }
        }
    }
}
struct FaceMetadata: Identifiable {
    let id = UUID()
    let bounds: CGRect  // Keep bounds for debugging
    let hasFace: Bool
    let hasSmile: Bool
    let isLeftEyeClosed: Bool
    let isRightEyeClosed: Bool
    let faceAngle: Double
    
    // Helper for debug printing
    var boundsDescription: String {
        String(format: "(x: %.1f, y: %.1f, w: %.1f, h: %.1f)",
              bounds.origin.x, bounds.origin.y,
              bounds.width, bounds.height)
    }
}
struct FaceStatusIndicator: View {
    let metadata: [FaceMetadata]
    
    var body: some View {
        VStack {
            Image(systemName: metadata.isEmpty ? "xmark.circle" : "checkmark.circle.fill")
                .foregroundColor(metadata.isEmpty ? .red : .green)
            Text("\(metadata.count)")
                .font(.caption2)
        }
    }
}
