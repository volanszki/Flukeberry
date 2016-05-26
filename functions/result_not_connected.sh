#!/bin/bash

basedir="$(cat ../settings/basedir)"
funcdir="$basedir/functions"
lastdir="$basedir/last"
tempdir="$basedir/tmp"
imagdir="$basedir/images"

echo '<table style="border: 1px dashed black;">
<tbody>
<tr>
<td style="text-align: center;">
<p><strong>Network endpoint measurement report</strong></p>
</td>
</tr>
<tr>
<td style="text-align: center; padding: 0 6px 0 6px;">
<p><img src="'$imagdir'/disconnected_s.png" alt=""/></p>
</td>
</tr>
<td style="text-align: center;">
<p><strong>No ethernet connection... :(</strong></p>
</td>
</tr>
</tbody>
</table>
' > $lastdir/result.html
