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
    @IBOutlet weak var textView: UITextView!
    var scanModel = ScanAiModel()
    var camera = Camera()
    var fixImageOrientation = FixImageOrientation()
    var imageAnalyzer = ImageAnalyzer()
    var drawBoundingBox = DrawBoundingBox()
    var fixedImage : FixedImageResult?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera.onImageCaptured = { [weak self] image in
            guard let self = self else { return }
            self.showPhotoConfirmationDialog(takenImage: image,onConfirm: { _ in self.fixImageOrientation.fixedOrientationWithMetadata(image: image, imageView: self.cameraView)},onRetake: {self.camera.takePicture()})
        }
    }
    
    @IBAction func action(_ sender: Any) {
        camera.setupCamera(view: view)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        camera.takePicture()
    }
    
    func showPhotoConfirmationDialog(takenImage: UIImage,onConfirm: @escaping (@escaping () -> Void) -> FixedImageResult,onRetake: @escaping () -> Void) {
        let aiModel = scanModel.setAiModel()
        guard let aiModel else{return}
        let alert = UIAlertController(title: "この写真を使いますか？", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "使う", style: .default) { _ in
            self.fixedImage = onConfirm() {
                self.imageAnalyzer.analyze(image: takenImage,model: aiModel) { result in
                    self.drawBoundingBox.drawBoundingBoxes(on: self.cameraView, observations: result, orientation: self.fixedImage!.originalOrientation)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "もう一度撮る", style: .default) { _ in
            onRetake()
        })
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    }

