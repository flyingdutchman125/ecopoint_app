import 'dart:io';

void main() async {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib dir not found');
    return;
  }

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('alert_helper.dart')) continue;

    String content = await file.readAsString();
    bool changed = false;

    while (content.contains('AppAlerts.showError(context, Terjadi Kesalahan);.showSnackBar(') || 
           content.contains('AppAlerts.showSuccess(context, Terjadi Kesalahan);.showSnackBar(') ||
           content.contains('AppAlerts.showSuccess(context, Berhasil);.showSnackBar(')) {
      
      int start = content.indexOf('AppAlerts.showError(context, Terjadi Kesalahan);.showSnackBar(');
      if (start == -1) start = content.indexOf('AppAlerts.showSuccess(context, Terjadi Kesalahan);.showSnackBar(');
      if (start == -1) start = content.indexOf('AppAlerts.showSuccess(context, Berhasil);.showSnackBar(');
      
      if (start == -1) break;

      int showSnackBarStart = content.indexOf('.showSnackBar(', start);
      int end = showSnackBarStart;
      int braceCount = 0;
      bool foundFirstParen = false;
      
      for (int i = showSnackBarStart; i < content.length; i++) {
        if (content[i] == '(') {
          braceCount++;
          foundFirstParen = true;
        } else if (content[i] == ')') {
          braceCount--;
        }
        
        if (foundFirstParen && braceCount == 0) {
          end = i;
          break;
        }
      }
      
      // account for trailing semicolon
      if (end + 1 < content.length && content[end + 1] == ';') {
        end++;
      }

      String block = content.substring(start, end + 1);
      
      // Extract text inside Text(...)
      String text = "'Terjadi Kesalahan'";
      RegExp textRegex = RegExp(r"Text\((['\"].*?['\"])(?:,.*?)?\)");
      var match = textRegex.firstMatch(block);
      if (match != null) {
        text = match.group(1)!;
      } else {
        // try to extract variable e.g. Text(auth.error!)
        RegExp varRegex = RegExp(r"Text\((.*?)(?:,.*?)?\)");
        var vMatch = varRegex.firstMatch(block);
        if (vMatch != null) {
          text = vMatch.group(1)!;
        }
      }
      
      String method = 'showError';
      if (block.toLowerCase().contains('berhasil') || 
          block.toLowerCase().contains('success') || 
          block.contains('Colors.green') || 
          block.contains('0xFF7BC143') ||
          block.contains('0xFF59B41C')) {
        method = 'showSuccess';
      }
      
      String replacement = 'AppAlerts.$method(context, $text);';
      content = content.replaceRange(start, end + 1, replacement);
      changed = true;
    }
    
    if (changed) {
      await file.writeAsString(content);
      print('Updated ${file.path}');
    }
  }
}
