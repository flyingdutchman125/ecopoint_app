import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int count = 0;
  for (final file in files) {
    String content = await file.readAsString();
    if (content.contains('AppAlerts.showError(context, Terjadi Kesalahan);.showSnackBar(')) {
      content = content.replaceAll('AppAlerts.showError(context, Terjadi Kesalahan);.showSnackBar(', 'ScaffoldMessenger.of(context).showSnackBar(');
      await file.writeAsString(content);
      count++;
    }
  }
  print('Fixed $count files.');
}
