import os
import time
from datetime import datetime


def try_acquire_lockfile(lock_path):
    """Atomic OS-level test-and-set. Returns True if acquired."""
    d = os.path.dirname(lock_path)
    if d:
        os.makedirs(d, exist_ok=True)
    try:
        fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        os.close(fd)
        return True
    except FileExistsError:
        return False


def release_lockfile(lock_path):
    if os.path.exists(lock_path):
        os.remove(lock_path)


def is_stale(started_at_iso, ttl_seconds):
    if not started_at_iso or started_at_iso == "None":
        return False
    elapsed = (datetime.now() - datetime.fromisoformat(started_at_iso)).total_seconds()
    return elapsed > ttl_seconds


def check_lock_status(lock_path, started_at_iso, ttl_seconds):
    """FREE | ACTIVE | STALE"""
    if not os.path.exists(lock_path):
        return "FREE"
    if is_stale(started_at_iso, ttl_seconds):
        return "STALE"
    return "ACTIVE"


def with_write_lock(write_lock_path, fn, retries=40, delay=0.05):
    """Serializa cualquier escritura a state.ini (mutex de archivo, vida corta).
    Distinto del lock de negocio (.lock de fase): este protege contra
    lost-update por read-modify-write concurrente, sin importar qué campo
    lógico se está tocando."""
    for _ in range(retries):
        if try_acquire_lockfile(write_lock_path):
            try:
                return fn()
            finally:
                release_lockfile(write_lock_path)
        time.sleep(delay)
    raise RuntimeError(
        "No se pudo adquirir el write-lock de state.ini tras reintentos."
    )
