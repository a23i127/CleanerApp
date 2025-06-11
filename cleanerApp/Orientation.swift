//
//  Orientation.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/06/11.
//

import Foundation
import UIKit
class Orientation {
    func videoRotationAngleForCurrentDeviceOrientation() -> CGFloat {
        switch UIDevice.current.orientation {
        case .portrait:
            return 90
        case .landscapeRight:
            return 0
        case .landscapeLeft:
            return 180
        case .portraitUpsideDown:
            return 270
        default:
            // 不明な場合は portrait にしておく
            return 90
        }
    }
}
