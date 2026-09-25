# win-scripts

A curated collection of lightweight, reliable Windows batch and automation scripts designed for system maintenance, disk optimization, and power-user workflows.

---

## 📂 Available Scripts

| Script | Target OS | Description | Requires Admin |
|---|---|---|---|
| `clean.bat` | Windows 10 / 11 | Deep system disk cleanup optimized for small SSDs and developer workstations | **Yes** |

---

## 🛠️ Script Details

### `clean.bat` — Windows Power-User Cleanup Script
A thorough cleanup utility specifically tuned for tight storage environments (e.g., 32 GB–64 GB system drives) and developer machines where build artifacts and system logs accumulate rapidly.

#### What it cleans:
1. **Windows Update Cache:** Safely stops `wuauserv` & `bits`, flushes downloaded update installers in `C:\Windows\SoftwareDistribution\Download`, and restarts the services.
2. **Delivery Optimization Files:** Clears peer-to-peer Windows Update cache objects via PowerShell.
3. **Temporary Files & Caches:** 
   - User temporary files (`%temp%`) and Windows system temp.
   - DirectX Shader Cache.
   - Windows Prefetch cache.
4. **Developer & Servicing Logs:** Clears accumulated CBS (Component-Based Servicing) and DISM log files.
5. **DISM Component Store (`WinSxS`):** Executes safe component cleanup (`/startcomponentcleanup`) to purge superseded update components without breaking rollback stability.
6. **Built-in Disk Cleanup (`cleanmgr`):**
   - **First Run:** Detects if preset `#1` is unconfigured and launches the native Disk Cleanup UI to let you pick categories to clean.
   - **Subsequent Runs:** Reuses your saved configuration automatically with an optional 3-second prompt if you wish to change your choices.
7. **Recycle Bin:** Empties all items permanently across all user profiles.

#### Key Features:
- **Real-time Metric Tracking:** Captures available disk space before and after the cleanup using 64-bit byte arithmetic (no integer-overflow bugs).
- **Formatted Summary:** Outputs raw byte counts alongside highlighted human-readable values (e.g., `[ +3.42 GB ]` in green).
- **Admin Privilege Verification:** Automatically verifies elevated permissions before running.

---

## 🚀 How to Run

### Method 1: File Explorer (Easiest)
1. Navigate to your cloned or downloaded `win-scripts` directory.
2. Right-click on `clean.bat` (or any script requiring elevation).
3. Select **"Run as administrator"**.
4. If prompted by User Account Control (UAC), click **Yes**.

### Method 2: Elevated Command Prompt or PowerShell
1. Press `Win + X` and choose **Terminal (Admin)**, **Command Prompt (Admin)**, or **PowerShell (Admin)**.
2. Navigate to the repository folder:
   ```cmd
   cd path\to\win-scripts
   ```
3. Run the desired script:
   ```cmd
   clean.bat
   ```

---

## ⚠️ Notes & First-Time Setup

> [!NOTE]  
> **Disk Cleanup Setup (`cleanmgr`):**  
> On the first run, the script will pause and launch the Windows Disk Cleanup settings window. Check the boxes for the items you want cleaned (e.g., *Previous Windows installations*, *Thumbnails*, *Temporary files*) and click **OK**. The script saves this preset and runs it automatically on subsequent executions.

---

## 💻 System Compatibility

- **Windows 11:** Fully supported (all versions/builds).
- **Windows 10:** Fully supported (all versions/builds).
- **Windows 7:** Partial support (DISM component cleanup and Delivery Optimization cmdlets will be skipped silently due to OS limitations).
