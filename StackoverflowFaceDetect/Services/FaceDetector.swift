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
    private let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil)
    
    func detectFaceFeatures(in image: UIImage) -> FaceMetadata {
        guard let ciImage = CIImage(image: image) else {
            return FaceMetadata(bounds: .zero, hasFace: false,
                              hasSmile: false, isLeftEyeClosed: false,
                              isRightEyeClosed: false, faceAngle: 0)
        }
        
        let features = detector?.features(in: ciImage) ?? []
        guard let faceFeature = features.first as? CIFaceFeature else {
            return FaceMetadata(bounds: .zero, hasFace: false,
                              hasSmile: false, isLeftEyeClosed: false,
                              isRightEyeClosed: false, faceAngle: 0)
        }
        
        return FaceMetadata(
            bounds: faceFeature.bounds,
            hasFace: true,
            hasSmile: faceFeature.hasSmile,
            isLeftEyeClosed: faceFeature.leftEyeClosed,
            isRightEyeClosed: faceFeature.rightEyeClosed,
            faceAngle: Double(faceFeature.faceAngle)
        )
    }
}
