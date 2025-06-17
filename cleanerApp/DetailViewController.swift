//
//  DetailViewController.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/17.
//

import Foundation
import UIKit
class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var data: CaptureData?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let image = UIImage(data: data!.imageData) {
            // image に変換成功！
            imageView.image = image
        } else {
            print("❌ 画像のデコードに失敗しました")
        }
    }
}
