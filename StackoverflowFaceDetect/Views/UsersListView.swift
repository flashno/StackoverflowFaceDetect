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
    @State private var faceMetadata: [FaceMetadata] = []
    
    var body: some View {
        HStack {
            // Image loading view remains the same
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                Text("Reputation: \(user.reputation)")
                Text("Faces: \(faceMetadata.count)")
                    .font(.caption)
                    .foregroundColor(faceMetadata.isEmpty ? .red : .green)
            }
            
            Spacer()
            
            FaceStatusIndicator(metadata: faceMetadata)
        }
        .task {
            await imageLoader.loadImage(from: user.profileImage)
            if let image = imageLoader.image {
                faceMetadata = FaceDetector.shared.detectFaces(in: image)
            }
        }
    }
}
struct FaceMetadata: Identifiable {
    let id = UUID()
    let bounds: CGRect
    let hasSmile: Bool
    let isLeftEyeClosed: Bool
    let isRightEyeClosed: Bool
    let faceAngle: Double
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
