import 'dart:io';

import 'package:path/path.dart';

class RecordRepository {
  RecordRepository(this.documentsDirectory);
  final Directory documentsDirectory;
  late final _dir = Directory(join(documentsDirectory.path, 'records'));

  Future<List<File>> getRecords() async {
    if (await _dir.exists() == false) {
      return const [];
    }

    return _dir.listSync().whereType<File>().where((e) => e.path.toLowerCase().endsWith('wav')).toList()..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
  }

  Future<File> createNewRecord() async {
    if (await _dir.exists() == false) {
      await _dir.create();
    }

    final records = await getRecords();
    final record = File(join(_dir.path, '${records.length}.wav'));
    return record.create();
  }
}
