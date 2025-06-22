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
struct ImageData: Codable {
    var image: Data
    let state: String
    let score: Int
    let advice: String
}
