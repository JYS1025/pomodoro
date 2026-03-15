import Cocoa
import CoreGraphics

let imagePath = "Assets/AppIcon.png" // The original image
guard let image = NSImage(contentsOfFile: imagePath) else {
    print("Cannot read image")
    exit(1)
}

let width = Int(image.size.width)
let height = Int(image.size.height)
let rect = CGRect(x: 0, y: 0, width: width, height: height)

// Force a raw bitmap context with explicit alpha channel
guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    print("Failed to create context")
    exit(1)
}

// Draw the rounded clip path
let radius = CGFloat(width) * 0.225
let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
context.addPath(path)
context.clip()

// Draw the image into the context
guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to get CGImage")
    exit(1)
}
context.draw(cgImage, in: rect)

// Extract the new image and save as PNG
guard let maskedImage = context.makeImage() else {
    print("Failed to extract image")
    exit(1)
}

let newBitmap = NSBitmapImageRep(cgImage: maskedImage)
guard let pngData = newBitmap.representation(using: .png, properties: [:]) else {
    print("Failed to create PNG")
    exit(1)
}

let outPath = "Assets/AppIcon_Transparent.png"
try! pngData.write(to: URL(fileURLWithPath: outPath))
print("Successfully generated true transparent PNG.")
