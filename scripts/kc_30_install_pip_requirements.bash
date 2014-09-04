#!/bin/sh -u

# scripts/kc_30_install_pip_requirements.sh

# ============================
# EXTEND ENVIRONMENT VARIABLES
. /vagrant/scripts/01_environment_vars.sh
# ============================

install_info "install_pip_requirements"

cd $KOBOCAT_PATH
. /usr/local/bin/virtualenvwrapper.sh
workon kc

if [ "$VIRTUAL_ENV" = "" ]; then
	echo "Virtualenv wasnot activated properly"
	exit 1;
fi

# savReaderWriter
[ $( pip freeze | grep savReaderWriter | wc -l ) = "0" ] && {
	# this is a large dependency
	# installing seperately to get it over with
	pip install https://bitbucket.org/fomcl/savreaderwriter/downloads/savReaderWriter-3.3.0.zip#egg=savreaderwriter;
}

# for unified database configurations
pip install dj-database-url

pip install -r $KOBOCAT_PATH/requirements/common.pip

sudo -u root pip install pybamboo