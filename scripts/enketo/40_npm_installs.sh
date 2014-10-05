echo "npm installs"

cd $ENKETO_EXPRESS_REPO_DIR
if [ $ENKETO_EXPRESS_USE_NODE_ENV = "true" ] && [ ! -d "$ENKETO_EXPRESS_NODE_ENV" ]; then
    nodeenv $ENKETO_EXPRESS_NODE_ENV
    . $ENKETO_EXPRESS_NODE_ENV/bin/activate
fi

npm install -g grunt-cli nodemon mocha bower

# remove node_modules if exists because npm builds can be system-specific
if [ -n $ENKETO_CLEAR_MODULES ]; then
	rm -rf $ENKETO_EXPRESS_REPO_DIR/node_modules
fi

npm install 

if [ $(whoami) = "root" ]; then
    npm install pm2@latest -g --unsafe-perm
else
    npm install pm2@latest -g
fi

bower install --allow-root
