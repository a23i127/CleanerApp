//
//  Request.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/22.
//

import Foundation
import Alamofire
import UIKit
import PKHUD
class Request {
    func uploadToSeverImage(_ image: UIImage,completion: @escaping (ImageData?) -> Void) {
        guard let url = URL(string: "**"),
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("画像変換に失敗")
            return
        }
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            },
            to: url,
            method: .post
        ).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(ImageData.self, from: data)
                    completion(result)
                } catch {
                    // ここでエラー内容（JSON）も確認
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        print("❌ APIエラー: \(errorResponse.error)")
                        completion(nil)
                    } else {
                        print("❌ デコード失敗: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            case .failure(let error):
                print("❌ 通信エラー: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
struct ErrorResponse: Decodable {
    let error: String
}
