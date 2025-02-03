//
//  FaceMetadata.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//


struct FaceMetadata {
    let hasFace: Bool
    let hasSmile: Bool
    let isLeftEyeClosed: Bool
    let isRightEyeClosed: Bool
    let faceAngle: Double
    
    // For debugging purposes
    var description: String {
        """
        Face Detected: \(hasFace)
        Smile: \(hasSmile)
        Left Eye Closed: \(isLeftEyeClosed)
        Right Eye Closed: \(isRightEyeClosed)
        Face Angle: \(String(format: "%.1f°", faceAngle))
        """
    }
}
