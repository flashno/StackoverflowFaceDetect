//
//  ImageLoader.swift
//  StackoverflowFaceDetect
//
//  Created by Rik Basu on 2/3/25.
//

import Foundation
import UIKit


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String?) async {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            image = cachedImage
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                cache.setObject(downloadedImage, forKey: urlString as NSString)
                await MainActor.run { image = downloadedImage }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
}
