if [ -d "$ENKETO_EXPRESS_REPO_DIR" ]; then
	echo "enketo-express code is already cloned"
else
	git clone https://github.com/kobotoolbox/enketo-express.git $ENKETO_EXPRESS_REPO_DIR
fi

cd $ENKETO_EXPRESS_REPO_DIR

echo 'ensuring submodules are updated'
git submodule update --init --recursive

echo 'building enketo api key file'
CONFIG_FILE_PATH="$ENKETO_EXPRESS_REPO_DIR/config/config.json"
python -c "import json;f=open('$CONFIG_FILE_PATH');config=json.loads(f.read());config['linked form and data server']['server url']='$KOBOCAT_URL';f2=open('$CONFIG_FILE_PATH~','w');f2.write(json.dumps(config, indent=4))"
mv $CONFIG_FILE_PATH~ $CONFIG_FILE_PATH
