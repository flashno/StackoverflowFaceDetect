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
    @State private var faceMetadata: [FaceMetadata] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ImageSection(image: imageLoader.image, faces: faceMetadata)
                
                VStack(alignment: .leading) {
                    Text("Detection Results")
                        .font(.title2.bold())
                    
                    ForEach(faceMetadata) { face in
                        FaceMetadataView(metadata: face)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(user.displayName)
        .task {
            await imageLoader.loadImage(from: user.profileImage)
            if let image = imageLoader.image {
                faceMetadata = FaceDetector.shared.detectFaces(in: image)
            }
        }
    }
}

struct ImageSection: View {
    let image: UIImage?
    let faces: [FaceMetadata]
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        ForEach(faces) { face in
                            Rectangle()
                                .stroke(Color.green, lineWidth: 2)
                                .frame(width: face.bounds.width, height: face.bounds.height)
                                .offset(x: face.bounds.minX, y: face.bounds.minY)
                        }
                    )
                    .background(GeometryReader { proxy in
                        Color.clear
                            .preference(key: ImageSizeKey.self, value: proxy.size)
                    })
            } else {
                ProgressView()
            }
        }
        .frame(maxHeight: 300)
        .padding()
    }
}

struct FaceMetadataView: View {
    let metadata: FaceMetadata
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Face #\(metadata.id)")
                .font(.headline)
            
            Group {
                Text("Bounds: \(formatRect(metadata.bounds))")
                Text("Smile: \(metadata.hasSmile ? "✓" : "✗")")
                Text("Left Eye: \(metadata.isLeftEyeClosed ? "Closed" : "Open")")
                Text("Right Eye: \(metadata.isRightEyeClosed ? "Closed" : "Open")")
                Text(formatAngle(metadata.faceAngle))
            }
            .font(.caption)
            .padding(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatRect(_ rect: CGRect) -> String {
        String(format: "(%.1f, %.1f) [%.1f x %.1f]",
               rect.origin.x, rect.origin.y,
               rect.width, rect.height)
    }
    
    private func formatAngle(_ angle: Double) -> String {
        String(format: "Rotation: %.1f°", angle)
    }
}
