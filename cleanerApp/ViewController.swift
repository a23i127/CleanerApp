//
//  ViewController.swift
//  RealtimeObjectCounting
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    enum ImageCaptureOrientation {
        case portrait
        case landscape
    }

    struct FixedImageResult {
        var image: UIImage
        var originalOrientation: ImageCaptureOrientation
    }
    @IBOutlet weak var cameraView: UIImageView! // カメラのプレビュー表示用（あとで静止画を見せる用に）
    @IBOutlet weak var footerView: UIView! // 結果表示用ビュー
// 結果表示ラベル
    @IBOutlet weak var textView: UITextView!
    private let imagePicker = UIImagePickerController()
    private var yoloModel: VNCoreMLModel!
    private var objectCounter: [String: Int] = [:]
    var result: FixedImageResult? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // ラベルのセットアップ

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
        ])

        // モデルの初期化
        do {
            yoloModel = try VNCoreMLModel(for: yolov8l().model) // クラス名は自分のに合わせてね
        } catch {
            print("モデルの初期化に失敗しました: \(error)")
        }

        // カメラの準備
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
    }

    @IBAction func takePhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let originalImage = info[.originalImage] as? UIImage else { return }
        let fixedImageObj = fixedOrientationWithMetadata(image: originalImage)
        analyze(image: fixedImageObj.image,orientation: fixedImageObj.originalOrientation)
    }

    func analyze(image: UIImage, orientation: ImageCaptureOrientation) {
        guard let cgImage = image.cgImage else { return }
        cameraView.image = image  // 撮った画像を表
               // 既存のバウンディングボックスを削除（再描画時に重ならないように）
        cameraView.subviews.forEach { $0.removeFromSuperview() }

        let request = VNCoreMLRequest(model: yoloModel) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }

            self.objectCounter.removeAll()

            for observation in results {
                guard let label = observation.labels.first?.identifier else { continue }
                self.objectCounter[label, default: 0] += 1

                let boundingBox = observation.boundingBox
                DispatchQueue.main.async {
                    self.drawBoundingBox(on: self.cameraView, box: boundingBox, label: label, orientation: orientation)
                }
            }

            let sorted = self.objectCounter.sorted(by: { $0.1 > $1.1 })
            DispatchQueue.main.async {
                self.textView.text = sorted.map { "\($0.key): \($0.value)個" }.joined(separator: "\n")
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    func drawBoundingBox(on imageView: UIImageView, box: CGRect, label: String,orientation: ImageCaptureOrientation) {
        let imageSize = imageView.bounds.size
        let rect: CGRect
        switch orientation {
        case .portrait:
            rect = CGRect(
                x: box.origin.x * imageSize.width,
                y: (1 - box.origin.y - box.height) * imageSize.height,
                width: box.width * imageSize.width,
                height: box.height * imageSize.height
            )
        case .landscape:
            rect = CGRect(
                x: (1 - box.origin.y - box.height) * imageSize.width,
                y: box.origin.x * imageSize.height,
                width: box.height * imageSize.width,
                height: box.width * imageSize.height
            )
        }
        // 以下はそのままOK
        let boxView = UIView(frame: rect)
        boxView.layer.borderWidth = 2
        boxView.layer.borderColor = UIColor.red.cgColor
        boxView.backgroundColor = UIColor.clear
        imageView.addSubview(boxView)

        let labelView = UILabel(frame: CGRect(x: rect.origin.x, y: rect.origin.y - 20, width: 120, height: 20))
        labelView.text = label
        labelView.textColor = .white
        labelView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        labelView.font = UIFont.boldSystemFont(ofSize: 14)
        imageView.addSubview(labelView)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func fixedOrientationWithMetadata(image: UIImage) -> FixedImageResult {
        // 補正後の画像サイズで判定（Exifには依存しない）
        let isLandscape = image.size.width > image.size.height
        let orientation: ImageCaptureOrientation = isLandscape ? .landscape : .portrait
        // 描画して補正（Exifを除去して .up 向きにする）
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return FixedImageResult(
            image: normalizedImage ?? image,
            originalOrientation: orientation
        )
    }
}

