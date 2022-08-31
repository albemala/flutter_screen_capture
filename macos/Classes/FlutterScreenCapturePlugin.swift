import Cocoa
import FlutterMacOS

struct CapturedScreenArea {
    let buffer: [UInt8]
    let width: Int
    let height: Int
    let bitsPerPixel: Int
    let bytesPerPixel: Int

    func asDictionary() -> [String: Any] {
        [
            "buffer": buffer,
            "width": width,
            "height": height,
            "bitsPerPixel": bitsPerPixel,
            "bytesPerPixel": bytesPerPixel
        ]
    }
}

func captureScreenArea(
    x: Int,
    y: Int,
    width: Int,
    height: Int
) -> CapturedScreenArea? {

    let displayID = CGMainDisplayID()
    let rect = CGRect(
        x: CGFloat(x),
        y: CGFloat(y),
        width: CGFloat(width),
        height: CGFloat(height)
    )
//    guard let image = CGWindowListCreateImage(
//        rect,
//        CGWindowListOption.optionAll,
//        kCGNullWindowID,
//        CGWindowImageOption.nominalResolution
//    ) else {
//        return nil
//    }
    guard let image = CGDisplayCreateImage(displayID, rect: rect) else {
        return nil
    }
    guard let imageData = image.dataProvider?.data else {
        return nil
    }
    guard let imageDataPtr = CFDataGetBytePtr(imageData) else {
        return nil
    }
    let buffer = UnsafeBufferPointer<UInt8>(
        start: imageDataPtr,
        count: CFDataGetLength(imageData)
    )
    // buffer is an array of bytes, where each 4 bytes represents a color with channels BGRA
    // transform the buffer into an array of colors with channels RGBA
    let correctedBuffer = buffer.enumerated().map { (index, byte) -> UInt8 in
        if index % 4 == 0 {
            return buffer[index + 2]
        } else if index % 4 == 2 {
            return buffer[index - 2]
        } else {
            return byte
        }
    }
    return CapturedScreenArea(
        buffer: correctedBuffer,
        width: width,
        height: height,
        bitsPerPixel: image.bitsPerPixel,
        bytesPerPixel: image.bitsPerPixel / 8
    )
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
            binaryMessenger: registrar.messenger
        )
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
            let capturedScreenArea = captureScreenArea(
                x: x,
                y: y,
                width: width,
                height: height
            )
            result(capturedScreenArea?.asDictionary())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
