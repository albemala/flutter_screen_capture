import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as image_lib;

@immutable
class CapturedScreenArea {
  final Uint8List buffer;
  final int width;
  final int height;
  final int bitsPerPixel;
  final int bytesPerPixel;

  double get aspectRatio => width / height;

  const CapturedScreenArea({
    required this.buffer,
    required this.width,
    required this.height,
    required this.bitsPerPixel,
    required this.bytesPerPixel,
  });

  factory CapturedScreenArea.fromJson(Map<Object?, Object?> json) {
    return CapturedScreenArea(
      buffer: Uint8List.fromList((json['buffer'] as List<Object?>).cast<int>()),
      width: json['width'] as int,
      height: json['height'] as int,
      bitsPerPixel: json['bitsPerPixel'] as int,
      bytesPerPixel: json['bytesPerPixel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'buffer': buffer.toList(),
      'width': width,
      'height': height,
      'bitsPerPixel': bitsPerPixel,
      'bytesPerPixel': bytesPerPixel,
    };
  }

  image_lib.Image toImage() {
    return image_lib.Image.fromBytes(
      width,
      height,
      buffer,
      format: imageFormat,
    );
  }

  image_lib.Format get imageFormat {
    if (Platform.isMacOS) return image_lib.Format.bgra;
    return image_lib.Format.rgba;
  }

  Uint8List toPngImage() {
    return Uint8List.fromList(image_lib.encodePng(toImage(), level: 0));
  }

  Color getPixelColor(double x, double y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw RangeError('Pixel coordinates out of range');
    }
    final index = ((y * width + x) * bytesPerPixel).toInt();
    final b = buffer[index];
    final g = buffer[index + 1];
    final r = buffer[index + 2];
    final a = buffer[index + 3];
    return Color.fromARGB(a, r, g, b);
  }

  CapturedScreenArea copyWith({
    Uint8List? buffer,
    int? width,
    int? height,
    int? bitsPerPixel,
    int? bytesPerPixel,
  }) {
    return CapturedScreenArea(
      buffer: buffer ?? this.buffer,
      width: width ?? this.width,
      height: height ?? this.height,
      bitsPerPixel: bitsPerPixel ?? this.bitsPerPixel,
      bytesPerPixel: bytesPerPixel ?? this.bytesPerPixel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapturedScreenArea &&
          runtimeType == other.runtimeType &&
          buffer == other.buffer &&
          width == other.width &&
          height == other.height &&
          bitsPerPixel == other.bitsPerPixel &&
          bytesPerPixel == other.bytesPerPixel;

  @override
  int get hashCode =>
      buffer.hashCode ^ //
      width.hashCode ^
      height.hashCode ^
      bitsPerPixel.hashCode ^
      bytesPerPixel.hashCode;
}
