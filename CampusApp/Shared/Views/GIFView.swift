//
//  GIFView.swift
//  NCSU-Welcome Pack
//
//  Created by Jared Tamulynas on 10/27/25.
//

import SwiftUI
import UIKit
import ImageIO

struct GIFView: UIViewRepresentable {
    let name: String
    var speed: Double = 1.0
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        if let path = Bundle.main.path(forResource: name, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let source = CGImageSourceCreateWithData(data as CFData, nil) {
            
            var images: [UIImage] = []
            var totalDuration: Double = 0
            let count = CGImageSourceGetCount(source)
            
            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                    
                    if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                       let frameDuration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                        totalDuration += frameDuration
                    } else {
                        totalDuration += 0.1
                    }
                }
            }
            
            imageView.animationImages = images
            imageView.animationDuration = totalDuration * speed
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
}
