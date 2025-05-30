//
//  Request.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/22.
//

import Foundation
import Alamofire
import UIKit
class Request {
    func uploadToSeverImage(_ image: UIImage,completion: @escaping (DecodableModel) -> Void) {
        guard let url = URL(string: "http://192.168.100.21:5001/analyze"),
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
                    print(String(data: data, encoding: .utf8))
                    let result = try decoder.decode(DecodableModel.self, from: data)
                    completion(result)
                } catch {
                    // ここでエラー内容（JSON）も確認
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        print("❌ APIエラー: \(errorResponse.error)")
                    } else {
                        print("❌ デコード失敗: \(error.localizedDescription)")
                    }
                }

            case .failure(let error):
                print("❌ 通信エラー: \(error.localizedDescription)")
            }
        }
    }
}
struct ErrorResponse: Decodable {
    let error: String
}
