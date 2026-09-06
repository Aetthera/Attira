//
//  BackgroundRemovalService.swift
//  Attira
//
//  Created by Alena Belova  on 2026-07-30.
//

import Foundation
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

enum BackgroundRemovalService {
    static func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let inputCGImage = image.cgImage else {
            throw NSError(domain: "BackgroundRemoval", code: 1)
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: inputCGImage)

        try handler.perform([request])

        guard let result = request.results?.first else {
            throw NSError(domain: "BackgroundRemoval", code: 2)
        }

        let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        let ciImage = CIImage(cgImage: inputCGImage)
        let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

        let filter = CIFilter.blendWithMask()
        filter.inputImage = ciImage
        filter.backgroundImage = CIImage.empty()
        filter.maskImage = maskImage

        let context = CIContext()

        guard
            let outputImage = filter.outputImage,
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            throw NSError(domain: "BackgroundRemoval", code: 3)
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
