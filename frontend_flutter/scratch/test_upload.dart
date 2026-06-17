import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

void main() async {
  print('Starting upload test...');
  
  // Create a dummy 10-byte file representing image bytes
  final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 10, 0x4A, 0x46, 0x49, 0x46]);
  
  // Construct fromBytes MultipartFile
  final fileFromBytes = MultipartFile.fromBytes(
    bytes,
    filename: 'food_scan.jpg',
    contentType: MediaType('image', 'jpeg'),
  );
  
  // Print details
  print('FromBytes length: ${fileFromBytes.length}');
  print('FromBytes contentType: ${fileFromBytes.contentType}');
  print('FromBytes filename: ${fileFromBytes.filename}');
}
