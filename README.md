**FileVault Logout Prompt**

This script will prompt users to logout in order to enable Filevault on computers managed by Jamf Pro. 

This script uses Bart Reardon's swiftDialog for user dialogs

https://github.com/bartreardon/swiftDialog

The script will perform a few checks and ask the user to log out to enable FileVault if needed when a Configuration Profile to enforce FileVault Disk Encription and escrow the Rceovery key to Jamf Pro has been installed on their computer. The script does the following:

- Checks if Recovery Key Escrow settings are present.  If not it exits.
- Checks if FileVault is enabled.  If it is, it exits.
- Checks if a user is logged in. If not, it exits.
- Checks if Swift Dialog is installed. If not, it installs it.
- Prompts the user to log out.
- If the user selects to log out, a confirmatiuon prompt is displayed with a time out to make sure any unsaved work is saved.
- If the User clicks on " Log Out Now" or the timeout expires, the current user is logged out.

The name of the organization can be set on line 34 of the script.

<img width="727" alt="Screenshot 2025-04-14 at 22 51 26" src="https://github.com/Sdelsaz/FileVault-Logout-Prompt/blob/main/Screenshot%201.png" />
<img width="727" alt="Screenshot 2025-04-14 at 22 51 39" src="https://github.com/Sdelsaz/FileVault-Logout-Prompt/blob/main/Screenshot%202.png" />
