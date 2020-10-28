#!/bin/bash
# scripts/use_quicken.sh
#
# Designed to maintain Our Quicken file: C:\Users\steve\Documents\Quicken\NEW2002.QFF
# and Foxboro's file: C:\Users\steve\Documents\Foxboro\quicken\FOXBORO.QDF
# and the Dropbox.
#
# Allowing one computer to be updating and others to download and not update/upload.
#
vSrcOurDocsDir="$HOME/Documents"
vSrcOurQuickenDir="${vSrcOurDocsDir}/Quicken"
vSrcFoxboroDir="${vSrcOurDocsDir}/Foxboro"
vSrcFoxboroQuickenDir="${vSrcFoxboroDir}/quicken"

vOurQuicken="NEW2002.QDF"
vFoxboroQuicken="FOXBORO.QDF"

vTgtDropBoxDir="$HOME/Dropbox"
vTgtOurQuickenDir="${vTgtDropBoxDir}/Quicken"
vTgtFoxboroDir="${vTgtDropBoxDir}/Foxboro"
vTgtFoxboroQuickenDir="${vTgtFoxboroDir}/quicken"

function Checkrc {
	vCheckrc=0
	return $vCheckrc
}

function ClearUpdate {
	vClearUpdate=0
	echo "ClearUpdate"
	rm -f $vDropBoxQuicken
	return $vClearUpdate
}

function SetUpdate {
	vSetUpdate=0
	echo "SetUpdate"
	hostname > $vDropBoxQuicken
	return $vSetUpdate
}

function DownloadQuicken {
	vDownloadQuicken=0
	echo "Download Quicken"
	echo "Ours"
	ls -l $vTgtOurQuickenDir/$vOurQuicken $vSrcOurQuickenDir/$vOurQuicken
	echo "press enter to continue or CTRL-C to stop"
	read
	cp $vTgtOurQuickenDir/$vOurQuicken $vSrcOurQuickenDir
	cksum $vTgtOurQuickenDir/$vOurQuicken
	cksum $vSrcOurQuickenDir/$vOurQuicken
	echo "Foxboro"
	ls -l $vTgtFoxboroQuickenDir/$vFoxboroQuicken $vSrcFoxboroQuickenDir/$vFoxboroQuicken
	echo "press enter to continue or CTRL-C to stop"
	read
	cp $vTgtFoxboroQuickenDir/$vFoxboroQuicken $vSrcFoxboroQuickenDir
	cksum $vTgtFoxboroQuickenDir/$vFoxboroQuicken
	cksum $vSrcFoxboroQuickenDir/$vFoxboroQuicken
	echo "press enter to continue or CTRL-C to stop"
	read
	return $vDownloadQuicken
}

function UploadQuicken {
	vUploadQuicken=0
	echo "Upload Quicken"
	echo "Ours"
	ls -l $vTgtOurQuickenDir/$vOurQuicken $vSrcOurQuickenDir/$vOurQuicken
	echo "press enter to continue or CTRL-C to stop"
	read
	cp $vSrcOurQuickenDir/$vOurQuicken $vTgtOurQuickenDir
	cksum $vSrcOurQuickenDir/$vOurQuicken
	cksum $vTgtOurQuickenDir/$vOurQuicken
	echo "Foxboro"
	ls -l $vTgtFoxboroQuickenDir/$vFoxboroQuicken $vSrcFoxboroQuickenDir/$vFoxboroQuicken
	cp $vSrcFoxboroQuickenDir/$vFoxboroQuicken $vTgtFoxboroQuickenDir
	cksum $vTgtFoxboroQuickenDir/$vFoxboroQuicken
	cksum $vSrcFoxboroQuickenDir/$vFoxboroQuicken
	echo "press enter to continue or CTRL-C to stop"
	read
	return $vUploadQuicken
}

vReturn=false
if [ ! -d $vSrcOurDocsDir ] ; then
	echo "1 $vSrcOurDocsDir directory is missing"
	vReturn=true
fi
if [ ! -d $vSrcOurQuickenDir ] ; then
	echo "2 $vSrcOurQuickenDir directory is missing"
	vReturn=true
fi
if [ ! -d $vSrcFoxboroDir ] ; then
	echo "3 $vSrcFoxboroDir directory is missing"
	vReturn=true
fi
if [ ! -d $vSrcFoxboroQuickenDir ] ; then
	echo "4 $vSrcFoxboroQuickenDir directory is missing"
	vReturn=true
fi

if [ ! -d $vTgtDropBoxDir ] ; then
	echo "5 $vTgtDropBoxDir directory is missing"
	vReturn=true
fi
if [ ! -d $vTgtOurQuickenDir ] ; then
	echo "6 $vTgtOurQuickenDir directory is missing"
	vReturn=true
fi
if [ ! -d $vTgtFoxboroDir ] ; then
	echo "7 $vTgtFoxboroDir directory is missing"
	vReturn=true
fi
if [ ! -d $vTgtFoxboroQuickenDir ] ; then
	echo "8 $vFoxboroQuickenDir directory is missing"
	vReturn=true
fi
if $vReturn ; then
	echo "cannot proceed"
	exit 1
else
	echo "Source and Target directories OK"
fi

vhostname=$(hostname)
vUpdating=""
vDropBoxQuicken="$vTgtOurQuickenDir/QUICKENN.txt"
if [ -f $vDropBoxQuicken ] ; then
	vUpdating=$(cat $vDropBoxQuicken)
fi

if [ "$vUpdating" = "$vhostname" ] ; then
	echo "Do you want to upload? y/n?"
	read vResponse
	if [ "$vResponse" = "y" ] ; then
		UploadQuicken
		echo "Do you want to release Quicken? y/n?"
		read vResponse
		if [ "$vResponse" = "y" ] ; then
			ClearUpdate
		fi
	fi
elif [ "$vUpdating" = "" ] ; then
	echo "Quicken is not being updated by anyone"
	echo "Do you want to download? y/n?"
	read vResponse
	if [ "$vResponse" = "y" ] ; then
		DownloadQuicken
		echo "Do you want to update Quicken? y/n?"
		read vResponse
		if [ "$vResponse" = "y" ] ; then
			SetUpdate
		fi
	fi
else
 	echo "Quicken is being updated by $vUpdating"
	echo "You can download but not update"
	echo "Do you want to download? y/n?"
	read vResponse
	if [ "$vResponse" = "y" ] ; then
		DownloadQuicken
	fi
fi
