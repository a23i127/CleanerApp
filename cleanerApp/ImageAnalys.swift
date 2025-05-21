//
//  Analys.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/21.
//

import Foundation
import UIKit
import Vision

class ImageAnalyzer {
    func analyze(image: UIImage, model: VNCoreMLModel, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        guard let cgImage = image.cgImage else {
            print("画像変換失敗")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                return print("1") }
            print(results)
            DispatchQueue.main.async {
                completion(results)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

