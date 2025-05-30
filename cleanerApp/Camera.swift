//
//  Camera.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/20.
//

import Foundation
import AVFoundation
import UIKit

class Camera: NSObject,AVCapturePhotoCaptureDelegate {
    
    var cameraManeger: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    var onImageCaptured: ((UIImage) -> Void)?
    weak var delegate: AVCapturePhotoCaptureDelegate?
    func setupCamera(view: UIView) {
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
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        let portantAngle = 90
        if let cameraPreview = photoOutput.connection(with: .video), cameraPreview.isVideoRotationAngleSupported(CGFloat(portantAngle)) {
            cameraPreview.videoRotationAngle = CGFloat(portantAngle)
        }
        DispatchQueue.global(qos: .background).async {
            self.photoOutput.capturePhoto(with: settings, delegate: self.delegate!)
        }
    }
    
    func stopCamera() {
        self.cameraManeger.stopRunning()
    }
}

