import UIKit
import CoreBluetooth

class Util {
    static let Floyd16x16: [[Int]] = [
        [0, 128, 32, 160, 8, 136, 40, 168, 2, 130, 34, 162, 10, 138, 42, 170],
        [192, 64, 224, 96, 200, 72, 232, 104, 194, 66, 226, 98, 202, 74, 234, 106],
        [48, 176, 16, 144, 56, 184, 24, 152, 50, 178, 18, 146, 58, 186, 26, 154],
        [240, 112, 208, 80, 248, 120, 216, 88, 242, 114, 210, 82, 250, 122, 218, 90],
        [12, 140, 44, 172, 4, 132, 36, 164, 14, 142, 46, 174, 6, 134, 38, 166],
        [204, 76, 236, 108, 196, 68, 228, 100, 206, 78, 238, 110, 198, 70, 230, 102],
        [60, 188, 28, 156, 52, 180, 20, 148, 62, 190, 30, 158, 54, 182, 22, 150],
        [252, 124, 220, 92, 244, 116, 212, 84, 254, 126, 222, 94, 246, 118, 214, 86],
        [3, 131, 35, 163, 11, 139, 43, 171, 1, 129, 33, 161, 9, 137, 41, 169],
        [195, 67, 227, 99, 203, 75, 235, 107, 193, 65, 225, 97, 201, 73, 233, 105],
        [51, 179, 19, 147, 59, 187, 27, 155, 49, 177, 17, 145, 57, 185, 25, 153],
        [243, 115, 211, 83, 251, 123, 219, 91, 241, 113, 209, 81, 249, 121, 217, 89],
        [15, 143, 47, 175, 7, 135, 39, 167, 13, 141, 45, 173, 5, 133, 37, 165],
        [207, 79, 239, 111, 199, 71, 231, 103, 205, 77, 237, 109, 197, 69, 229, 101],
        [63, 191, 31, 159, 55, 183, 23, 151, 61, 189, 29, 157, 53, 181, 21, 149],
        [254, 127, 223, 95, 247, 119, 215, 87, 253, 125, 221, 93, 245, 117, 213, 85]
    ]
    
    static let p0: [Int] = [0, 128]
    static let p1: [Int] = [0, 64]
    static let p2: [Int] = [0, 32]
    static let p3: [Int] = [0, 16]
    static let p4: [Int] = [0, 8]
    static let p5: [Int] = [0, 4]
    static let p6: [Int] = [0, 2]
    
    static func toGrayscale(bmpOriginal: UIImage) -> UIImage? {
        let width = Int(bmpOriginal.size.width) * 2
        let height = Int(bmpOriginal.size.height) * 2
        
        // Create a grayscale bitmap context
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        // Draw original image into the context with grayscale filter
        guard let cgImage = bmpOriginal.cgImage else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create a new UIImage from the context
        guard let newCGImage = context.makeImage() else {
            return nil
        }
        let bmpGrayscale = UIImage(cgImage: newCGImage)
        
        return bmpGrayscale
    }
    
    static func bitmapToBWPix(mBitmap: UIImage)  -> [Int]?{
        let grayBitmap = toGrayscale(bmpOriginal: mBitmap)
        
        guard let cgImage = grayBitmap?.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        
        var pixels = [Int](repeating: 0, count: width * height)
        var data = [Int](repeating: 0, count: width * height)
        
        
        guard let ciImage = CIImage(image: grayBitmap!) else { return nil }
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CIColorControls")
        filter!.setValue(ciImage, forKey: kCIInputImageKey)
        filter!.setValue(0.0, forKey: kCIInputSaturationKey)
        let outputCIImage = filter!.outputImage
        let bwImage = context.createCGImage(outputCIImage!, from: outputCIImage!.extent)
        
        let uibwImage = UIImage(cgImage: bwImage!)
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: &pixels,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 16,
                                      bytesPerRow: width * 8,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create bitmap context")
        }

        // Draw the image into the context
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(uibwImage.cgImage!, in: rect)
                
        formatKDither16x16(orgpixels: pixels, xsize: width, ysize: height, despixels: &data)
        
        return data
        
    }

    static func formatKDither16x16(orgpixels: [Int], xsize: Int, ysize: Int, despixels: inout [Int]) {
        var k = 0
        for y in 0..<ysize {
            for x in 0..<xsize {
                if (orgpixels[k] & 0xFF) > Floyd16x16[x & 0xF][y & 0xF] {
                    despixels[k] = 0
                } else {
                    despixels[k] = 1
                }
                k += 1
            }
        }
    }
    
    static func pixToEscRastBitImageCmd(src: [Int]) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: src.count / 8)
        var i = 0
        var k = 0
        
        while i < data.count {
            
            let pp0 = p0[Int(src[k])]
            let pp1 = p1[Int(src[k + 1])]
            let pp2 = p2[Int(src[k + 2])]
            let pp3 = p3[Int(src[k + 3])]
            let pp4 = p4[Int(src[k + 4])]
            let pp5 = p5[Int(src[k + 5])]
            let pp6 = p6[Int(src[k + 6])]
            
            data[i] = UInt8(truncatingIfNeeded: (pp0 + pp1 + pp2 + pp3 + pp4  + pp5 + pp6 + Int(src[k + 7])))
            k += 8
            i += 1
        }
        
        return data
    }
}
