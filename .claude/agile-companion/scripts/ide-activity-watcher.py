#!/usr/bin/env python3
"""
agile-companion IDE activity watcher
Captures work signals throughout the day into ~/.agile-companion/today-activity.log
The agile companion skill reads this at standup and EOD.

Works as a standalone daemon OR as a VS Code extension backend.
Run: python3 ide-activity-watcher.py --config ~/.agile-companion/team-config.yml

Signal types captured (filtered by team-config.yml):
  - File saves (via inotify/FSEvents/ReadDirectoryChanges)
  - Test runs (pytest, jest, go test output parsing)
  - Build events (make, npm run build, cargo build)
  - Notebook runs (Jupyter kernel execution events)
  - Model training (torch/tensorflow output patterns)
  - Time-in-file (inferred from file save intervals)
  - Commits (via git hook, not this script)
"""

import os
import sys
import json
import time
import argparse
import subprocess
from datetime import datetime, date
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

# ── Config ────────────────────────────────────────────────────────────

DEFAULT_CONFIG = {
    "ide_signals": {
        "file_saves": {"enabled": True, "weight": "low", "min_session_minutes": 10},
        "test_runs": {"enabled": True, "weight": "medium", "capture_pass_fail": True},
        "builds": {"enabled": False, "weight": "low"},
        "notebook_runs": {"enabled": True, "weight": "high", "capture_cell_count": True},
        "model_training": {"enabled": True, "weight": "high", "capture_duration": True},
        "time_in_file": {"enabled": True, "weight": "low", "deep_work_threshold_minutes": 25},
    }
}

LOG_DIR = Path.home() / ".agile-companion"
TODAY = date.today().isoformat()
ACTIVITY_LOG = LOG_DIR / "today-activity.log"
COMMIT_LOG = LOG_DIR / "today-commits.log"


def load_config(config_path=None):
    """Load team config, fall back to defaults."""
    if config_path and Path(config_path).exists() and yaml:
        with open(config_path) as f:
            team_config = yaml.safe_load(f)
        return team_config.get("ide_signals", DEFAULT_CONFIG["ide_signals"])
    return DEFAULT_CONFIG["ide_signals"]


def write_signal(signal_type, data):
    """Append a signal entry to today's activity log."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    entry = {
        "date": TODAY,
        "time": datetime.now().strftime("%H:%M"),
        "type": signal_type,
        **data
    }
    with open(ACTIVITY_LOG, "a") as f:
        f.write(json.dumps(entry) + "\n")


def read_today_activity():
    """Return today's activity as a list of signal entries."""
    if not ACTIVITY_LOG.exists():
        return []
    entries = []
    with open(ACTIVITY_LOG) as f:
        for line in f:
            try:
                entry = json.loads(line.strip())
                if entry.get("date") == TODAY:
                    entries.append(entry)
            except json.JSONDecodeError:
                continue
    return entries


