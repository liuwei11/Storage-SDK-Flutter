import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'utils.dart';

void main() {
  group("file in China", () {
    setUp(() => initNorthChina());

    test('query file', () async {
      LCQuery<LCFile> query = new LCQuery<LCFile>('_File');
      LCFile file = await query.get('5e0dbfa0562071008e21c142');
      print(file.url);
      print(file.getThumbnailUrl(32, 32));
    });

    test('save from path', () async {
      LCFile file = await LCFile.fromPath('avatar', './avatar.jpg');
      await file.save(onProgress: (int count, int total) {
        print('$count/$total');
        if (count == total) {
          print('done');
        }
      });
      print(file.objectId);
      assert(file.objectId != null);
    });

    test('save from memory', () async {
      String text = 'hello, world';
      Uint8List data = utf8.encode(text);
      LCFile file = LCFile.fromBytes('text', data);
      await file.save();
      print(file.objectId);
      assert(file.objectId != null);
    });

    test('save from url', () async {
      LCFile file = LCFile.fromUrl(
          'scene', 'http://img95.699pic.com/photo/50015/9034.jpg_wh300.jpg');
      file.addMetaData('size', 1024);
      file.addMetaData('width', 128);
      file.addMetaData('height', 256);
      file.mimeType = 'image/jpg';
      await file.save();
      print(file.objectId);
      assert(file.objectId != null);
    });

    test('object with file', () async {
      LCFile file = await LCFile.fromPath('avatar', './avatar.jpg');
      LCObject obj = new LCObject('FileObject');
      obj['file'] = file;
      String text = 'hello, world';
      Uint8List data = utf8.encode(text);
      LCFile file2 = LCFile.fromBytes('text', data);
      obj['files'] = [file, file2];
      await obj.save();
      assert(file.objectId != null && file.url != null);
      assert(file2.objectId != null && file2.url != null);
      assert(obj.objectId != null);
    });

    test('query object with file', () async {
      LCQuery<LCObject> query = new LCQuery('FileObject');
      query.include('files');
      List<LCObject> objs = await query.find();
      objs.forEach((item) {
        LCFile file = item['file'] as LCFile;
        assert(file.objectId != null && file.url != null);
        List files = item['files'] as List;
        files.forEach((f) {
          assert(f is LCFile);
          assert(f.objectId != null && f.url != null);
        });
      });
    });
  });

  group('file in US', () {
    setUp(() => initUS());

    test('aws', () async {
      LCFile file = await LCFile.fromPath('avatar', './avatar.jpg');
      await file.save();
      print(file.objectId);
      assert(file.objectId != null);
    });
  });
}
