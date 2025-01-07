Import-Module yaml
$yaml = Get-Content -Path "assets-and-connectivity_1.0.0.yaml"
$parentNode = $yaml.SelectSingleNode("//info")
$childNodes = $parentNode.GetChildNodes()
$node = $childNodes.SelectSingleNode("//summary")
Write-Host $parentNode.Value
Write-Host $node.Value