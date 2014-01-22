rmdir /S /Q ..\..\bin
mkdir ..\..\bin
copy bin ..\..\bin

rmdir /S /Q ..\..\lib
mkdir ..\..\lib
copy lib ..\..\lib

.\rebuildmods
.\rebuildide
.\rebuildbmk
.\rebuildbcc
