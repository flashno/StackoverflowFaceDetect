//
//  UserDetailView.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import UIKit
import SwiftUI

struct UserDetailView: View {
    let user: User
    @ObservedObject var viewModel: UsersViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageData = viewModel.userImagesData[user.id] {
                    // Profile Image Section
                    Image(uiImage: imageData.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                    
                    // Face Detection Results Section
                    VStack(alignment: .leading, spacing: 10) {
                        // Main Face Detection Status
                        Text(imageData.faceMetadata.hasFace ? "Face Detected ✓" : "No Face Detected ✗")
                            .font(.title)
                            .foregroundColor(imageData.faceMetadata.hasFace ? .green : .red)
                        
                        if imageData.faceMetadata.hasFace {
                            Divider()
                            
                            FacialFeaturesView(metadata: imageData.faceMetadata)

                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                } else {
                    // Loading State
                    ProgressView()
                        .padding()
                }
            }
        }
        .navigationTitle(user.displayName)
        .background(Color(.systemGroupedBackground))
    }
}

// Keep the existing FeatureRow view
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
        .font(.subheadline)
    }
}

struct FacialFeaturesView: View {
    let metadata: FaceMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Facial Features:")
                .font(.headline)
                
            FeatureRow(label: "Smile", value: metadata.hasSmile)
            FeatureRow(label: "Left Eye Open", value: !metadata.isLeftEyeClosed)
            FeatureRow(label: "Right Eye Open", value: !metadata.isRightEyeClosed)
            
            Text("Face Angle: \(String(format: "%.1f°", metadata.faceAngle))")
                .font(.subheadline)
        }
    }
}
