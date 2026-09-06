//
//  ImageStore.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-28.
//

import Foundation
import UIKit

enum ImageStore {
    static func saveImage(_ image: UIImage) throws -> String {
        let fileName = UUID().uuidString + ".jpg"
        let url = documentsDirectory.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw ImageStoreError.encodingFailed
        }

        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func loadImage(from fileName: String?) -> UIImage? {
        guard let fileName else { return nil }

        let url = documentsDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

enum ImageStoreError: Error {
    case encodingFailed
}
