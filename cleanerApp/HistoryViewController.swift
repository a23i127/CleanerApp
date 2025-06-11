//
//  History.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/11.
//

import Foundation
import UIKit
class HistoryViewController: UIViewController, displayDidFinish {
    let secondViewController = SecondViewController()
    var image: UIImage?
    var analysData: DecodableModel?
    var captureData: [CaptureData]?
    override func viewDidLoad() {
        super.viewDidLoad()
        secondViewController.delegate = self
    }
    func caputureData(image: UIImage?, analysData: DecodableModel?) {
        let imageData = image!.pngData()!
        let newCapture = CaptureData(imageData: imageData, score: analysData!.score,text: analysData!.advice)
        captureData?.append(newCapture)
        CacheManager.shared.saveCaptureData(captureData!, forKey: "captureData")
    }
}
