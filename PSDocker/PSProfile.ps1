Start-Transcript -Path ($env:HOME+'/pshistory.log') -Append
####################################

function Prompt{
  $item = Get-History -Count 1
  if(-not $item)
    {
      "[$($item.Id)] $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
      $host.UI.RawUI.WindowTitle = "$([environment]::UserDomainName)\$([System.Environment]::UserName)@$([environment]::MachineName)"
    } else {
      $diff = $item.EndExecutionTime-$item.StartExecutionTime
      $TotalMilliseconds =  [math]::round($diff.TotalMilliseconds)
      "[$($item.Id)][$TotalMilliseconds ms] $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
      $title = "[{0:HH:mm:ss,fff}]" -f [datetime]($diff.ticks)
      $host.UI.RawUI.WindowTitle = "$([environment]::UserDomainName)\$([System.Environment]::UserName)@$([environment]::MachineName) | Execution Time: {0}" -f $title
    }
}

Function ICC_ScriptLogger {
    [CmdletBinding()]
    param (
        $text,
        $errorlevel,
        [bool]$cluster
    )
    $Colour = switch -CaseSensitive ($errorlevel) {
        'i' {'Gray' }
        'I' {"white"}
        "w" {"Blue"}
        "W" {"Yellow"}
        "e" {"Red"}
        "E" {"Red"}
        "L" {"Green"}
        Default {"Cyan"}
    }
    $Time = get-date -format T
    if($Cluster) {
        $Text = "[{0}] [{1}] [C] [{2}]" -f $Time,$errorlevel,$text
    } else {
        $Text = "[{0}] [{1}] [{2}]" -f $Time,$errorlevel,$text
    }
        Write-Host $text -ForegroundColor  $Colour
}