#!/usr/bin/env python3
"""
Launcher wrapper for hawklithm/workbuddy2api (codebuddy_proxy).
Applies message role normalization (developer -> system, default system prompt fallback)
and forwards CLI flags from environment variables.
"""

import json
import os
import runpy
import sys

_orig_loads = json.loads
_orig_dumps = json.dumps


def _normalize_messages(obj):
    if isinstance(obj, dict) and isinstance(obj.get("messages"), list):
        msgs = obj["messages"]
        if msgs and isinstance(msgs[0], dict) and msgs[0].get("role") == "developer":
            msgs[0]["role"] = "system"
        if not msgs or (isinstance(msgs[0], dict) and msgs[0].get("role") != "system"):
            msgs.insert(0, {"role": "system", "content": "You are a helpful assistant."})
    return obj


def _patched_loads(s, *args, **kwargs):
    return _normalize_messages(_orig_loads(s, *args, **kwargs))


def _patched_dumps(o, *args, **kwargs):
    return _orig_dumps(_normalize_messages(o), *args, **kwargs)


json.loads = _patched_loads
json.dumps = _patched_dumps


def main():
    host = os.environ.get("HOST", "0.0.0.0")
    port = os.environ.get("PORT", "48787")
    use_global = os.environ.get("WORKBUDDY_GLOBAL", "true").lower() in ("1", "true", "yes")
    use_desensitize = os.environ.get("WORKBUDDY_DESENSITIZE", "true").lower() in ("1", "true", "yes")
    session_file = os.environ.get("SESSION_FILE", "").strip()

    argv = ["codebuddy_proxy", "--host", host, "--port", str(port)]
    if use_global:
        argv.append("--global")
    if use_desensitize:
        argv.append("--desensitize")
    if session_file and os.path.isfile(session_file):
        argv.extend(["--session-file", session_file])

    sys.argv = argv
    runpy.run_module("codebuddy_proxy", run_name="__main__", alter_sys=True)


if __name__ == "__main__":
    main()
