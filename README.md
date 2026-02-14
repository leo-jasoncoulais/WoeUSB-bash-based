# Windows Bootable USB Creator (CLI)

This Bash script automates the creation of a bootable Windows installation USB drive from a mounted Windows source (ISO or folder) on Linux. It specifically handles **FAT32** limitations by automatically splitting the `install.wim` file.

## ⚠️ Warning

This script uses `sudo` and performs partition manipulation via `gdisk`. **All data on the target drive will be permanently erased.** Double-check your target device identifier before execution.

## 🚀 Features

* **Auto-Dependency Install**: Installs required tools (`gdisk`, `wimtools`, `util-linux`) via `apt`.
* **Validation**: Checks if the source contains a valid Windows image (`install.wim` or `install.esd`).
* **GPT Partitioning**: Automatically initializes the target drive with a GPT table.
* **WIM Splitting**: Splits large `install.wim` files (over 4GB) into `.swm` chunks to ensure UEFI compatibility on FAT32 partitions.

## 📋 Prerequisites

* A Debian/Ubuntu-based system (uses `apt` package manager).
* **Root** privileges (sudo).
* A mounted Windows ISO or an extracted Windows source folder.

## 🛠️ Usage

### Syntax

```bash
chmod +x woeusb.bash
sudo ./woeusb.bash <windows_iso_path> <target_disk>

```

### Example

If your Windows ISO is `windows.iso` and your USB drive is identified as `/dev/sdb`:

```bash
./woeusb.bash windows.iso /dev/sdb
```

## 🔍 Technical Workflow

| Step | Action Taken |
| --- | --- |
| **Dependencies** | Installs `gdisk` and `wimlib-imagex`. |
| **Safety Check** | Ensures the second argument is a raw disk (e.g., `/dev/sdb`) and not a partition (e.g., `/dev/sdb1`). |
| **Partitioning** | Sets up a GPT table and creates an 8GB FAT32 partition. |
| **Copying** | Uses `wimsplit` to segment the installer at 4GB intervals. |
