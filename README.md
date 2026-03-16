# LanSchool Removal / Reinstall Flow

## Overview
This process is used for a given room to identify devices, validate uninstall success, validate registry cleanup, and build the final reinstall collection.

Devices that fail at any validation point are written to `Manual_Touch.csv` for manual remediation, with a separate column sharing the fail location. After correction, `Manual_Touch.csv` can be used to scope the LanSchool reinstall deployment.

Devices that pass all validation steps are written to `Final_Reinstall_Collection.csv` and can be used to scope the LanSchool reinstall deployment.

After that, `4_Final_Cleanup.bat` is used to clean up any files from the workflow.

---

## Script Names
- `1_Post_Uninstall_Check.bat`
- `2_RegRemoval.bat`
- `3_Post_RegRemoval_Check.bat`
- `4_Final_Cleanup.bat`

---

## Network Share
All reporting files are written to:

\\fileserver\share\LanSchoolReporting\%REPORT_NAME%.csv

---

## Files Generated
### Success / progress files
- `Uninstall_Success.csv`
- `Final_Reinstall_Collection.csv`

### Manual remediation file
- `Manual_Touch.csv`

---

## Process Flow

### Step 1: Run LanSchool uninstall for the room (use the room as the collection to scope)
Run the LanSchool uninstall against the scoped room collection.

---

### Step 2: After uninstall completes, run `1_Post_Uninstall_Check.bat`
This is to validate whether LanSchool artifacts are still present. Scope that same room collection used earlier in step 1.

This script checks for the following LanSchool artifacts:

C:\Program Files (x86)\LanSchool\Teacher.exe [Teacher install file]

C:\Program Files (x86)\LanSchool\Student.exe [Student install file]

#### Behavior
- If either artifact still exists:
  - the device is written to `Manual_Touch.csv`
  - `FailLocation` is set to `LanSchool App Uninstall`

- If neither artifact exists:
  - the device is written to `Uninstall_Success.csv`

#### Purpose
This step confirms whether the application uninstall actually removed the LanSchool install artifacts.

---

### Step 3: Run `2_RegRemoval.bat`
Use the devices listed in:

\\fileserver\share\LanSchoolReporting\Uninstall_Success.csv

Build an SCCM collection from those devices and scope `2_RegRemoval.bat` to that collection.

This script deletes the LanSchool installer and application registry keys.

#### Registry keys removed
HKLM\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A

HKCU\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A

HKLM\SOFTWARE\LanSchool

HKLM\SOFTWARE\WOW6432Node\LanSchool

It also targets both 32-bit and 64-bit views where applicable.

#### Purpose
This step clears remaining LanSchool registry presence before reinstall.

---

### Step 4: Run `3_Post_RegRemoval_Check.bat` — Post-registry-removal validation

Use the devices listed in:

\\fileserver\share\LanSchoolReporting\Uninstall_Success.csv

Use that same SCCM collection from those devices and scope `3_Post_RegRemoval_Check.bat` to that collection.

This script validates whether the following registry keys still exist:

HKLM\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A

HKCU\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A

HKLM\SOFTWARE\LanSchool

HKLM\SOFTWARE\WOW6432Node\LanSchool

#### Behavior
- If the registry keys do not exist:
  - the device is written to `Final_Reinstall_Collection.csv`

- If any registry key still exists:
  - the device is written to `Manual_Touch.csv`
  - `FailLocation` is set to `Registry Removal`

#### Purpose
This step confirms whether registry cleanup succeeded.

---

## Outcome

### Devices in `Final_Reinstall_Collection.csv`
These devices:
- successfully uninstalled LanSchool
- successfully cleared the LanSchool registry presence
- are ready to be used as the SCCM collection for reinstall

### Devices in `Manual_Touch.csv`
These devices failed somewhere in the process and require manual remediation before being used to scope the new reinstall.

Possible failure locations:
- `LanSchool App Uninstall`
- `Registry Removal`

---

## Final Step: Run `4_Final_Cleanup.bat` — Post-reinstall cleanup

Removes these files after update completes:

`Manual_Touch.csv`

`Uninstall_Success.csv`

`Final_Reinstall_Collection.csv`

---

## End-to-end Summary
1. Run LanSchool uninstall for the target room.
2. Run `1_Post_Uninstall_Check.bat`.
   - If LanSchool artifacts still exist, device goes to `Manual_Touch.csv`.
   - If uninstall looks clean, device goes to `Uninstall_Success.csv`.
3. Build an SCCM collection from `Uninstall_Success.csv`.
4. Run `2_RegRemoval.bat` against that collection to remove registry keys.
5. Run `3_Post_RegRemoval_Check.bat` against that same scoped set.
   - If registry is cleared, device goes to `Final_Reinstall_Collection.csv`.
   - If registry remains, device goes to `Manual_Touch.csv`.
6. Use `Final_Reinstall_Collection.csv` to build the final reinstall collection and install the new version.
7. Manually remediate anything listed in `Manual_Touch.csv` and then, after resolution, add that list to the new final reinstall collection.
8. Run `4_Final_Cleanup.bat` to remove the reporting files so the workflow is cleaned up for future LanSchool update runs.

---

## Notes
- `Manual_Touch.csv` is the catch-all list for devices that fail validation.
- `Final_Reinstall_Collection.csv` is the final clean set for reinstall targeting.
- `Uninstall_Success.csv` is only the intermediate collection used between uninstall validation and registry cleanup.
