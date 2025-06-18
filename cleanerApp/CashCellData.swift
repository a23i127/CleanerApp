//
//  CashCellData.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/17.
//

import Foundation
import UIKit
class CashCellData: UITableViewCell {
    @IBOutlet weak var cashImageView: UIImageView!
    @IBOutlet weak var cashScoreLabel: UILabel!
    func configure(cashData: CaptureData) {
        if let image = UIImage(data: cashData.imageData) {
            // image に変換成功！
            cashImageView.image = image
        } else {
            print("❌ 画像のデコードに失敗しました")
        }
        cashScoreLabel.text = "スコア: "+String(cashData.score)
    }
}

