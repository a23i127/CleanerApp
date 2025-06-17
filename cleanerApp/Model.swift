//
//  MOdel.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/21.
//

import Foundation
import UIKit
struct FixedImageResult {
    let image: UIImage
    let originalOrientation: ImageCaptureOrientation
}
enum ImageCaptureOrientation {
    case portrait
    case landscape
}
struct CaptureData: Codable {
    let imageData: Data
    let score: Int
    let text: String
}
