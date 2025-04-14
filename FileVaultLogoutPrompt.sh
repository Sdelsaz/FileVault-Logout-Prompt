#!/bin/bash
##########################################################################################
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
##########################################################################################
#
# This script can be used to prompt users to log out/in after a FileVault Configuration profile has been installed on their mac. 
# The script will perform a few checks and ask the user to log out to enable FileVault if needed.
#
# - Checks if Recovery Key Escrow settings are present
# - Checks if FileVault is enabled
# - Checks if a user is logged in
# - Checks if Swift Dialog is installed
#
# If the user chooses to log out, a confirmation prompt appears with a timeout to ensure any unsaved work is saved. After the timeout elapes, the user is automatically logged out.
#
# Created by Sebastien Del Saz Alvarez 5th of January 2025
#
##########################################################################################
#
# This script uses Bart Reardon's swiftDialog for user dialogs
# https://github.com/bartreardon/swiftDialog
#
##########################################################################################
# Variables
User=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
Org="Example Inc."
Icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"
Banner="https://support.apple.com/content/dam/edam/applecare/images/en_US/psp/psp_heroes/psp-hero-banner-macos.image.large_2x.jpg"
Title="FileVault Disk Encryption"
Font="size=15,name=Apple SD Gothic Neo"
TitleFont="colour=black,font=$Font,shadow=1"
LogoutPrompt()
{
	dialog -s --title "$Title" --titlefont "$TitleFont" --message "Please log out and back in to enable FileVault Disk Encryption. FileVault Disk Encryption is required by **$Org** to ensure the security and compliance of your Mac. 

**IMPORTANT**: After clicking on 'Log Out Now' you will be logged out automatically. Please make sure to save any unsaved work before proceeding." --icon "$Icon" --overlayicon "caution" --messagefont "$Font" --button1text "Log Out Now" --button2text "Later" 
}
ConfirmationPrompt()
{
	dialog -s --title "$Title" --titlefont "$TitleFont" --message "**WARNING**: You will be logged out soon, Please save any unsaved work" --icon "$Icon" --overlayicon caution --messagefont "$Font" --button1text "Log Out Now" --button2text "Cancel" --timer 60
}
# Check if there are FileVault Recovery Key escrow settings present
echo "Checking if there are settings present to Escrow the FileVault Recovery Key"
EscrowSettings=$(defaults read '/Library/Managed Preferences/com.apple.security.FDERecoveryKeyEscrow.plist')
if [[ -z $EscrowSettings ]]
then
echo "No FileVault Escrow Settings Found, make sure a profile has been deployed and it contains FileVault Recovery Key Escrow settings. Exiting"
else
echo "Escrow Settings Found, checking if a user is logged in"
# Check if a user is logged in
if [[  -z "$User" ]] || [[ "$User" == "root" ]]
then
echo "No user logged in. Exiting"
else
echo "User $User is logged in."
# Check if FileVault is enabled
echo "Checking if FileVault is enabled"
FVstatus=$(fdesetup status)
# If FileVault is not enabled prompt the enduser to log out
if [[ $FVstatus == "FileVault is On." ]]
then
echo "FileVault is already ON, exiting"
# Update inventory
/usr/local/bin/jamf recon
else
echo "FileVault is off"
# Check if Swift Dialog is installed. if not, Install it
echo "Checking if SwiftDialog is installed"
if [[ -e "/usr/local/bin/dialog" ]]
then
echo "SwiftDialog is already installed"
else
echo "SwiftDialog Not installed, downloading and installing"
/usr/bin/curl https://github.com/swiftDialog/swiftDialog/releases/download/v2.5.5/dialog-2.5.5-4802.pkg -L -o /tmp/dialog-2.5.5-4802.pkg 
cd /tmp
/usr/sbin/installer -pkg dialog-2.5.5-4802.pkg -target /
fi
# Launch first logout prompt
echo "Prompting user to log out"
LogoutPrompt
case $? in
  0)
  echo "User clicked on 'Log Out Now'. Displaying Confirmation prompt"
# Launch logout confirmation prompt
ConfirmationPrompt
		case $? in
  0)
  echo "User clicked on 'Log Out Now'. logging user $User Out."
launchctl bootout gui/$(id -u "$User")
  ;;
  2)
  echo "User clicked on 'Cancel'"
  ;;
  4)
  echo "Confirmation prompt countdown elapsed. logging user $User Out."
launchctl bootout gui/$(id -u "$User")
  ;;
esac
  ;;
  2)
  echo "User clicked on 'Later'"
  ;;
 esac
fi
fi
fi
exit 0
