import Cocoa
import FlutterMacOS

func resize(
    image: CGImage,
    ratio: Float
) -> CGImage? {
    let newWidth = Int(Float(image.width) / ratio)
    let newHeight = Int(Float(image.height) / ratio)
    let bitsPerComponent = image.bitsPerComponent // usually 8
    let bytesPerPixel = image.bitsPerPixel / bitsPerComponent // usually 4
    let bytesPerRow = newWidth * bytesPerPixel
    guard let colorSpace = image.colorSpace else { return nil }
    guard let context = CGContext(
        data: nil,
        width: newWidth,
        height: newHeight,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: image.bitmapInfo.rawValue)
    else { return nil }
    // draw image to context (resizing it)
    context.interpolationQuality = .default
    context.draw(
        image,
        in: CGRect(
            x: 0,
            y: 0,
            width: newWidth,
            height: newHeight))
    // extract resulting image from context
    return context.makeImage()
}

struct CapturedScreenArea {
    let buffer: Data
    let width: Int
    let height: Int
    let bitsPerPixel: Int
    let bytesPerPixel: Int
}

func captureScreenArea(
    x: Int,
    y: Int,
    width: Int,
    height: Int
) -> CapturedScreenArea? {
    let rect = CGRect(
        x: x,
        y: y,
        width: width,
        height: height)

    guard var image = CGWindowListCreateImage(
        rect,
//        CGWindowListOption.optionOnScreenOnly,
        CGWindowListOption.optionAll,
        kCGNullWindowID,
        CGWindowImageOption.bestResolution)
    else {
        return nil
    }

    // For example on retina displays, this value could be 2.0 or 3.0
    let screenPixelRatio = Float(image.width) / Float(width);
    if let resizedImage = resize(image: image, ratio: screenPixelRatio) {
        image = resizedImage
    }

    guard let imageData = image.dataProvider?.data else {
        return nil
    }
    guard let imageDataPtr = CFDataGetBytePtr(imageData) else {
        return nil
    }
    return CapturedScreenArea(
        buffer: Data(
            bytes: imageDataPtr,
            count: CFDataGetLength(imageData)),
        width: image.width,
        height: image.height,
        bitsPerPixel: image.bitsPerPixel,
        bytesPerPixel: image.bitsPerPixel / 8)
}

let invalidArgumentsError = FlutterError(
    code: "INVALID_ARGUMENTS",
    message: "Invalid arguments",
    details: nil
)

public class FlutterScreenCapturePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_screen_capture",
            binaryMessenger: registrar.messenger)
        let instance = FlutterScreenCapturePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "captureScreenArea":
            guard let args = call.arguments as? [String: Any] else {
                result(invalidArgumentsError)
                return
            }
            guard let x = args["x"] as? Int else {
                result(invalidArgumentsError)
                return
            }
            guard let y = args["y"] as? Int else {
                result(invalidArgumentsError)
                return
            }
            guard let width = args["width"] as? Int else {
                result(invalidArgumentsError)
                return
            }
            guard let height = args["height"] as? Int else {
                result(invalidArgumentsError)
                return
            }
            if let capturedScreenArea = captureScreenArea(
                x: x,
                y: y,
                width: width,
                height: height) {
                result([
                    "buffer": capturedScreenArea.buffer,
                    "width": capturedScreenArea.width,
                    "height": capturedScreenArea.height,
                    "bitsPerPixel": capturedScreenArea.bitsPerPixel,
                    "bytesPerPixel": capturedScreenArea.bytesPerPixel
                ])
            } else {
                result(nil)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
