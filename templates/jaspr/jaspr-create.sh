# Parses 'jaspr.create' as json and calls 'jaspr create' with the appropriate arguments.

CONFIG_FILE=".idx/.jaspr"
CONFIG_CONTENT=$(cat "$CONFIG_FILE")
MODE=$(echo "$CONFIG_CONTENT" | jq -r '.mode')
ROUTING=$(echo "$CONFIG_CONTENT" | jq -r '.routing')
FLUTTER=$(echo "$CONFIG_CONTENT" | jq -r '.flutter')
BACKEND=$(echo "$CONFIG_CONTENT" | jq -r '.backend')

rm "$CONFIG_FILE"
rm ".idx/jaspr-create.sh"

ARGS="--mode=${MODE} --routing=${ROUTING} --flutter=${FLUTTER} --backend=${BACKEND}"
dart pub global activate jaspr_cli
jaspr create $ARGS --no-pub-get .idx/project
mv .idx/project/* .
rm -rf .idx/project
dart pub get
