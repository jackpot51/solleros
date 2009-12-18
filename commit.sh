#!/bin/bash
#This script is for Linux and Mac users that would like to commit to the SVN
cd ..
svn status | grep ^\! | cut -c8- | xargs svn rm
svn status | grep ^\? | cut -c8- | xargs svn add
echo What do you want your log message to be?
read logmessage
svn commit -m "${logmessage}"
