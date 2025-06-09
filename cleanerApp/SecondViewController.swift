//
//  SecondViewController.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/06.
//

import Foundation
import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aiReviewTextView: UITextView!
    //アンラッピングされた値を格納する
    var image: UIImage?
    var analysData: DecodableModel?
    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let analysData = analysData else { return }
        imageView.image = image
        scoreLabel.text = String(analysData.score)
        updateScoreLabel(label: scoreLabel, score: analysData.score)
        aiReviewTextView.text = analysData.advice
    }
    func updateScoreLabel(label: UILabel, score: Int) {
        label.text = "スコア: \(score)"

        switch score {
        case 0..<40:
            label.textColor = .blue
        case 40..<70:
            label.textColor = .black
        case 70...100:
            label.textColor = .red
        default:
            label.textColor = .gray  // スコアが想定外の場合
        }
    }
}
