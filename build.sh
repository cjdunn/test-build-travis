#!/bin/bash

# /////////////////////////////////////////////////////////////////
#
# build.sh
#  A shell script that builds the Hack fonts from UFO source
#  Copyright 2017 Christopher Simpkins
#  MIT License
#
#  Usage: ./build.sh (--install-dependencies)
#     Arguments:
#     --install-dependencies (optional) - installs all
#       build dependencies prior to the build script execution
#
# /////////////////////////////////////////////////////////////////


# test for number of arguments
if [ $# -gt 1 ]
	then
	    echo "Inappropriate arguments included in your command." 1>&2
	    echo "Usage: ./build.sh (--install-dependencies)" 1>&2
	    exit 1
fi

if [ "$1" = "--install-dependencies" ]
	then
		# fontmake
		pip install --upgrade fontmake
		# fontTools (installed with fontmake at this time. leave this as dependency check as python scripts for fixes require it should fontTools eliminate dep)
		pip install --upgrade fonttools
		# ttfautohint v1.6 (must be pinned to v1.6 and above for Hack instruction sets)
        # begin with OS X check for platform specific ttfautohint install using Homebrew, install from source on other platforms
        platformstr=$(uname)
        if [ "$platformstr" = "Darwin" ]; then
            # test for homebrew install
            if ! which homebrew
                then
                    echo "Please manually install Homebrew (https://brew.sh/) before the execution of this script with the --install-dependencies flag on the OS X platform." 1>&2
                    exit 1
            fi

            # install Homebrew release of ttfautohint (this installs all dependencies necessary for build)
            #    use --upgrade flag to confirm latest version installed as need 1.6+
            if ! brew install --upgrade ttfautohint
                then
                    echo "Unable to install ttfautohint with Homebrew.  Please attempt to install this dependency manually and repeat this script without the --install-dependencies flag." 1>&2
                    exit 1
            fi
        else
            curl -L https://sourceforge.net/projects/freetype/files/ttfautohint/1.6/ttfautohint-1.6.tar.gz/download -o ttfautohint.tar.gz
            tar -xvzf ttfautohint.tar.gz
            ttfautohint-1.6/configure --with-qt=no
            ttfautohint-1.6/make
            if ! sudo ttfautohint-1.6/make install; then
            	echo "Unable to install ttfautohint from source.  Please attempt to manually install this dependency and repeat this script without the --install-dependencies flag" 1>&2
            	exit 1
            fi

            if [ -f "ttfautohint-1.6.tar.gz" ]
                then
                    rm ttfautohint-1.6.tar.gz
            fi

            if [ -d "ttfautohint-1.6" ]
                then
                    rm -rf ttfautohint-1.6
            fi
        fi

		# confirm installs
		installflag=0
        # fontmake installed
		if ! which fontmake
			then
			    echo "Unable to install fontmake with 'pip install fontmake'.  Please attempt manual install and repeat build without the --install-dependencies flag." 1>&2
			    installflag=1
		fi
        # fontTools python library can be imported
		if ! python -c "import fontTools"
			then
			    echo "Unable to install fontTools with 'pip install fonttools'.  Please attempt manual install and repeat build without the --install-dependencies flag." 1>&2
			    installflag=1
		fi
        # ttfautohint installed
		if ! which ttfautohint
			then
			    echo "Unable to install ttfautohint from source.  Please attempt manual install and repeat build without the --install-dependencies flag." 1>&2
			    installflag=1
		fi
		# if any of the dependency installs failed, exit and do not attempt build, notify user
		if [ $installflag -eq 1 ]
			then
			    echo "Build canceled." 1>&2
			    exit 1
        fi
fi

# Desktop ttf font build

echo "Starting build..."
echo " "

# build regular set

# if ! fontmake -u "source/1-Drawing/Test-Reglar.ufo" -o ttf
# 	then
# 	    echo "Unable to build the Test-Reglar.ufo.  Build canceled." 1>&2
# 	    exit 1
# fi


# if ! fontmake -u "source/1-Drawing/Test-Bold.ufo" -o ttf
#     then
#         echo "Unable to build Test-Bold.ufo.  Build canceled." 1>&2
#         exit 1
# fi

if ! fontmake -m "source/designspace/test.designspace" -i --interpolate -o otf --no-production-names
    then
        echo "Unable to build from designspace.  Build canceled." 1>&2
        exit 1
fi


echo " "
echo "Build complete.  Release files are available in the build directory."
