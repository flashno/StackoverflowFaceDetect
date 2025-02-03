//
//  FaceDetector.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import UIKit
import CoreImage
class FaceDetector {
    static let shared = FaceDetector()
    private let detector: CIDetector?
    
    init() {
        let context = CIContext() // Explicit context creation
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true
        ]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options)
    }
    
    func detectFaceFeatures(in image: UIImage) -> FaceMetadata {
        guard let cgImage = image.cgImage else {
            return FaceMetadata(hasFace: false, hasSmile: false,
                              isLeftEyeClosed: false, isRightEyeClosed: false, faceAngle: 0)
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        let features = detector?.features(
            in: ciImage,
            options: [
                CIDetectorImageOrientation: orientation.rawValue,
                CIDetectorSmile: true,
                CIDetectorEyeBlink: true
            ]
        ) ?? []
        
        guard let faceFeature = features.first as? CIFaceFeature else {
            return FaceMetadata(hasFace: false, hasSmile: false,
                              isLeftEyeClosed: false, isRightEyeClosed: false, faceAngle: 0)
        }
        
        return FaceMetadata(
            hasFace: true,
            hasSmile: faceFeature.hasSmile,
            isLeftEyeClosed: faceFeature.leftEyeClosed,
            isRightEyeClosed: faceFeature.rightEyeClosed,
            faceAngle: Double(faceFeature.faceAngle)
        )
    }
}

