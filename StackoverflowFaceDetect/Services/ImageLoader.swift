//
//  ImageLoader.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import Foundation
import UIKit
class ImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String?) async {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            await MainActor.run { image = cachedImage }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            
            cache.setObject(image, forKey: urlString as NSString)
            await MainActor.run { self.image = image }
        } catch {
            print("Image load error: \(error)")
        }
    }
}
