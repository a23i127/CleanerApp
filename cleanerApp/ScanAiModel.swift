//
//  ScanAiModel.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/21.
//

import Foundation
import CoreML
import Vision
class ScanAiModel {
    private var aiModel: VNCoreMLModel?

    func setAiModel() -> VNCoreMLModel? {
        do {
            aiModel = try VNCoreMLModel(for: yolov8l().model)
            return aiModel
        } catch {
            print("モデルの初期化に失敗しました: \(error)")
            return nil
        }
    }
}
