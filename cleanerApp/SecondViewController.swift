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
    var image: UIImage?
    var textData: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        aiReviewTextView.text = textData
    }
}
