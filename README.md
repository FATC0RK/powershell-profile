

# 🎨 PowerShell Profile (Pretty PowerShell)

A stylish and functional PowerShell profile that looks and feels almost as good as a Linux terminal.

## ⚡ One Line Install (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```
irm "https://raw.githubusercontent.com/FATC0RK/powershell-profile/refs/heads/main/setup.ps1" | iex
```
🚨MAY NOT WORK BECAUSE IT IS NOT SIGNED BY A CERTIFICATE AUTHORITY🚨 <br>
🚨IF IT DOESN'T WORK JUST COPY THE CODE OF `Microsoft.PowerShell_profile.ps1` INTO YOUR OWN `$profile` AND DELETE THE `Update-Profile` FUNCTION🚨

## Customize this profile

**Do not make any changes to the `Microsoft.PowerShell_profile.ps1` file**, since it's hashed and automatically overwritten by any commits to this repository.

After the profile is installed and active, run the `Edit-Profile` function to create a separate profile file for your current user. Make any changes and customizations in this new file named `profile.ps1`.

Now, enjoy your enhanced and stylish PowerShell experience! 🚀
