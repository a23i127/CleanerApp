import Cache
import Foundation

class CacheManager {
    static let shared = CacheManager()
    let storage: Storage<String, captureData>
    
    private init() {
        do {
            storage = try Storage<String, captureData>(
                diskConfig: DiskConfig(name: "MyDiskCache"),
                memoryConfig: MemoryConfig(), fileManager: FileManager.default,
                transformer: TransformerFactory.forCodable(ofType: captureData.self)
            )
        } catch {
            fatalError("Storage creation failed: \(error)")
        }
    }
}
