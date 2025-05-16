//
//  ViewController.swift
//  RealtimeObjectCounting
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    enum ImageCaptureOrientation {
        case portrait
        case landscape
    }

    struct FixedImageResult {
        var image: UIImage
        var originalOrientation: ImageCaptureOrientation
    }
        var cameraManeger: AVCaptureSession!
        var photoOutput: AVCapturePhotoOutput!
        var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var cameraView: UIImageView! // カメラのプレビュー表示用（あとで静止画を見せる用に）
    @IBOutlet weak var footerView: UIView! // 結果表示用ビュー
// 結果表示ラベル
    @IBOutlet weak var textView: UITextView!
    private let imagePicker = UIImagePickerController()
    private var aiModel: VNCoreMLModel!
    private var objectCounter: [String: Int] = [:]
    var result: FixedImageResult? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAiModel()
    }
    func setAiModel() {
        do {
            aiModel = try VNCoreMLModel(for: yolov8l().model)
        } catch {
            print("モデルの初期化に失敗しました: \(error)")
        }
    }
    @IBAction func action(_ sender: Any) {
        setupCamera()
    }
    func setupCamera() {
        cameraManeger = AVCaptureSession()
        cameraManeger.sessionPreset = .photo
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let inputedCamera = try? AVCaptureDeviceInput(device: camera),
              cameraManeger.canAddInput(inputedCamera) else {
            print("カメラのセットアップ失敗")
            return
        }
        cameraManeger.addInput(inputedCamera)
        
        photoOutput = AVCapturePhotoOutput()
        guard cameraManeger.canAddOutput(photoOutput) else { return }
        cameraManeger.addOutput(photoOutput)
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraManeger)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.frame = view.bounds
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
        
        let portantAngle = 90
        if let cameraPreview = cameraPreviewLayer.connection, cameraPreview.isVideoRotationAngleSupported(CGFloat(portantAngle)) {
            cameraPreview.videoRotationAngle = CGFloat(portantAngle)
        }
        DispatchQueue.global(qos: .background).async {
            self.cameraManeger.startRunning()
        }
    }
    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        if let conn = photoOutput.connection(with: .video), conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }
        DispatchQueue.global(qos: .background).async {
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                print("画像取得失敗")
                return
            }
            // 表示 or 保存
        showPhotoConfirmationDialog(takenImage: image)
        }
    func showPhotoConfirmationDialog(takenImage: UIImage) {
        let alert = UIAlertController(title: "この写真を使いますか？", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "使う", style: .default) { _ in
            let fixedImageObj = self.fixedOrientationWithMetadata(image: takenImage)
            self.analyze(image: fixedImageObj.image,orientation: fixedImageObj.originalOrientation)
        })

        alert.addAction(UIAlertAction(title: "もう一度撮る", style: .default) { _ in
            
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }
    func analyze(image: UIImage, orientation: ImageCaptureOrientation) {
        guard let cgImage = image.cgImage else { return print(1)}
        cameraView.image = image  // 撮った画像を表
               // 既存のバウンディングボックスを削除（再描画時に重ならないように）
        cameraView.subviews.forEach { $0.removeFromSuperview() }

        let request = VNCoreMLRequest(model: aiModel) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return}

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
                print(sorted)
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
        let orientation: ImageCaptureOrientation
        if image.imageOrientation == .left || image.imageOrientation == .right ||
            image.imageOrientation == .leftMirrored || image.imageOrientation == .rightMirrored {
            orientation = .portrait
        } else {
            orientation = .landscape
        }

        // 本当に描画するサイズ（幅と高さを逆にする必要がある場合がある）
        var drawSize = image.size
        if orientation == .landscape {
            drawSize = CGSize(width: image.size.height, height: image.size.width)
        }

        UIGraphicsBeginImageContextWithOptions(drawSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return FixedImageResult(image: image, originalOrientation: orientation)
        }
        
        // 回転補正
        switch image.imageOrientation {
       
        case .up:
            context.rotate(by: -.pi / 2)
            context.translateBy(x: -image.size.width, y: 0)
        case .down:
            context.rotate(by: .pi)
            context.translateBy(x: -image.size.width, y: -image.size.height)
        default:
            break
        }

        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print(image.size)
        print(normalizedImage!.size)
        return FixedImageResult(
            image: normalizedImage ?? image,
            originalOrientation: orientation
        )
    }
}
extension UIImage {
 
    func fixedOrientation() -> UIImage? {
 
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
 
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
 
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
 
        var transform: CGAffineTransform = CGAffineTransform.identity
 
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
 
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .up, .down, .left, .right:
            break
        }
 
        ctx.concatenate(transform)
 
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
 
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
