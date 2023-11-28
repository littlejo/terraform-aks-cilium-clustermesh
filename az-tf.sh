RG=$AZURE_RESOURCE_GROUP
LC=$(az group list | jq -r '.[0].location')

echo "resource_group_name = \"$RG\""
echo "location            = \"$LC\""
