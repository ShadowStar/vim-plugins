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
#   LAST CHANGE:05/22/2018 21:29:27
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

DIR="$(dirname "$(realpath $0)")"

if [ "${HOME}" == "$(dirname "${DIR}")" ]; then
	DIR="$(basename ${DIR})"
fi

function linkfile ()
{
	[ ! -e ${2} ] && ln -sfv ${1} ${2} || echo "${2} existed"
}

linkfile ${DIR} ${HOME}/.vim
linkfile ${DIR}/vimrc ${HOME}/.vimrc

