#!/usr/bin/env python3
import os
import argparse
import re
import subprocess


def get_process_user(pid):
    """Retrieve the user of a given process."""
    cmd = f"ps -o user= -p {pid}"
    result = subprocess.check_output(cmd, shell=True).decode('utf-8').strip()
    return result

def get_gpu_processes():
    """Get list of processes using the GPU."""
    cmd = "nvidia-smi pmon -c 1 -s u"
    result = subprocess.check_output(cmd, shell=True).decode('utf-8')
    processes = []
    for line in result.splitlines()[2:]:
        if not line.startswith("#"):
            try:
                pid = int(line.split()[1])
                processes.append(pid)
            except ValueError:
                continue
    return processes

def get_process_ancestry(pid):
    """Recursively retrieve the ancestry of a process."""
    cmd = f"pstree -s {pid}"
    result = subprocess.check_output(cmd, shell=True).decode('utf-8')
    return result.strip()

def is_orphaned(tree):
    """Check if the process is orphaned based on the ancestry tree."""
    # This is a hack specific for the multiprocessing gpu setup we are using
    print([proc for proc in tree.split("---")])
    true_count = 0
    keys = ["systemd", "python3"]
    procs = tree.split("---")
    for proc in procs:
        for key in keys:
            if key in proc:
                true_count +=1
                break

    return true_count == len(procs) 

def main():
    parser = argparse.ArgumentParser(description="Kill orphaned GPU processes.")
    parser.add_argument('-n', action='store_true', help="Dry run, show processes but don't kill them.")
    args = parser.parse_args()

    current_user = os.getlogin()

    for pid in get_gpu_processes():
        process_user = get_process_user(pid)
        if process_user != current_user:
            continue  # Skip processes that are not started by the current user

        tree = get_process_ancestry(pid)
        print(f"Process Tree for PID {pid}: {tree}")
        if is_orphaned(tree):
            if args.n:
                print(f"Would kill orphaned process {pid}.")
            else:
                print(f"Killing orphaned process {pid}...")
                subprocess.run(f"kill -9 {pid}", shell=True)

if __name__ == "__main__":
    main()

