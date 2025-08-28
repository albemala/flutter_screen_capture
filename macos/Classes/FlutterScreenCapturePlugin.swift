import Cocoa
import FlutterMacOS

private extension CGImage {
    func resized(by ratio: Float) -> CGImage? {
        let newWidth = Int(Float(width) / ratio)
        let newHeight = Int(Float(height) / ratio)
        
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        let bytesPerRow = newWidth * bytesPerPixel
        
        guard let colorSpace = colorSpace else {
            return nil
        }
        
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.interpolationQuality = .default
        context.draw(self, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        return context.makeImage()
    }
}

private struct CapturedScreenArea {
    let buffer: Data
    let width: Int
    let height: Int
    let bitsPerPixel: Int
    let bytesPerPixel: Int
}

private func captureScreenArea(x: Int, y: Int, width: Int, height: Int) -> CapturedScreenArea? {
    let rect = CGRect(x: x, y: y, width: width, height: height)
    
    guard var image = CGWindowListCreateImage(
        rect,
        .optionAll,
        kCGNullWindowID,
        .bestResolution
    ) else {
        return nil
    }
    
    let screenPixelRatio = Float(image.width) / Float(width)
    if let resizedImage = image.resized(by: screenPixelRatio) {
        image = resizedImage
    }
    
    guard let imageData = image.dataProvider?.data as? Data else {
        return nil
    }
    
    return CapturedScreenArea(
        buffer: imageData,
        width: image.width,
        height: image.height,
        bitsPerPixel: image.bitsPerPixel,
        bytesPerPixel: image.bitsPerPixel / 8
    )
}

private let invalidArgumentsError = FlutterError(
    code: "INVALID_ARGUMENTS",
    message: "Invalid arguments",
    details: nil
)

private struct CaptureAreaArgs {
    let x, y, width, height: Int
    
    init?(from call: FlutterMethodCall) {
        guard
            let args = call.arguments as? [String: Any],
            let x = args["x"] as? Int,
            let y = args["y"] as? Int,
            let width = args["width"] as? Int,
            let height = args["height"] as? Int
        else {
            return nil
        }
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public class FlutterScreenCapturePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_screen_capture",
            binaryMessenger: registrar.messenger
        )
        let instance = FlutterScreenCapturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "captureScreenArea":
            handleCaptureScreenArea(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleCaptureScreenArea(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = CaptureAreaArgs(from: call) else {
            result(invalidArgumentsError)
            return
        }
        
        if let capturedArea = captureScreenArea(
            x: args.x,
            y: args.y,
            width: args.width,
            height: args.height
        ) {
            result([
                "buffer": capturedArea.buffer,
                "width": capturedArea.width,
                "height": capturedArea.height,
                "bitsPerPixel": capturedArea.bitsPerPixel,
                "bytesPerPixel": capturedArea.bytesPerPixel,
            ])
        } else {
            result(nil)
        }
    }
}
