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
    var analysData: ImageData?
    let decoder = DecodeImageData()
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let analysData = analysData else { return }
        let uiImage = decoder.decodeImage(imageData: analysData.image)
        imageView.image = uiImage
        scoreLabel.text = String(analysData.score)
        updateScoreLabel(label: scoreLabel, score: analysData.score)
        aiReviewTextView.text = analysData.advice
        stateLabel.text = analysData.state
    }
    @IBAction func caputurePhoto(_ sender: Any) {
        CacheManager.shared.caputureData(analysData: self.analysData)
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
