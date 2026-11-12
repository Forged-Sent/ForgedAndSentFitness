@{
    RootModule = 'Forge.Runtime.psm1'
    ModuleVersion = '2.0.0'
    GUID = '20784930-ff6a-435d-b208-c50a59112a25'
    Author = 'Personal engineering environment'
    Description = 'Local, discoverable PowerShell workspace for Forged & Sent.'
    PowerShellVersion = '7.5'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @('helpme','dash','keys','fs','forge','reloadforge','ph','ptest','jump','mark','marks','unmark','z','back','projects','mkcd','up','qa','ff','ftext','ll','todo','todos','done','note','notes','recent-notes','session','focus','recent-command','port','err','pathcheck','refreshpath','envshow','netcheck','sshgo','jview','cliptools','hash','comparefile','tempwork','trash','gst','gad','gmsg','gpsh')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{ PSData = @{ Tags = @('productivity','Windows','Flutter') } }
}
