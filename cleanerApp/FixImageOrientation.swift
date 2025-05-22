//
//  FIxImageOrientation.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/21.
//

import Foundation
import UIKit
class FixImageOrientation {
    func fixedOrientationWithMetadata(image: UIImage,imageView: UIImageView) -> FixedImageResult? {
        let orientation: ImageCaptureOrientation
        if image.imageOrientation == .left || image.imageOrientation == .right ||
            image.imageOrientation == .leftMirrored || image.imageOrientation == .rightMirrored {
            orientation = .portrait
        } else {
            orientation = .landscape
        }

        // 本当に描画するサイズ（幅と高さを逆にする必要がある場合がある）
        var drawSize = image.size
        if orientation == .landscape {
            drawSize = CGSize(width: image.size.height, height: image.size.width)
        }

        UIGraphicsBeginImageContextWithOptions(drawSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return FixedImageResult(image: image, originalOrientation: orientation)
        }
        
        // 回転補正
        switch image.imageOrientation {
       
        case .up:
            context.rotate(by: -.pi / 2)
            context.translateBy(x: -image.size.width, y: 0)
        case .down:
            context.rotate(by: .pi)
            context.translateBy(x: -image.size.width, y: -image.size.height)
        default:
            break
        }

        image.draw(in: CGRect(origin: .zero, size: image.size))
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        imageView.image = fixedImage
        UIGraphicsEndImageContext()
        return FixedImageResult(
            image: fixedImage ?? image,
            originalOrientation: orientation
        )
    }
}
