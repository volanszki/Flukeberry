#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
lastdir="$basedir/last"
tempdir="$basedir/tmp"
imagdir="$basedir/images"
measdir="$basedir/measurements"
settdir="$basedir/settings"
flukeberryname="$(cat $settdir/hostname)"
datetime=$1

function check_poe {
    if [ "$(grep "MDI power support" $tempdir/tcpdump.out | wc -l)" == "1" ]; then
	echo $(grep "MDI power support" $tempdir/tcpdump.out | awk '{print $12}')
    else
	echo "n/a"
    fi
}

function value_checking {
	if [ "$datetime" == "" ]; then datetime="n/a"; fi
	if [ "$patch_port" == "" ]; then patch_port="not defined"; fi
	if [ "$vendor" == "" ]; then vendor="n/a"; fi
	if [ "$sw_name" == "" ]; then sw_name="n/a"; fi
	if [ "$sw_ip" == "" ]; then sw_ip="n/a"; fi
	if [ "$sw_unit" == "" ]; then sw_unit="n/a"; fi
	if [ "$sw_port" == "" ]; then sw_port="n/a"; fi
	if [ "$sw_vlan" == "" ]; then sw_vlan="n/a"; fi
	if [ "$sw_poe" == "" ]; then sw_poe="n/a"; fi
	if [ "$device" == "" ]; then device="n/a"; fi
}

function save_results {
    local filename="$flukeberryname-$(date '+%Y-%m-%d').csv"
    if [ ! -f $measdir/$filename ]; then
	echo "not exist"
	echo "Date/Time;Patch port;Vendor;Switch/Stack name;Switch/Stack IP;Unit number;Port number;VLAN PVID;PoE;Device;Checker" > $measdir/$filename
    fi
    echo $datetime";"$patch_port";"$vendor";"$sw_name";"$sw_ip";"$sw_unit";"$sw_port";"$sw_vlan";"$sw_poe";"$device";"$flukeberryname >> $measdir/$filename
}

LLDP="0"

if [ "$(grep -i lldp $tempdir/tcpdump.out | wc -l)" != "0" ]; then
    LLDP="1"
fi

if [ $LLDP == "1" ]; then
    sw_name=$(grep "System Name TLV (5)" $tempdir/tcpdump.out | awk -F ":" '{print $2}' | awk '{print $1}')
    sw_ip=$(grep "IPv4" $tempdir/tcpdump.out | awk -F ":" '{print $2}' | awk '{print $1}')
    sw_unit=$(grep "Port Description TLV (4)" $tempdir/tcpdump.out | awk -F "Unit" '{print $2}' | awk '{print $1}')
    sw_port=$(grep "Port Description TLV (4)" $tempdir/tcpdump.out | awk -F "Port" '{print $3}' | awk '{print $1}')
    sw_vlan=$(grep "port vlan id (PVID)" $tempdir/tcpdump.out | awk -F ":" '{print $2}' | awk '{print $1}')
    sw_poe=$(check_poe)
    sw_mac=$(grep "Subtype MAC address (4)" $tempdir/tcpdump.out | awk '{print $5}' | cut -c 1-8)
    vendor=$($funcdir/mac_getvendor.sh $sw_mac)
    device=$(grep -A 1 "System Description TLV (6)" $tempdir/tcpdump.out | tail -n 1)
    patch_port=$(cat $basedir/keyboard/patch.port)
else
    sw_name=$(grep "Device-ID (0x01)" $tempdir/tcpdump.out | awk -F "bytes:" '{print $2}' | cut -c 2- | sed "s/'//g")
    sw_ip=$(grep "Address (0x02)" $tempdir/tcpdump.out | awk -F "bytes:" '{print $2}' | awk '{print $3}')
    vendor=$(grep "Platform (0x06)" $tempdir/tcpdump.out | awk -F "bytes:" '{print $2}' | awk '{print $1}' | sed "s/'//g" | tr '[:upper:]' '[:lower:]')
    device=$(grep "Platform (0x06)" $tempdir/tcpdump.out | awk -F "bytes:" '{print $2}' | sed "s/'//g")
    value_num=$(grep "Port-ID (0x03)" $tempdir/tcpdump.out | awk -F "Ethernet" '{print $2}' | tr -d -c '/' | awk '{ print length; }')
    if [ "$value_num" == "1" ]; then
	sw_unit=$(grep "Port-ID (0x03)" $tempdir/tcpdump.out | awk -F "Ethernet" '{print $2}' | awk -F "/" '{print $1}')
	sw_port=$(grep "Port-ID (0x03)" $tempdir/tcpdump.out | awk -F "Ethernet" '{print $2}' | awk -F "/" '{print $2}' | sed "s/'//g")
    else
	sw_port=$(grep "Port-ID (0x03)" $tempdir/tcpdump.out | awk -F "Ethernet" '{print $2}' | sed "s/'//g" | rev | awk -F "/" '{print $1}')
	sw_unit=$(grep "Port-ID (0x03)" $tempdir/tcpdump.out | awk -F "Ethernet" '{print $2}' | sed "s/'//g" | rev | awk -F "/" '{print $3"/"$2}')
    fi
    sw_vlan=$(grep "Native VLAN ID (0x0a)" $tempdir/tcpdump.out | awk -F "bytes:" '{print $2}' | awk '{print $1}')
    patch_port=$(cat $basedir/keyboard/patch.port)
    sw_poe=""
fi

value_checking
save_results

echo '<table width="390" style="border: 1px dashed black;">
<tbody>
<tr>
<td style="text-align: center;">
<p><strong>Network endpoint measurement report</strong></p>
</td>
</tr>
<tr>
<td style="text-align: center; padding: 0 0 0 0;">
<p><img src="'$imagdir'/'$vendor'_s.png" alt=""/></p>
</td>
</tr>
<tr>
<td>
<table>
<tbody>
<tr>
<td width="140" style="border-bottom: 1px dotted black;" width="180">Patch port:</td>
<td width="270" style="border-bottom: 1px dotted black; text-align: left;" colspan="2">'$patch_port'</td>
</tr>
<tr>
<td width="140" style="border-bottom: 1px dotted black;" width="180">Date / Time:</td>
<td width="270" style="border-bottom: 1px dotted black; text-align: left;" colspan="2">'$datetime'</td>
</tr>
<tr>
<td width="140" style="border-bottom: 1px dotted black;">Stack Name:</td>
<td width="270" style="border-bottom: 1px dotted black; text-align: left;" colspan="2">'$sw_name'</td>
</tr>
<tr>
<td width="140" style="border-bottom: 1px dotted black;">Stack IP:</td>
<td width="270" style="border-bottom: 1px dotted black; text-align: left;" colspan="2">'$sw_ip'</td>
</tr>
<tr>
<td width="140" style="border-bottom: 1px dotted black;">SW Info:</td>
<td width="125" style="border-bottom: 1px dotted black; text-align: left;">Unit: <strong>'$sw_unit'</strong></td>
<td width="125" style="border-bottom: 1px dotted black; text-align: left;">Port: <strong>'$sw_port'</strong></td>
</tr>
<tr>
<td width="140">VLAN & POE:</td>
<td width="125" style="text-align: left;">PVID: <strong>'$sw_vlan'</strong></td>
<td width="125" style="text-align: left;">POE: <strong>'$sw_poe'</strong></td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
' > $lastdir/result.html
