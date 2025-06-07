//
//  FirtstViewController.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/07.
//

import Foundation
import UIKit
import PhotosUI
import PKHUD
import Vision
class FirtstViewController: UIViewController,PHPickerViewControllerDelegate {
    var request = Request()
    var analysedData: DecodableModel?
    var analyser = ImageAnalyzer()
    var scanModel = ScanAiModel()
    var aiModel: VNCoreMLModel!
    var drawBox = DrawBoundingBox()
    var analysedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        aiModel = scanModel.setAiModel()
    }
    @IBAction func didTapSelectLibralyButton(_ sender: Any) {
        presentPhotoPicker()
    }
    func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1  // 1枚だけ選択
        config.filter = .images    // 画像のみ
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    //ライブラリから選択したらデリゲートで呼ばれる
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self else { return }
            if let image = image as? UIImage {
                self.request.uploadToSeverImage(image) { result in
                    guard let result else {
                        HUD.flash(.labeledError(title: "エラー", subtitle: "解析に失敗しました"), delay: 1.5)
                        return
                    }
                    //解析させた情報を格納
                    DispatchQueue.main.async {
                        self.analysedData = result
                        self.performSegue(withIdentifier: "library", sender: nil)
                    }
                    HUD.flash(.success, delay: 1.0)
                }
                self.analyser.analyze(image: image,model: self.aiModel) { analyzedResult in
                    //検知した物体にboxをつけてたimageを格納
                    self.analysedImage = self.drawBox.drawBoundingBoxes(
                        on: image,
                        observations: analyzedResult,
                        orientation: image.imageOrientation
                    )
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "library" {
            if let reviewViewController = segue.destination as? SecondViewController {
                reviewViewController.image = self.analysedImage
                reviewViewController.textData = self.analysedData?.advice
            }
        }
    }
}

