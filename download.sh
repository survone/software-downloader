#!/bin/bash

SAVE_BASE_PATH='/home/dao/smb4k/SERVER-NT3/D$/share/sys/Go/' # don't forget about trailing slash!
REJECT_LIST="Stub|tprsetup|dfmirage"




# creating hash
declare -A PROGRAMS
PROGRAMS=(
    ['http://www.piriform.com/ccleaner/download/slim//downloadfile']='ccleaner/'
    ['http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/latest/win32/ru/']='Mozilla/Firefox/'
    ['http://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/latest/win32/ru/']='Mozilla/Thunderbird/'
    ['http://www.tightvnc.com/download.php']='sys/ra/vnc/tight'
)

for url in "${!PROGRAMS[@]}"
do
    wget --continue --accept=exe,msi --reject-regex=$REJECT_LIST --no-parent --recursive --no-directories -nc --content-disposition --directory-prefix=$SAVE_BASE_PATH${PROGRAMS[$url]} $url
done

PROGRAMS=(
    ["adobe_flash.pl"]="Mozilla/ext.add/"
    ["dopdf.pl"]="Graph/pdf/doPDF/"
    ["fusioninventory-agent.pl"]="glpi/fusioninventory/agents/"
    ["jre.pl"]="java/JRE/"
    ["xnview.pl"]="Graph/XnView/"
)

for program in "${!PROGRAMS[@]}"
do
    perl $program --base=$SAVE_BASE_PATH${PROGRAMS[$program]}
done
