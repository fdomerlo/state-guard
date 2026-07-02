import os
import glob
import re
import json

def clean_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Remove 'Transacción' sections
    content = re.sub(r'## Transacción\n.*?(?=\n## |\Z)', '', content, flags=re.DOTALL)
    
    # Remove specific lines
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        lower_line = line.lower()
        if 'return envelope' in lower_line or 'sobre de retorno' in lower_line:
            continue
        if 'actualización de estado' in lower_line:
            continue
        if 'lock phase' in lower_line or 'txn_status' in lower_line or 'completed_phases' in lower_line or 'pending_phases' in lower_line:
            continue
        if 'ejecutá commit' in lower_line or 'ejecuta commit' in lower_line:
            continue
        if 'protocolo de transacción' in lower_line and 'commit' in lower_line:
            continue
        if 'indentar' in lower_line and ('.yaml' in lower_line or '.ini' in lower_line):
            continue
        if 'corromper el estado' in lower_line:
            continue
        if 'bloques de control' in lower_line and 'output' in lower_line:
            continue
        # Replace 'Persistir y Reportar' with 'Reportar'
        line = re.sub(r'(### Paso \d+: )Persistir y Reportar', r'\1Reportar', line)
        new_lines.append(line)
        
    content = '\n'.join(new_lines)
    
    # Remove specific blocks that might be left over
    content = re.sub(r'## Return Envelope.*?(?=\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(r'## Sobre de Retorno.*?(?=\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(r'## Actualización de Estado.*?(?=\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(r'### Return Envelope.*?(?=\n### |\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(r'### Sobre de Retorno.*?(?=\n### |\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(r'### Actualización de Estado.*?(?=\n### |\n## |\Z)', '', content, flags=re.DOTALL | re.IGNORECASE)

    # Clean up empty list items if any
    content = re.sub(r'\n- \n', '\n', content)
    
    # Remove multiple blank lines
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content.strip() + '\n')
        return True
    return False

def main():
    base_dir = '/home/fdomerlo/workspace/github.com/fdomerlo/agentify-sdd/skills'
    skill_files = glob.glob(os.path.join(base_dir, '**', 'SKILL.md'), recursive=True)
    
    modified_files = []
    for fp in skill_files:
        if clean_file(fp):
            rel_path = os.path.relpath(fp, base_dir)
            modified_files.append(rel_path)
    
    print(json.dumps(modified_files))

if __name__ == '__main__':
    main()
