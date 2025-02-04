//
//  FaceDetector.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import UIKit
import CoreImage

class FaceDetector : @unchecked Sendable {
    // Singleton instance for shared access
    static let shared = FaceDetector()
    
    // Private properties for face detection
    private let detector: CIDetector?
    private let context: CIContext
    
    // Dedicated serial queue for face detection operations
    private let detectionQueue = DispatchQueue(
        label: "com.app.facedetector",
        qos: .userInitiated
    )
    
    private init() {
        // Create a CIContext with default options
        // We store this as a property to avoid recreating it for each detection
        self.context = CIContext(options: [
            .useSoftwareRenderer: false  // Use GPU when available
        ])
        
        // Configure detector with high accuracy and feature detection
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true
        ]
        
        // Initialize detector with our persistent context
        self.detector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: context,
            options: options
        )
    }

    // Public async interface for face detection
    func detectFaceFeatures(in image: UIImage) async -> FaceMetadata {
        // Perform detection on our dedicated queue using continuation
        await withCheckedContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(returning: .empty)
                return
            }
            detectionQueue.async {
                let result = self.performDetection(on: image)
                continuation.resume(returning: result)
            }
        }
    }
    
    // Private synchronous implementation of face detection
    private func performDetection(on image: UIImage) -> FaceMetadata {
        // Convert UIImage to CGImage for processing
        guard let cgImage = image.cgImage else {
            return FaceMetadata.empty
        }
        
        // Create CIImage and get proper orientation
        let ciImage = CIImage(cgImage: cgImage)
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        // Perform feature detection with proper orientation
        let features = detector?.features(
            in: ciImage,
            options: [
                CIDetectorImageOrientation: orientation.rawValue,
                CIDetectorSmile: true,
                CIDetectorEyeBlink: true
            ]
        ) ?? []
        
        // Extract face features if available
        guard let faceFeature = features.first as? CIFaceFeature else {
            return FaceMetadata.empty
        }
        
        // Return metadata with detected features
        return FaceMetadata(
            hasFace: true,
            hasSmile: faceFeature.hasSmile,
            isLeftEyeClosed: faceFeature.leftEyeClosed,
            isRightEyeClosed: faceFeature.rightEyeClosed,
            faceAngle: Double(faceFeature.faceAngle)
        )
    }
}

// Extension to provide a default empty state
extension FaceMetadata {
    static var empty: FaceMetadata {
        FaceMetadata(
            hasFace: false,
            hasSmile: false,
            isLeftEyeClosed: false,
            isRightEyeClosed: false,
            faceAngle: 0
        )
    }
}
