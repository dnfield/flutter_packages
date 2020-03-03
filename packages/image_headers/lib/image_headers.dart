import 'dart:typed_data';

/// Image format information for formats supported by Flutter.
enum ImageType {
  /// A Portable Network Graphics format image.
  png,

  /// A JPEG format image.
  ///
  /// This library does not support JPEG 2000.
  jpeg,

  /// A WebP format image.
  webp,

  /// A Graphics Interchange Format image.
  gif,

  /// A Windows Bitmap format image.
  bmp,
}

/// Provides details about image format information for raw compressed bytes
/// of an image.
abstract class ImageData {
  /// Allows subclasses to be const.
  const ImageData();

  /// Creates an appropriate [ImageData] for the source `bytes`, if possible.
  ///
  /// Only supports image formats supported by Flutter.
  factory ImageData.fromBytes(Uint8List bytes) {
    if (bytes == null || bytes.isEmpty) {
      throw ArgumentError('bytes');
    } else if (_startsWith(bytes, pngHeader)) {
      return PngImageData._(bytes.buffer.asByteData());
    } else if (_startsWith(bytes, gif89aHeader)) {
      return GifImageData._(bytes.buffer.asByteData(), 89);
    } else if (_startsWith(bytes, gif87aHeader)) {
      return GifImageData._(bytes.buffer.asByteData(), 87);
    } else if (_startsWith(bytes, jpegBaseHeader)) {
      return JpegImageData._(bytes.buffer.asByteData());
    } else if (_startsWith(bytes, webpBaseHeader)) {
      return WebPImageData._(bytes.buffer.asByteData());
    } else if (_startsWith(bytes, bmpHeader)) {
      return BmpImageData._(bytes.buffer.asByteData());
    } else {
      return null;
    }
  }

  static bool _startsWith(Uint8List bytes, List<int> needle) {
    if (bytes.length < needle.length) {
      return false;
    }

    for (int index = 0; index < needle.length; index++) {
      if (bytes[index] != needle[index]) {
        return false;
      }
    }
    return true;
  }

  /// The raw bytes of this image.
  ByteData get data;

  /// The [ImageType] this instance represents.
  ImageType get type;

  /// The width, in pixels, of the image.
  int get width;

  /// The height, in pixels, of the image.
  int get height;

  /// The esimated size of the image in bytes.
  ///
  /// The `withMipmapping` parameter controls whether to account for mipmapping
  /// when decompressing the image. Flutter will use this when possible, at the
  /// cost of slightly more memory usage.
  int estimatedSizeBytes({bool withMipmapping = true}) {
    if (withMipmapping)
      return (width * height * 4.3).ceil();
    return width * height * 4;
  }

  /// The header for a PNG format file.
  static const List<int> pngHeader = <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  /// The start of the JPEG header.
  static const List<int> jpegBaseHeader = <int>[0xFF, 0xD8];

  /// The start of the WebP header.
  static const List<int> webpBaseHeader = <int>[
    0x52,
    0x49,
    0x46,
    0x46,
  ];

  /// The header for a GIF87a format GIF file.
  static const List<int> gif87aHeader = <int>[
    0x47,
    0x49,
    0x46,
    0x38,
    0x37,
    0x61,
  ];

  /// The header for a GIF89a format GIF file.
  static const List<int> gif89aHeader = <int>[
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
  ];

  /// The header for a Windows BMP file ('BM').
  static const List<int> bmpHeader = <int>[
    0x42,
    0x4D,
  ];
}

/// The [ImageData] for a PNG image.
class PngImageData extends ImageData {
  PngImageData._(this.data);

  @override
  final ByteData data;

  @override
  ImageType get type => ImageType.png;

  int _width;
  @override
  int get width => _width ??= data.getUint32(16, Endian.big);

  int _height;
  @override
  int get height => _height ??= data.getUint32(20, Endian.big);
}

/// The [ImageData] for a GIF image.
class GifImageData extends ImageData {
  GifImageData._(this.data, this.version);

  @override
  final ByteData data;

  @override
  ImageType get type => ImageType.gif;

  /// The GIF version, either 87 or 89.
  final int version;

  int _width;
  @override
  int get width => _width ??= data.getUint16(6, Endian.little);

  int _height;
  @override
  int get height => _height ??= data.getUint16(8, Endian.little);
}

/// The [ImageData] for a JPEG image.
///
/// This library does not support JPEG2000 images.
class JpegImageData extends ImageData {
  JpegImageData._(this.data) {
    int index = 4; // Skip the first header bytes (already validated).
    index += data.getUint8(index) * 256 + data.getUint8(index + 1);
    while (index < data.lengthInBytes) {
      if (data.getUint8(index) != 0xFF) {
        // Start of block
        throw StateError('Invalid JPEG file');
      }
      if (data.getUint8(index + 1) == 0xC0) {
        // Start of frame 0
        _height = data.getUint16(index + 5, Endian.big);
        _width = data.getUint16(index + 7, Endian.big);
        break;
      }
      index += 2;
      index += data.getUint8(index) * 256 + data.getUint8(index + 1);
    }
  }

  @override
  final ByteData data;

  @override
  ImageType get type => ImageType.jpeg;

  int _width;
  @override
  int get width => _width;

  int _height;
  @override
  int get height => _height;
}

/// The [ImageData] for a WebP image.
class WebPImageData extends ImageData {
  WebPImageData._(this.data);

  @override
  final ByteData data;

  @override
  ImageType get type => ImageType.webp;

  int _width;
  @override
  int get width => _width ??= data.getUint16(26, Endian.little);

  int _height;
  @override
  int get height => _height ??= data.getUint16(28, Endian.little);
}

/// The [ImageData] for a BMP image.
class BmpImageData extends ImageData {
  BmpImageData._(this.data);

  @override
  final ByteData data;

  @override
  ImageType get type => ImageType.bmp;

  int _width;
  @override
  int get width => _width ??= data.getInt32(18, Endian.little);

  int _height;
  @override
  int get height => _height ??= data.getInt32(22, Endian.little);
}
