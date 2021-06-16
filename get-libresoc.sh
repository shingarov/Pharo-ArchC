#!/bin/sh

echo "Please follow the manual instructions inside this file."

# There are two possible scenarios depending on what you want.
#
# If you only want the OpenPOWER pseudocode in order to process it in
# Smalltalk, then:
#    mkdir libresoc
#    cd libresoc
#    git clone URL: https://git.libre-soc.org/git/openpower-isa.git
#    export LIBRESOC=`pwd`

# If you want a real LibreSOC installation, then:
#    mkdir libresoc
#    cd libresoc
#    git clone URL: https://git.libre-soc.org/git/dev-env-setup.git
# and use the automated scripts in there.
# Alternatively, you can follow the steps explained in the section "Quick
# peek at the code" on the title page of libre-soc.org.
