#!/bin/bash - 
#===============================================================================
#
#          FILE: install.sh
# 
#         USAGE: ./install.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ShadowStar, <orphen.leiliu@gmail.com>
#  ORGANIZATION: Gmail
#       CREATED: 05/22/2018 20:04:17
#   LAST CHANGE:05/22/2018 20:16:35
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

DIR="$(dirname "$(realpath $0)")"

if [ "${HOME}" == "$(dirname "${DIR}")" ]; then
	DIR="$(basename ${DIR})"
fi

[ ! -e ${HOME}/.vim ] && ln -sv ${DIR} ${HOME}/.vim
ln -sv ${DIR}/vimrc ${HOME}/.vimrc

