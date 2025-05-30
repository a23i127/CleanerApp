//
//  ViewController.swift
//  RealtimeObjectCounting
//

import UIKit
import AVFoundation
import CoreML
import Vision
//可読性の高いコードを常に意識する
class ViewController: UIViewController, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var footerView: UIView! 
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
        camera.delegate = self
        aiModel = scanModel.setAiModel()
    }
    @IBAction func action(_ sender: Any) {
        camera.setupCamera(view: view)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        camera.takePicture()
    }
    //写真撮った後に呼ばれるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("画像取得失敗")
            return
        }
        //写真の回転の向きを修正
        let fixedImage = fixImageOrientation.fixedOrientationWithMetadata(image: image, imageView: cameraView)
        guard let fixedImage else { return }
        askToUsePhoto(takenImageData: fixedImage)
    }
    //撮った写真を使うかどうかの処理
    func askToUsePhoto(takenImageData: FixedImageResult) {
        let alert = UIAlertController(title: "この写真を使いますか？", message: nil, preferredStyle: .actionSheet)
        self.cameraView.image = takenImageData.image
        alert.addAction(UIAlertAction(title: "使う", style: .default) { _ in
            self.camera.stopCamera()
            self.requestToSever(takenImage: takenImageData.image,aiModel: self.aiModel)
            self.detectImage(imageData: takenImageData,model: self.aiModel)
        })
        alert.addAction(UIAlertAction(title: "もう一度撮る", style: .default) { _ in
            self.cameraView.image = nil
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    //imageをサーバーに送って、pythonサーバーで分析させる
    func requestToSever(takenImage: UIImage,aiModel: VNCoreMLModel) {
        self.request.uploadToSeverImage(takenImage) { [weak self] result in
            guard let self = self else { return }
            self.analysedData = result
        }
    }
    //キャプチャさせたimageに物体検知をさせる処理
    func detectImage(imageData: FixedImageResult,model: VNCoreMLModel) {
        self.imageAnalyzer.analyze(image: imageData.image, model: aiModel) { analyzedResult in
            //検知した物体にboxをつけて描画する
            self.drawBoundingBox.drawBoundingBoxes(
                on: self.cameraView,
                observations: analyzedResult,
                orientation: imageData.originalOrientation
            )
        }
    }
}

