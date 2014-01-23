rm -r -f ../../bin
mkdir ../../bin
cp bin/* ../../bin
chmod +x ../../bin/*

rm -r -f ../../lib
mkdir ../../lib
#cp lib/* ../../lib

./rebuildmods.bat
./rebuildide.bat
./rebuildbmk.bat
./rebuildbcc.bat
