import 'dart:io';

import 'package:image_headers/image_headers.dart';
import 'package:test/test.dart';

void main() {
  test('PNG', () {
    final File file = File('test/fixtures/backpack.png');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is PngImageData, true);
    expect(imageData.type, ImageType.png);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });

  test('BMP', () {
    final File file = File('test/fixtures/backpack.bmp');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is BmpImageData, true);
    expect(imageData.type, ImageType.bmp);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });

  test('GIF', () {
    final File file = File('test/fixtures/backpack.gif');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is GifImageData, true);
    expect(imageData.type, ImageType.gif);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });

  test('WebP', () {
    final File file = File('test/fixtures/backpack.webp');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is WebPImageData, true);
    expect(imageData.type, ImageType.webp);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });

  test('JPEG', () {
    final File file = File('test/fixtures/backpack.jpg');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is JpegImageData, true);
    expect(imageData.type, ImageType.jpeg);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });

  test('JPEG 2000', () {
    final File file = File('test/fixtures/backpack.jpf');
    final ImageData imageData = ImageData.fromBytes(file.readAsBytesSync());
    expect(imageData is JpegImageData, true);
    expect(imageData.type, ImageType.jpeg);
    expect(imageData.height, 650);
    expect(imageData.width, 672);
  });
}
