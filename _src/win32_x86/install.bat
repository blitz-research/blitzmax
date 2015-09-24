rmdir /S /Q ..\..\bin
mkdir ..\..\bin
copy bin ..\..\bin

rmdir /S /Q ..\..\lib
mkdir ..\..\lib
copy lib ..\..\lib

call rebuildmods
call rebuildide
call rebuildbmk
call rebuildbcc
call rebuildmakedocs
