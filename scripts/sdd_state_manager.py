#!/usr/bin/env python3
import argparse
import configparser
import os
import sys
from datetime import datetime

STATE_FILE = ".agentify/changes/{change}/state.ini"
PHASES_ORDER = ["explore", "propose", "spec", "design", "tasks", "hotfix", "apply", "verify", "archive"]

def load_state(change_name):
    path = STATE_FILE.format(change=change_name)
    config = configparser.ConfigParser()
    if not os.path.exists(path):
        print(f"ERROR: No se encontró el state.ini para '{change_name}'")
        sys.exit(1)
    config.read(path, encoding='utf-8')
    return config, path

def save_state(config, path):
    if not config.has_section('Metadata'):
        config.add_section('Metadata')
    config.set('Metadata', 'last_updated', datetime.now().isoformat())
    with open(path, 'w', encoding='utf-8') as f:
        config.write(f)

def get_list(config, section, option):
    val = config.get(section, option, fallback="").strip()
    return [x.strip() for x in val.split(',')] if val else []

def set_list(config, section, option, lst):
    config.set(section, option, ", ".join(lst))

def cmd_begin(args):
    config, path = load_state(args.change)
    if config.get('Transaction', 'txn_status', fallback='idle') == 'in_progress':
        print("ERROR: Ya hay una transacción en progreso.")
        sys.exit(1)
    
    config.set('Transaction', 'txn_status', 'in_progress')
    config.set('Transaction', 'txn_phase', args.phase)
    config.set('Transaction', 'txn_started_at', datetime.now().isoformat())
    save_state(config, path)
    print(f"SUCCESS|BEGIN transaccional iniciado para fase: {args.phase}")

def cmd_commit(args):
    config, path = load_state(args.change)
    if config.get('Transaction', 'txn_status', fallback='idle') != 'in_progress':
        print("ERROR: No hay transacción en progreso para hacer commit.")
        sys.exit(1)
    
    phase = config.get('Transaction', 'txn_phase')
    config.set('Graph', 'current_phase', phase)
    config.set('Graph', 'lock_phase', args.next_phase)
    
    completed = get_list(config, 'Graph', 'completed_phases')
    if phase not in completed:
        completed.append(phase)
        set_list(config, 'Graph', 'completed_phases', completed)
        
    pending = get_list(config, 'Graph', 'pending_phases')
    if phase in pending:
        pending.remove(phase)
        set_list(config, 'Graph', 'pending_phases', pending)
        
    config.set('Transaction', 'txn_status', 'idle')
    config.set('Transaction', 'txn_phase', 'None')
    save_state(config, path)
    print(f"SUCCESS|COMMIT exitoso. Nueva lock_phase: {args.next_phase}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SDD State Manager (INI Format - Zero Dependencies)")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    p_begin = subparsers.add_parser("begin")
    p_begin.add_argument("--change", required=True)
    p_begin.add_argument("--phase", required=True)
    
    p_commit = subparsers.add_parser("commit")
    p_commit.add_argument("--change", required=True)
    p_commit.add_argument("--next-phase", required=True)

    args = parser.parse_args()
    if args.command == "begin": cmd_begin(args)
    elif args.command == "commit": cmd_commit(args)