def summarize_for_companion(config=None):
    """
    Produce a human-readable summary of today's IDE activity.
    This is what the companion reads at standup and EOD.
    Returns a dict with signal summaries by weight.
    """
    if config is None:
        config = DEFAULT_CONFIG["ide_signals"]

    entries = read_today_activity()
    if not entries:
        return {"summary": "No IDE activity logged today.", "signals": []}

    signals = []

    # ── Commits (from git hook log, not this script) ──────────────────
    if COMMIT_LOG.exists():
        commits = []
        with open(COMMIT_LOG) as f:
            for line in f:
                if line.startswith(TODAY):
                    parts = line.strip().split(" | ")
                    if len(parts) >= 4:
                        commits.append({
                            "time": parts[0].split(" ")[1],
                            "repo": parts[1],
                            "hash": parts[2],
                            "message": parts[3]
                        })
        if commits:
            signals.append({
                "type": "commits",
                "weight": "high",
                "count": len(commits),
                "items": commits,
                "summary": f"{len(commits)} commit{'s' if len(commits)>1 else ''}: " +
                           ", ".join(c["message"][:50] for c in commits[:3])
            })

    # ── File saves ────────────────────────────────────────────────────
    save_cfg = config.get("file_saves", {})
    if save_cfg.get("enabled", True):
        saves = [e for e in entries if e["type"] == "file_save"]
        if saves:
            # Infer deep work sessions from save clusters
            files_touched = list(set(e.get("file", "") for e in saves))
            deep_work = [e for e in entries if e["type"] == "deep_work_session"]
            summary = f"Active in {len(files_touched)} file(s)"
            if deep_work:
                summary += f" — {len(deep_work)} deep work session(s)"
            signals.append({
                "type": "file_saves",
                "weight": save_cfg.get("weight", "low"),
                "count": len(saves),
                "files": files_touched[:5],
                "deep_work_sessions": len(deep_work),
                "summary": summary
            })

    # ── Test runs ─────────────────────────────────────────────────────
    test_cfg = config.get("test_runs", {})
    if test_cfg.get("enabled", True):
        tests = [e for e in entries if e["type"] == "test_run"]
        if tests:
            passed = sum(1 for t in tests if t.get("result") == "pass")
            failed = sum(1 for t in tests if t.get("result") == "fail")
            signals.append({
                "type": "test_runs",
                "weight": test_cfg.get("weight", "medium"),
                "count": len(tests),
                "passed": passed,
                "failed": failed,
                "summary": f"{len(tests)} test run(s) — {passed} passed, {failed} failed"
            })

    # ── Notebook runs ─────────────────────────────────────────────────
    nb_cfg = config.get("notebook_runs", {})
    if nb_cfg.get("enabled", True):
        notebooks = [e for e in entries if e["type"] == "notebook_run"]
        if notebooks:
            total_cells = sum(e.get("cells_executed", 0) for e in notebooks)
            nb_names = list(set(e.get("notebook", "") for e in notebooks))
            signals.append({
                "type": "notebook_runs",
                "weight": nb_cfg.get("weight", "high"),
                "count": len(notebooks),
                "notebooks": nb_names,
                "total_cells": total_cells,
                "summary": f"{len(notebooks)} notebook run(s) across: " +
                           ", ".join(Path(n).name for n in nb_names[:3] if n)
            })

    # ── Model training ────────────────────────────────────────────────
    ml_cfg = config.get("model_training", {})
    if ml_cfg.get("enabled", True):
        trains = [e for e in entries if e["type"] == "model_training"]
        if trains:
            total_min = sum(e.get("duration_minutes", 0) for e in trains)
            signals.append({
                "type": "model_training",
                "weight": ml_cfg.get("weight", "high"),
                "count": len(trains),
                "total_minutes": total_min,
                "summary": f"{len(trains)} training run(s), ~{total_min}min total"
            })

    # ── Sort by weight ────────────────────────────────────────────────
    weight_order = {"high": 0, "medium": 1, "low": 2}
    signals.sort(key=lambda s: weight_order.get(s.get("weight", "low"), 2))

    # ── Prose summary ─────────────────────────────────────────────────
    high = [s["summary"] for s in signals if s.get("weight") == "high"]
    medium = [s["summary"] for s in signals if s.get("weight") == "medium"]

    if high:
        prose = "Today's work evidence: " + "; ".join(high)
        if medium:
            prose += ". Also: " + "; ".join(medium)
    elif medium:
        prose = "Some activity logged: " + "; ".join(medium)
    else:
        prose = "Light activity logged today."

    return {"summary": prose, "signals": signals}


# ── VS Code Extension Interface ───────────────────────────────────────
# VS Code extensions call these functions via subprocess or JSON-RPC.
# Install the companion VS Code extension to enable rich signal capture.

