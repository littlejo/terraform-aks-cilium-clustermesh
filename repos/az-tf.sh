RG=$(az group list | jq -r '.[0].name')
LC=$(az group list | jq -r '.[0].location')

echo "resource_group_name = \"$RG\""
echo "location            = \"$LC\""
