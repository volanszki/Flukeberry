#!/bin/bash

basedir="$(cat ../settings/basedir)"
lastdir="$basedir/last"
imagdir="$basedir/images"


echo '<table style="border: 1px dashed black;">
<tbody>
<tr>
<td style="text-align: center;">
<p><strong>Network endpoint measurement report</strong></p>
</td>
</tr>
<tr>
<td style="text-align: center; padding: 0 10px 0 0;">
<p><img src="'$imagdir'/unknown_s.png" alt=""/></p>
</td>
</tr>
<td style="text-align: center;">
<p><strong>Not recognized device... :(</strong><br>Ask your SysAdmin!</p>
</td>
</tr>
</tbody>
</table>
' > $lastdir/result.html


