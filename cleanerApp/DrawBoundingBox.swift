import UIKit
import Vision

class DrawBoundingBox {
    func drawBoundingBoxes(
        on image: UIImage,
        observations: [VNRecognizedObjectObservation],
        orientation: UIImage.Orientation
    ) -> UIImage {
        let imageSize = image.size
        // CoreGraphics context で描画する
        UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: imageSize))
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }
        
        for observation in observations {
            guard let label = observation.labels.first?.identifier else { continue }
            
            let box = observation.boundingBox
            let rect: CGRect
            
            switch orientation {
            case .up, .down, .upMirrored, .downMirrored:
                // 縦向き（portrait相当）
                rect = CGRect(
                    x: box.origin.x * imageSize.width,
                    y: (1 - box.origin.y - box.height) * imageSize.height,
                    width: box.width * imageSize.width,
                    height: box.height * imageSize.height
                )
                
            case .left, .right, .leftMirrored, .rightMirrored:
                // 横向き（landscape相当）
                rect = CGRect(
                    x: (1 - box.origin.y - box.height) * imageSize.width,
                    y: box.origin.x * imageSize.height,
                    width: box.height * imageSize.width,
                    height: box.width * imageSize.height
                )
                
            @unknown default:
                // 万が一新しい case が来た時は portrait扱いで fallback
                rect = CGRect(
                    x: box.origin.x * imageSize.width,
                    y: (1 - box.origin.y - box.height) * imageSize.height,
                    width: box.width * imageSize.width,
                    height: box.height * imageSize.height
                )
            }
            // ボックス線を描く
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(6.0)
            context.stroke(rect)
            
            // ラベルの背景
            let labelRect = CGRect(x: rect.origin.x, y: rect.origin.y - 20, width: 120, height: 20)
            context.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
            context.fill(labelRect)
            
            // ラベルのテキスト描画
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            label.draw(in: labelRect.insetBy(dx: 5, dy: 2), withAttributes: textAttributes)
        }
        
        // 出来上がった画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}
extension UIView {
    //UIimageViewをUIImageとして取得する
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
