#!/usr/bin/env python3

import os
import shutil
import time
import argparse
from datetime import datetime, timedelta


def delete_old_subdirectories(parent_dir, days=14, dry_run=False, recursive=False):
    now = time.time()
    cutoff = now - (days * 86400)  # 86400 seconds in a day

    for root, dirs, files in os.walk(parent_dir):
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            if os.path.isdir(dir_path):
                dir_mtime = os.path.getmtime(dir_path)
                if dir_mtime < cutoff:
                    print(
                        f"Would delete directory: {dir_path}"
                        if dry_run
                        else f"Deleting directory: {dir_path}"
                    )
                    if not dry_run:
                        try:
                            shutil.rmtree(dir_path)
                        except Exception as e:
                            print(f"Error: {e}")
        if not recursive:
            break


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Delete subdirectories older than a specified number of days."
    )
    parser.add_argument("path", type=str, help="The parent directory path.")
    parser.add_argument(
        "--days", type=int, default=14, help="The age threshold in days (default: 14)."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform a dry run without deleting directories.",
    )
    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Search for subdirectories recursively.",
    )

    args = parser.parse_args()

    delete_old_subdirectories(
        args.path, days=args.days, dry_run=args.dry_run, recursive=args.recursive
    )
