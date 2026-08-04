import os

def fix_files(directory):
    target = "AppAlerts.showError(context, Terjadi Kesalahan);.showSnackBar("
    replacement = "ScaffoldMessenger.of(context).showSnackBar("
    
    count = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if target in content:
                    content = content.replace(target, replacement)
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Fixed {filepath}")
                    count += 1
    
    print(f"Total files fixed: {count}")

if __name__ == '__main__':
    fix_files('/home/rebel/ecopoint/lib')
