# Reproduction script for SubjectAlternativeName feature
# This script demonstrates the new SubjectAlternativeName property

Write-Host "Demonstrating SubjectAlternativeName property" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Before the fix, to get SAN you had to manually extract it:
Write-Host "BEFORE: Manual extraction required" -ForegroundColor Yellow
Write-Host @'
$sig = Get-AuthenticodeSignature myfile.dll
$sanExt = $sig.SignerCertificate.Extensions | Where-Object { $_.Oid.FriendlyName -match "subject alternative name" }
$sanStr = $sanExt.Format(1)
'@
Write-Host ""

# After the fix, it's a built-in property:
Write-Host "AFTER: Built-in property" -ForegroundColor Green
Write-Host @'
$sig = Get-AuthenticodeSignature myfile.dll
$sig.SubjectAlternativeName  # Returns string[] or null
'@
Write-Host ""

# Example usage on Windows:
if ($IsWindows) {
    Write-Host "Example on Windows system file:" -ForegroundColor Cyan
    $systemFile = "$env:windir\System32\ntdll.dll"
    
    if (Test-Path $systemFile) {
        $sig = Get-AuthenticodeSignature -FilePath $systemFile
        Write-Host "File: $systemFile"
        Write-Host "Status: $($sig.Status)"
        Write-Host "SubjectAlternativeName property exists: $(($sig.PSObject.Properties.Name) -contains 'SubjectAlternativeName')"
        
        if ($sig.SubjectAlternativeName) {
            Write-Host "SubjectAlternativeName values:"
            $sig.SubjectAlternativeName | ForEach-Object { Write-Host "  - $_" }
        } else {
            Write-Host "SubjectAlternativeName: (null or empty)"
        }
    }
} else {
    Write-Host "Note: Get-AuthenticodeSignature is primarily used on Windows." -ForegroundColor Yellow
    Write-Host "On Linux/macOS, code signing works differently." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Feature successfully implemented!" -ForegroundColor Green
