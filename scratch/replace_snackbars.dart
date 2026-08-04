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
    if (!content.contains('ScaffoldMessenger')) continue;

    // We will do a generic replacement.
    // Since ScaffoldMessenger is used in various ways, we will find "ScaffoldMessenger.of(context).showSnackBar"
    // and try to extract the text inside SnackBar(content: Text('...'))
    // This is a naive regex but it works for most cases in this codebase.
    
    // Pattern to match ScaffoldMessenger block
    // We'll use a loop to manually parse it to be safe, because regex for nested parenthesis is hard in Dart.
    // Let's use a simpler approach: just replace all standard ScaffoldMessengers we find.
    
    // Instead of regex for the whole block, let's find the start of ScaffoldMessenger
    bool changed = false;
    while (content.contains('ScaffoldMessenger.of(context).showSnackBar')) {
      int start = content.indexOf('ScaffoldMessenger.of(context).showSnackBar');
      int end = start;
      int braceCount = 0;
      bool foundFirstParen = false;
      
      for (int i = start; i < content.length; i++) {
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
      
      if (end == start) {
        break; // couldn't parse
      }
      
      String block = content.substring(start, end + 1);
      
      // Extract text inside Text(...)
      String text = 'Terjadi Kesalahan';
      RegExp textRegex = RegExp('Text\\((["\'].*?["\'])(?:,.*?)?\\)');
      var match = textRegex.firstMatch(block);
      if (match != null) {
        text = match.group(1)!;
      } else {
        // sometimes it's Text(auth.error!)
        RegExp varRegex = RegExp('Text\\((.*?)(?:,.*?)?\\)');
        var vMatch = varRegex.firstMatch(block);
        if (vMatch != null) {
          text = vMatch.group(1)!;
        }
      }
      
      // Determine if error or success
      String method = 'showError'; // default
      if (block.toLowerCase().contains('berhasil') || block.toLowerCase().contains('success') || block.contains('Colors.green')) {
        method = 'showSuccess';
      }
      
      String replacement = 'AppAlerts.$method(context, $text);';
      content = content.replaceRange(start, end + 1, replacement);
      // clean up trailing semi-colon if it was double
      if (content.length > end + 1 + replacement.length && content.startsWith(';', start + replacement.length)) {
          content = content.replaceRange(start + replacement.length, start + replacement.length + 1, '');
      }
      changed = true;
    }
    
    if (changed) {
      // add import if needed
      if (!content.contains('alert_helper.dart')) {
        // calculate relative path
        int depth = file.path.split('/').length - 2; // -1 for 'lib', -1 for filename
        String relativePath = depth == 0 ? 'core/utils/alert_helper.dart' : '${List.filled(depth, '..').join('/')}/core/utils/alert_helper.dart';
        content = "import '$relativePath';\n" + content;
      }
      await file.writeAsString(content);
      print('Updated \${file.path}');
    }
  }
}
