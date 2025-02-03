//
//  UserDetailView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import SwiftUICore
import UIKit
import SwiftUI

struct UserDetailView: View {
    let user: User
    @StateObject private var imageLoader = ImageLoader()
    @State private var faceMetadata: FaceMetadata?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                } else {
                    ProgressView()
                }
                
                if let metadata = faceMetadata {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(metadata.hasFace ? "Face Detected ✓" : "No Face Detected ✗")
                            .font(.title)
                            .foregroundColor(metadata.hasFace ? .green : .red)
                        
                        if metadata.hasFace {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Facial Features:")
                                    .font(.headline)
                                FeatureRow(label: "Smile", value: metadata.hasSmile)
                                FeatureRow(label: "Left Eye Open", value: !metadata.isLeftEyeClosed)
                                FeatureRow(label: "Right Eye Open", value: !metadata.isRightEyeClosed)
                                Text("Face Angle: \(String(format: "%.1f°", metadata.faceAngle))")
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(user.displayName)
        .task {
            await imageLoader.loadImage(from: user.profileImage)
            guard let image = imageLoader.image else { return }
            
            let metadata = await Task.detached {
                FaceDetector.shared.detectFaceFeatures(in: image)
            }.value
            
            await MainActor.run {
                faceMetadata = metadata
            }
        }
    }
}

struct FeatureRow: View {
    let label: String
    let value: Bool
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: value ? "checkmark" : "xmark")
                .foregroundColor(value ? .green : .red)
        }
    }
}
