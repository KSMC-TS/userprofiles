# User Profiles
## Backup / Restore Script
### Used when migrating to new PCs

BR-UserProfile.ps1

*required args:*
- mode: options 'Backup' or 'Restore'
  - Backup - will back up user profile directories to a file share
  - Restore - restores user profile from backup 
  
- destination: enter file share path '\\server\share'


1. **Prepare backup share ahead of time**
    - Share should allow 'everyone' to R/W on share permissions
    - NTFS permissions should be: 
    ```
    - Domain admins (full control - This folder, subfolders, and files)
    - CREATOR OWNER (full control - subfolders and files only)
    - Everyone (special* Read permissions + Create Folders - this folder only)
    ```
    - This will ensure the public share is usable by all, but profile data is only accessible by the individual user (and admins)

2. **Drop a copy of this script on the file share.** Make sure NTFS permissions on script allow 'Everyone' to Read/Execute

3. Run Script to Backup: **run logged-on as user**
    
    - Commands to run (replace '\\BACKUP\SHARE' with share created above):
    
    ```
    powershell.exe -noexit -executionpolicy bypass -command "& \\BACKUP\SHARE\BR-UserProfile.ps1 -mode backup -destination '\\BACKUP\SHARE'"
    ```

4. Run script to Restore: **run logged-on as user**
    - Run on New PC, or after Reset/Autopilot setup
    - Commands to run (replace '\\BACKUP\SHARE' with share created above):
    
    ```
    powershell.exe -noexit -executionpolicy bypass -command "& \\BACKUP\SHARE\BR-UserProfile.ps1 -mode restore -destination '\\BACKUP\SHARE'"
    ```
        
   - **NOTE on restore operations:**
      - if connecting from Intune/AAD-joined device to a local AD file share: 
      
      Make sure to open the file share in an 'Explorer' window first, to authenticate the user, prior to running the script



*Features to add*
- built-in Auth mechanism for restoring without manual auth to share first
- progress bar for file transfers
- clearing cache content from Google/Firefox prior to backup
