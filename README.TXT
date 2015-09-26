* Installing on Windows:

Install Mingw and set MINGW env var to root of mingw installation (ie: 'one up' from bin), then...

cd _src\win32_x86
install

Tested with TDM-GCC-32 5.1.0 and TDM-GCC-64 5.1.0, available from:

http://tdm-gcc.tdragon.net/download


* Installing on MacOS:

Install xcode command line tools, then...

cd _src/macos_x86
chmod +x *.bat
./install.bat

* Installing on Linux:


cd _src/linux_x86
chmod +x *.bat
./install.bat

Requires 32 bit dev libs.
