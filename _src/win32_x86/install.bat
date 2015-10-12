echo off
cls

echo ***********************
echo ***** STARTING UP *****
echo ***********************

rmdir /S /Q ..\..\bin
mkdir ..\..\bin
copy bin ..\..\bin

rmdir /S /Q ..\..\lib
mkdir ..\..\lib
copy lib ..\..\lib

echo ****************************
echo ***** BUILDING MODULES *****
echo ****************************
call rebuildmods

echo ***************************
echo ***** BUILDING MAXIDE *****
echo ***************************
call rebuildide

echo ************************
echo ***** BUILDING BMK *****
echo ************************
call rebuildbmk

echo ************************
echo ***** BUILDING BCC *****
echo ************************
call rebuildbcc

echo *****************************
echo ***** BUILDING MAKEDOCS *****
echo *****************************
call rebuildmakedocs
