//
//  decodeModel.swift
//  cleanerApp
//
//  Created by 高橋沙久哉 on 2025/05/22.
//

import Foundation
struct DecodableModel: Decodable {
    var message: String
    var savedAs: String
    var status: String
}
