//
//  ViewController.swift
//  RealtimeObjectCounting
//

import UIKit
import AVFoundation
import CoreML
import Vision
import PKHUD
//可読性の高いコードを常に意識する
class ViewController: UIViewController, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var gotoViewButtun: UIButton!
    var scanModel = ScanAiModel()
    var camera = Camera()
    var fixImageOrientation = FixImageOrientation()
    var imageAnalyzer = ImageAnalyzer()
    var drawBoundingBox = DrawBoundingBox()
    var fixedImage : FixedImageResult?
    var aiModel: VNCoreMLModel!
    var request = Request()
    var analysedData: DecodableModel?
    var analysedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.delegate = self
        aiModel = scanModel.setAiModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        camera.setupCamera(view: view)
    }
    @IBAction func takePhoto(_ sender: Any) {
        camera.takePicture()
    }
    @IBAction func seni(_ sender: Any) {
        self.performSegue(withIdentifier: "GoReview", sender: nil)
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
            //キャプチャしたimageを物体検知させる処理
            self.imageAnalyzer.analyze(image: takenImageData.image,model: self.aiModel) { analyzedResult in
                //検知した物体にboxをつけてたimageを格納
                self.analysedImage = self.drawBoundingBox.drawBoundingBoxes(
                    on: self.cameraView.image!,
                    observations: analyzedResult,
                    orientation: takenImageData.image.imageOrientation
                )
            }
        })
        alert.addAction(UIAlertAction(title: "もう一度撮る", style: .default) { _ in
            self.cameraView.image = nil
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    //imageをサーバーに送って、pythonサーバーでAIに分析させる
    func requestToSever(takenImage: UIImage,aiModel: VNCoreMLModel) {
        HUD.show(.labeledProgress(title: "分析中...", subtitle: "画像を送信してAIが解析しています"))
        self.request.uploadToSeverImage(takenImage) { [weak self] result in
            guard let self = self else { return }
            guard let result else {
                HUD.flash(.labeledError(title: "エラー", subtitle: "解析に失敗しました"), delay: 1.5)
                return
            }
            //解析させた情報を格納
            DispatchQueue.main.async {
                self.analysedData = result
            }
            HUD.flash(.success, delay: 1.0)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoReview" {
            if let reviewViewController = segue.destination as? SecondViewController {
                reviewViewController.image = self.analysedImage
                reviewViewController.textData = self.analysedData?.advice
            }
        }
    }
}

