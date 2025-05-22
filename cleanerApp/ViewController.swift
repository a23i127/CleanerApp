//
//  ViewController.swift
//  RealtimeObjectCounting
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIImageView! // カメラのプレビュー表示用（あとで静止画を見せる用に）
    @IBOutlet weak var footerView: UIView! // 結果表示用ビュー
    // 結果表示ラベル
    var scanModel = ScanAiModel()
    var camera = Camera()
    var fixImageOrientation = FixImageOrientation()
    var imageAnalyzer = ImageAnalyzer()
    var drawBoundingBox = DrawBoundingBox()
    var fixedImage : FixedImageResult?
    var aiModel: VNCoreMLModel!
    var request = Request()
    var analysedData: DecodableModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        aiModel = scanModel.setAiModel()
        camera.onImageCaptured = { [weak self] image in
            guard let self = self else { return }
            self.didTakenPicture(takenImage: image,onConfirm: {
                self.fixImageOrientation.fixedOrientationWithMetadata(image: image, imageView: self.cameraView) })
        }
    }
    @IBAction func action(_ sender: Any) {
        camera.setupCamera(view: view)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        camera.takePicture()
    }
    
    func didTakenPicture(takenImage: UIImage,onConfirm: @escaping () -> FixedImageResult?) {
        let alert = UIAlertController(title: "この写真を使いますか？", message: nil, preferredStyle: .actionSheet)
        self.cameraView.image = takenImage
        alert.addAction(UIAlertAction(title: "使う", style: .default) { _ in
            self.startAnalys(onConfirm: onConfirm,aiModel: self.aiModel)
            self.camera.stopCamera()
        })
        alert.addAction(UIAlertAction(title: "もう一度撮る", style: .default) { _ in
            self.cameraView.image = nil
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    
    func startAnalys(onConfirm: @escaping () -> FixedImageResult?,aiModel: VNCoreMLModel) {
        guard let fixed = onConfirm() else { return }
        self.request.uploadToSeverImage(fixed.image) { [weak self] result in
            guard let self = self else { return }
            self.analysedData = result
        }
        self.imageAnalyzer.analyze(image: fixed.image, model: aiModel) { analyzedResult in
            self.drawBoundingBox.drawBoundingBoxes(
                on: self.cameraView,
                observations: analyzedResult,
                orientation: fixed.originalOrientation
            )
        }
    }
}

