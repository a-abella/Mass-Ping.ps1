# Mass-Ping.ps1
Mass Ping utility. Ping lists of hosts to monitor network status.

Select target PCs from source files passed as parameters, from Organization Units, or from manual entry. Parses ping output and displays host status.

Organizational Unit graphical selection dialog provided by MicaH's Choose-ADOrganizationaUnit function. https://itmicah.wordpress.com/2016/03/29/active-directory-ou-picker-revisited/

## Requirements ##
1. ActiveDirectory Powershell module (available in Windows RSAT).
2. MicaH's ChooseADOrganizationalUnit.ps1 file for dotsourcing. https://itmicah.wordpress.com/2016/03/29/active-directory-ou-picker-revisited/

Read through script comments for the lines that must be edited to suit your environment.
