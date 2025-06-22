//
//  decodeImageData.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/22.
//

import Foundation
import UIKit
class DecodeImageData {
    func decodeImage(imageData: Data) -> UIImage {
        guard let image = UIImage(data: imageData) else {
                // アンラップ失敗時に返すプレースホルダー画像（例）
                return UIImage(named: "エラー") ?? UIImage()
            }
            return image
    }
}