def handle_vscode_event(event_json):
    """
    Called by VS Code extension when a signal event occurs.
    Event format: {"type": "file_save|test_run|notebook_run|...", ...}
    """
    try:
        event = json.loads(event_json)
        signal_type = event.pop("type", "unknown")
        write_signal(signal_type, event)
        return {"status": "ok"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


# ── File watcher (standalone daemon mode) ─────────────────────────────

def watch_directory(watch_path, config):
    """
    Lightweight file watcher using polling (no system dependencies).
    For richer signal capture, use the VS Code extension instead.
    """
    print(f"Watching: {watch_path}")
    print(f"Activity log: {ACTIVITY_LOG}")
    print("Press Ctrl+C to stop.\n")

    seen = {}
    file_open_times = {}

    try:
        while True:
            for root, dirs, files in os.walk(watch_path):
                # Skip hidden dirs, node_modules, __pycache__, .git
                dirs[:] = [d for d in dirs if not d.startswith('.')
                           and d not in ('node_modules', '__pycache__', 'venv', '.venv')]

                for fname in files:
                    # Only watch code files
                    if not any(fname.endswith(ext) for ext in
                               ['.py', '.ipynb', '.R', '.sql', '.js', '.ts',
                                '.go', '.rs', '.java', '.scala', '.jl']):
                        continue

                    fpath = os.path.join(root, fname)
                    try:
                        mtime = os.path.getmtime(fpath)
                    except OSError:
                        continue

                    if fpath in seen and seen[fpath] != mtime:
                        # File was modified
                        rel_path = os.path.relpath(fpath, watch_path)
                        write_signal("file_save", {"file": rel_path})

                        # Deep work detection
                        if fpath in file_open_times:
                            duration = (time.time() - file_open_times[fpath]) / 60
                            threshold = config.get("time_in_file", {}).get(
                                "deep_work_threshold_minutes", 25)
                            if duration >= threshold:
                                write_signal("deep_work_session", {
                                    "file": rel_path,
                                    "duration_minutes": round(duration)
                                })
                                file_open_times[fpath] = time.time()  # reset
                        else:
                            file_open_times[fpath] = time.time()

                    seen[fpath] = mtime

            time.sleep(5)  # poll every 5 seconds

    except KeyboardInterrupt:
        print("\nWatcher stopped.")


# ── Pytest plugin (auto-captures test results) ────────────────────────
# Add to conftest.py: from agile_companion_watcher import pytest_plugin
# Or install as pytest plugin: pip install agile-companion-pytest

class AgileCompanionPytestPlugin:
    """Pytest plugin — auto-log test results to activity log."""

    def pytest_runtest_logreport(self, report):
        if report.when == "call":
            write_signal("test_run", {
                "test": report.nodeid,
                "result": "pass" if report.passed else "fail",
                "duration_seconds": round(report.duration, 2)
            })


# ── Jupyter kernel watcher ────────────────────────────────────────────
# Call from Jupyter: from agile_companion_watcher import log_notebook_run

def log_notebook_run(notebook_path, cells_executed, kernel_name="python3"):
    """Call this from a Jupyter post-execution hook to log notebook runs."""
    write_signal("notebook_run", {
        "notebook": str(notebook_path),
        "cells_executed": cells_executed,
        "kernel": kernel_name
    })


def log_model_training(framework, duration_minutes, metadata=None):
    """Call from training scripts to log model training events."""
    write_signal("model_training", {
        "framework": framework,
        "duration_minutes": duration_minutes,
        **(metadata or {})
    })


# ── CLI ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="agile-companion IDE activity watcher")
    parser.add_argument("--config", help="Path to team-config.yml")
    parser.add_argument("--watch", help="Directory to watch for file saves")
    parser.add_argument("--summary", action="store_true",
                        help="Print today's activity summary and exit")
    parser.add_argument("--vscode-event", help="Handle a VS Code event (JSON string)")
    args = parser.parse_args()

    config = load_config(args.config)

    if args.summary:
        result = summarize_for_companion(config)
        print(result["summary"])
        for s in result["signals"]:
            print(f"  [{s['weight'].upper()}] {s['summary']}")
        sys.exit(0)

    if args.vscode_event:
        result = handle_vscode_event(args.vscode_event)
        print(json.dumps(result))
        sys.exit(0)

    if args.watch:
        watch_directory(args.watch, config)
    else:
        # Default: print summary
        result = summarize_for_companion(config)
        print(result["summary"])
