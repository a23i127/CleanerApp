import UIKit
import Vision

class DrawBoundingBox {
    func drawBoundingBoxes(
        on imageView: UIImageView,
        observations: [VNRecognizedObjectObservation],
        orientation: ImageCaptureOrientation
    ) {
        var counter: [String: Int] = [:]
        let imageSize = imageView.bounds.size

        imageView.subviews.forEach { $0.removeFromSuperview() } // 既存を消す

        for observation in observations {
            guard let label = observation.labels.first?.identifier else { continue }
            counter[label, default: 0] += 1

            let box = observation.boundingBox
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

            // ボックス表示
            let boxView = UIView(frame: rect)
            boxView.layer.borderWidth = 2
            boxView.layer.borderColor = UIColor.red.cgColor
            boxView.backgroundColor = .clear
            imageView.addSubview(boxView)

            // ラベル表示
            let labelView = UILabel(frame: CGRect(x: rect.origin.x, y: rect.origin.y - 20, width: 120, height: 20))
            labelView.text = label
            labelView.textColor = .white
            labelView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            labelView.font = UIFont.boldSystemFont(ofSize: 14)
            imageView.addSubview(labelView)
        }

        // 必要なら、counter を戻り値にして ViewController で使ってもよい
        print("ラベル数:", counter)
    }
}

