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
class FirtstViewController: UIViewController,PHPickerViewControllerDelegate,CameraViewControllerDelegate {
    var request = Request()
    var analysedData: ImageData?
    var analyser = ImageAnalyzer()
    var scanModel = ScanAiModel()
    var aiModel: VNCoreMLModel!
    var drawBox = DrawBoundingBox()
    var analysedImage: UIImage?
    var imageAnalyzer = ImageAnalyzer()
    var drawBoundingBox = DrawBoundingBox()
    override func viewDidLoad() {
        super.viewDidLoad()
        aiModel = scanModel.setAiModel()
    }
    @IBAction func didTakePictureButton(_ sender: Any) {
        
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
        HUD.show(.labeledProgress(title: "分析中...", subtitle: "画像を送信してAIが解析しています"))
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            HUD.hide()
            return
        }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self else { return }
            if let image = image as? UIImage {
                self.request.uploadToSeverImage(image) { result in
                    guard var result else {
                        HUD.flash(.labeledError(title: "エラー", subtitle: "解析に失敗しました"), delay: 1.5)
                        return
                    }
                    
                    self.imageAnalyzer.analyze(image: image,model: self.aiModel) { analyzedResult in
                        //検知した物体にboxをつけてたimageを格納
                        let drawedImage = self.drawBoundingBox.drawBoundingBoxes(
                            on: image,
                            observations: analyzedResult,
                            orientation: image.imageOrientation
                        )
                        //再度データ化
                        result.image = drawedImage.pngData()!
                        DispatchQueue.main.async {
                            //解析した情報を格納
                            self.analysedData = result
                        }
                        HUD.flash(.success, delay: 1.0)
                        //処理後画面遷移
                        self.performSegue(withIdentifier: "library", sender: nil)
                    }
                    
                }
            }
        }
    }
    func cameraViewControllerDidDismiss(analysedData: ImageData?) {
        
        self.analysedData = analysedData
        self.performSegue(withIdentifier: "library", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCamera" {
            if let cameraViewController = segue.destination as? ViewController {
                cameraViewController.delegate = self
            }
        }
        if segue.identifier == "library" {
            if let reviewViewController = segue.destination as? SecondViewController {
                reviewViewController.analysData = self.analysedData
            }
        }
    }
}

