import Cache
import UIKit
import Foundation

class CacheManager {
    //staticで、classに直接紐付けた。
    static let shared = CacheManager()
    var captureData: [ImageData] = []
    let storage: Storage<String, [ImageData]>
    //privateにより、インスタンス化はアプリで１度のみしかされない！
    private init() {
        do {
            storage = try Storage<String, [ImageData]>(
                diskConfig: DiskConfig(name: "MyDiskCache"),
                memoryConfig: MemoryConfig(), fileManager: FileManager.default,
                transformer: TransformerFactory.forCodable(ofType: [ImageData].self)
            )
        } catch {
            fatalError("Storage creation failed: \(error)")
        }
    }
    
    func caputureData( analysData: ImageData?) {
        let newCapture = ImageData(image: analysData!.image, state: analysData!.state, score: analysData!.score,advice: analysData!.advice)
        captureData.append(newCapture)
        saveCaptureData(captureData, forKey: "captureData")
    }
    // MARK: - 保存
    func saveCaptureData(_ data: [ImageData], forKey key: String) {
        do {
            try storage.setObject(data, forKey: key)
            print("✅ キャッシュ保存成功: \(key)")
        } catch {
            print("❌ キャッシュ保存失敗: \(error)")
        }
    }
    
    // MARK: - 取得
    func loadCaptureData(forKey key: String) -> [ImageData]? {
        do {
            let data = try storage.object(forKey: key)
            print("✅ キャッシュ取得成功: \(key)")
            return data
        } catch {
            print("⚠️ キャッシュ取得失敗（存在しない可能性あり）: \(error)")
            return nil
        }
    }
    
    // MARK: - 削除
    func removeCaptureData(forKey key: String) {
        do {
            try storage.removeObject(forKey: key)
            print("✅ キャッシュ削除成功: \(key)")
        } catch {
            print("⚠️ キャッシュ削除失敗: \(error)")
        }
    }
    // MARK: - 全削除
    func clearCache() {
        do {
            try storage.removeAll()
            print("✅ キャッシュ全削除成功")
        } catch {
            print("⚠️ キャッシュ全削除失敗: \(error)")
        }
    }
}
