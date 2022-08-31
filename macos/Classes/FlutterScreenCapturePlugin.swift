import Cocoa
import FlutterMacOS

struct CapturedScreenArea {
    let buffer: Data
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
    guard let buffer = CFDataGetBytePtr(imageData) else {
        return nil
    }
    return CapturedScreenArea(
        buffer: Data(
            bytes: buffer,
            count: CFDataGetLength(imageData)
        ),
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
