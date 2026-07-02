import os
import glob
import re
import json

def clean_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Remove entire '## Transacción' section
    # Matches '## Transacción' up to the next '## ' or EOF
    content = re.sub(r'## Transacción\n.*?(?=\n## |\Z)', '', content, flags=re.DOTALL)
    
    # 2. Remove 'Return Envelope' / 'Sobre de Retorno' / 'Actualización de Estado' sections
    content = re.sub(r'## (?:Return Envelope|Sobre de Retorno|Actualización de Estado)\n.*?(?=\n## |\Z)', '', content, flags=re.DOTALL)
    content = re.sub(r'### (?:Return Envelope|Sobre de Retorno|Actualización de Estado)\n.*?(?=\n### |\n## |\Z)', '', content, flags=re.DOTALL)
    
    # 3. Clean up 'Persistir y Reportar' or 'Reportar' lines that mention COMMIT/state.yaml
    # Rename 'Paso X: Persistir y Reportar' to 'Paso X: Reportar'
    content = re.sub(r'(### Paso \d+: )Persistir y Reportar', r'\1Reportar', content)
    # Remove lines mentioning 'Ejecutá COMMIT' or 'state.yaml'
    content = re.sub(r'.*Ejecutá COMMIT en `state\.yaml`.*?\n', '', content)
    content = re.sub(r'.*Actualizar el estado en `state\.yaml`.*?\n', '', content)
    
    # 4. Remove any block or line with txn_status, completed_phases, pending_phases, lock_phase
    content = re.sub(r'.*txn_status.*\n?', '', content)
    content = re.sub(r'.*completed_phases.*\n?', '', content)
    content = re.sub(r'.*pending_phases.*\n?', '', content)
    content = re.sub(r'.*lock_phase.*\n?', '', content)
    
    # 5. Remove rules about .yaml or .ini indentation/manipulation
    content = re.sub(r'- .*indentar.*\.yaml.*\n?', '', content, flags=re.IGNORECASE)
    content = re.sub(r'- .*indentar.*\.ini.*\n?', '', content, flags=re.IGNORECASE)
    content = re.sub(r'- .*corromper el estado.*\n?', '', content, flags=re.IGNORECASE)
    content = re.sub(r'- .*bloques de control.*output.*\n?', '', content, flags=re.IGNORECASE)
    content = re.sub(r'- .*Return Envelope.*\n?', '', content, flags=re.IGNORECASE)
    content = re.sub(r'- .*Sobre de Retorno.*\n?', '', content, flags=re.IGNORECASE)

    # Remove extra blank lines created by deletions
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
