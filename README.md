# file-watcher-backup

A Bash-based script that monitors specified files for changes at regular time intervals and creates up to three rotating backups for each modified file.

## Description

This script takes two command-line arguments:

1. A **time interval** (in seconds)
2. A **file list**, which is a text file containing file names to be monitored (one file name per line)

At every specified time interval, the script checks each listed file to determine if it has been modified since the last check. If a modification is detected, a backup is created. The script keeps up to three backups for each file, rotating them to always preserve the three most recent versions.

Each time a new backup is made, a message is printed to inform the user.

Additionally, after every **10 cycles** (i.e., after `10 * time_interval` seconds), the script **re-reads the file list** to detect any changes. If a file that was previously being monitored is no longer listed:

- The user is asked whether they want to **restore the most recent backup**.
- Regardless of the answer, the script will **remove the associated backup files** to free up space and maintain consistency.

## Features

- Monitors multiple files listed in a text file
- Checks for changes at a user-defined interval
- Automatically creates and rotates up to 3 backups per file
- Prompts the user to restore removed files from backup
- Re-scans the file list every 10 intervals to track additions or removals

## Compatibility

### macOS

The script `backupScriptMacOs.bash` is tailored specifically for macOS systems. It utilizes the `stat -f "%m"` command to retrieve the modification time of files, which is compatible with BSD-style `stat`, as found in macOS.

### Ubuntu/Linux

The original version, `backupScriptUbuntu.sh`, is designed for GNU/Linux environments. It uses the `stat -c "%Y"` command, which aligns with the GNU version of `stat`. While slightly older, this script is functionally equivalent to the macOS version.

## Usage macOs

```bash
./backupScriptMacOs.bash [time_interval] [file_list]
```

## Usage Ubuntu

```bash
./backupScriptUbuntu.bash [time_interval] [file_list]
```
