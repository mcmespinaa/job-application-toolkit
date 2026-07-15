#!/usr/bin/env python3
"""validate_manifests.py — validate the Claude Code plugin + marketplace manifests.

A malformed marketplace.json or plugin.json breaks `/plugin install` for every downstream
user, and the failure is invisible until someone tries. This asserts both files parse, carry
the required fields, that the marketplace's plugin `source` resolves to a real plugin dir
containing a real plugin.json, and that any skills listed in plugin.json actually exist.

Stdlib only. Exit 0 = valid, 1 = invalid.
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
MARKETPLACE = os.path.join(ROOT, ".claude-plugin", "marketplace.json")

errors = []
def err(msg): errors.append(msg)
def ok(msg): print(f"  ok: {msg}")


def load_json(path, label):
    if not os.path.isfile(path):
        err(f"{label}: file not found at {path}")
        return None
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        ok(f"{label}: valid JSON")
        return data
    except json.JSONDecodeError as e:
        err(f"{label}: JSON parse error: {e}")
        return None


def require(data, key, label):
    if not isinstance(data, dict) or key not in data or data[key] in (None, "", [], {}):
        err(f"{label}: missing/empty required field '{key}'")
        return False
    ok(f"{label}: has '{key}'")
    return True


# --- marketplace.json ---
mkt = load_json(MARKETPLACE, "marketplace.json")
if mkt:
    for k in ("name", "owner", "plugins"):
        require(mkt, k, "marketplace.json")
    plugins = mkt.get("plugins")
    if not isinstance(plugins, list) or not plugins:
        err("marketplace.json: 'plugins' must be a non-empty array")
    else:
        for i, p in enumerate(plugins):
            lbl = f"marketplace.json plugins[{i}]"
            require(p, "name", lbl)
            src = p.get("source")
            if not src:
                err(f"{lbl}: missing 'source'")
                continue
            ok(f"{lbl}: source = {src}")
            # source is relative to the marketplace root (repo root here).
            plugin_dir = os.path.normpath(os.path.join(ROOT, src))
            if not os.path.isdir(plugin_dir):
                err(f"{lbl}: source dir does not exist: {plugin_dir}")
                continue
            # --- the plugin.json it points to ---
            pj_path = os.path.join(plugin_dir, ".claude-plugin", "plugin.json")
            pj = load_json(pj_path, f"{p.get('name')}/plugin.json")
            if pj:
                for k in ("name", "description", "version"):
                    require(pj, k, f"{p.get('name')}/plugin.json")
                # If plugin.json enumerates skills, each must exist on disk.
                declared = pj.get("skills") or []
                if declared:
                    for s in declared:
                        # accept either a bare name or a path
                        name = s if isinstance(s, str) else s.get("name", "")
                        skill_md = os.path.join(plugin_dir, "skills", name, "SKILL.md")
                        if os.path.isfile(skill_md):
                            ok(f"declared skill '{name}' -> SKILL.md exists")
                        else:
                            err(f"declared skill '{name}' has no {skill_md}")
                # Cross-check: every skills/*/SKILL.md on disk should be discoverable.
                skills_dir = os.path.join(plugin_dir, "skills")
                if os.path.isdir(skills_dir):
                    found = sorted(
                        d for d in os.listdir(skills_dir)
                        if os.path.isfile(os.path.join(skills_dir, d, "SKILL.md"))
                    )
                    ok(f"skills on disk: {', '.join(found)}")

if errors:
    print("\nMANIFEST VALIDATION FAILED:", file=sys.stderr)
    for e in errors:
        print(f"  - {e}", file=sys.stderr)
    sys.exit(1)

print("\nAll manifests valid.")
