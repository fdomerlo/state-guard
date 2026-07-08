#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys

def compile_opencode_prompt(repo_dir, skills_path):
    content = (
        "Actúas como agente de desarrollo.\n\n"
        "## PROTOCOLO DE ESTADO (ACID)\n"
        "1. PROHIBIDO editar state.ini manualmente.\n"
        f"2. Delega la mutación del estado usando siempre la terminal con este comando exacto: `python3 {skills_path}/bin/mmx_state_manager.py [comando]`\n"
        "3. Carga siempre `{SKILLS_PATH}/_shared/mmx-convention.md` al iniciar.\n"
    )
    return content.replace("{SKILLS_PATH}", skills_path)

def compile_lazy_prompt(repo_dir, skills_path):
    prompt_path = os.path.join(repo_dir, "integrations", "system-prompt.md")
    with open(prompt_path, "r", encoding="utf-8") as f:
        prompt = f.read()
    return prompt.replace("{SKILLS_PATH}", skills_path)

def process_opencode_commands(commands_src, commands_target, skills_path):
    if not os.path.exists(commands_src):
        return
    os.makedirs(commands_target, exist_ok=True)
    for cmd_file in os.listdir(commands_src):
        if not cmd_file.endswith(".md"):
            continue
        src_path = os.path.join(commands_src, cmd_file)
        tgt_path = os.path.join(commands_target, cmd_file)
        with open(src_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Reemplazar variables de ruta
        content = content.replace("{{SKILLS_PATH}}", skills_path)
        content = content.replace("{SKILLS_PATH}", skills_path)
        
        # Forzar el tool-calling de lectura de forma directa y menos alarmista
        pattern = re.compile(r"Lee el archivo\s+`([^`]+)`\s+y\s+ejecuta\s+sus\s+instrucciones.*", re.IGNORECASE)
        replacement = r"Usa tu herramienta `read_file` obligatoriamente en la ruta `\1` para cargar el contrato de esta fase."
        
        if pattern.search(content):
            content = pattern.sub(replacement, content)
        else:
            # Fallback
            content = content.replace("Lee el archivo", "Usa tu herramienta `read_file` obligatoriamente en el archivo")
            
        with open(tgt_path, "w", encoding="utf-8") as f:
            f.write(content)

def main():
    parser = argparse.ArgumentParser(description="Memex Packager")
    parser.add_argument("--target", required=True, help="Target engine: opencode, claude-code, antigravity-cli, project-local, all-global, custom")
    parser.add_argument("--skills-path", required=True, help="Resolved skills path")
    parser.add_argument("--config-target", required=False, help="Path to config file to inject")
    parser.add_argument("--commands-src", required=False, help="Source directory for opencode commands")
    parser.add_argument("--commands-target", required=False, help="Target directory for opencode commands")
    
    args = parser.parse_args()
    
    repo_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    if args.target == "opencode":
        if not args.config_target:
            print("Missing --config-target for opencode")
            sys.exit(1)
            
        prompt = compile_opencode_prompt(repo_dir, args.skills_path)
        
        source_config = os.path.join(repo_dir, "integrations", "opencode", "opencode.json")
        try:
            with open(source_config, "r", encoding="utf-8") as f:
                source = json.load(f)
        except Exception as e:
            print(f"Error reading source opencode.json: {e}")
            sys.exit(1)
            
        os.makedirs(os.path.dirname(args.config_target), exist_ok=True)
        if os.path.exists(args.config_target):
            try:
                with open(args.config_target, "r", encoding="utf-8") as f:
                    target = json.load(f)
            except Exception:
                target = {"$schema": "https://opencode.ai/config.json", "agent": {}}
        else:
            target = {"$schema": "https://opencode.ai/config.json", "agent": {}}
            
        if "agent" not in target:
            target["agent"] = {}
            
        target["agent"]["memex"] = source["agent"]["memex"]
        target["agent"]["memex"]["prompt"] = prompt
        
        with open(args.config_target, "w", encoding="utf-8") as f:
            json.dump(target, f, indent=2, ensure_ascii=False)
            
        if args.commands_src and args.commands_target:
            process_opencode_commands(args.commands_src, args.commands_target, args.skills_path)
            
if __name__ == "__main__":
    main()