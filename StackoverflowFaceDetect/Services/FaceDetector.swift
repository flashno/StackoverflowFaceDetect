//
//  FaceDetector.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import CoreImage
import UIKit


class FaceDetector {
    static let shared = FaceDetector()
    private let detector: CIDetector?
    
    init() {
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true,
            CIDetectorNumberOfAngles: 3
        ]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
    }
    
    func detectFaces(in image: UIImage) -> [FaceMetadata] {
        guard let ciImage = CIImage(image: image) else { return [] }
        
        // Convert UIImage orientation to CGImagePropertyOrientation
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        
        let features = detector?.features(in: ciImage, options: [
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true,
            CIDetectorImageOrientation: cgOrientation.rawValue // Now using correct raw value
        ]) ?? []
        
        return features.compactMap { $0 as? CIFaceFeature }.map {
            FaceMetadata(
                bounds: $0.bounds,
                hasSmile: $0.hasSmile,
                isLeftEyeClosed: $0.leftEyeClosed,
                isRightEyeClosed: $0.rightEyeClosed,
                faceAngle: Double($0.faceAngle)
            )
        }
    }
}
