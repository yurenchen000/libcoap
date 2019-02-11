#!/bin/bash



# ------------- init PATH
#dir=$(dirname `readlink -f $0`)/../examples
#dir=`readlink -f $dir`
dir=/home/chen/doc/libcoap/OUT/usr/local
#echo $dir

export PATH=$dir/bin:$PATH
export LD_LIBRARY_PATH=$dir/lib


[ "$1" == "--path" ] && echo $dir && return

# ------------- main


#coap-server -v9 |& grep 'qlink/searchack' -B2 --line-buffered | awk '$0 ~ "<->" {print $8; gsub("].*","", $8); gsub("\\[::.*:","", $8); print $8}' 

echo "1. start server"
GWIP=/tmp/gwip.out
coap-server -v9 |& grep 'qlink/searchack' -B2 --line-buffered | awk '$0 ~ "<->" { gsub("].*","", $8); gsub("\\[::.*:","", $8); print $8; system("killall coap-server")}' > $GWIP &
echo "pid: `pidof coap-server`"

echo "2. broadcast search"
dat='{"searchKey":"ANDLINK-DEVICE","andlinkVersion":"V2"}'
#coap-client -m post coap://255.255.255.255/qlink/searchgw -e $dat -v6 -N -B1
for i in {1..3}; do
	coap-client -m post coap://255.255.255.255/qlink/searchgw -e $dat -v3 -N -B1
	echo "pid: `pidof coap-server`"
	pidof coap-server >/dev/null || break;
done

echo "3. result"
echo "gwip: `cat $GWIP`"

