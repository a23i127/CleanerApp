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
    let decodeObj = DecodeImageData()
    func configure(cashData: ImageData) {
        cashImageView.image = decodeObj.decodeImage(imageData: cashData.image)
        cashScoreLabel.text = "スコア: "+String(cashData.score)
    }
}

