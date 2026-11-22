Write-Host "Hi There!"

Connect-AzAccount -Identity
New-AzStorageAccount -Name examplestorage -ResourceGroupName example-test -Location centralus -SkuName Standard_GRS

docker version

Write-Host "Bye There!"