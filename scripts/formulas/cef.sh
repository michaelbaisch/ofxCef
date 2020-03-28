#! /bin/bash
#
# CEF

FORMULA_TYPES=( "osx" "vs" "msys2" )

# Define the version and distribution (Standard | Minimal)
# Is there permanent link to the latest version?
VER="79.1.35+gfebbb4a+chromium-79.0.3945.130" #"76.1.13+gf19c584+chromium-76.0.3809.132"
DISTRIBUTION="Minimal"

# download the source code and unpack it into LIB_NAME
function download() {

  # Check Distribution
  if [ "$DISTRIBUTION" == "Standard" ] || [ "$DISTRIBUTION" == "standard" ] ; then
    DISTRIBUTION=""
  elif [ "$DISTRIBUTION" == "Minimal" ] || [ "$DISTRIBUTION" == "minimal" ] ; then
    DISTRIBUTION="_minimal"
  else
    DISTRIBUTION=""
  fi

  # Percent-encoding: + -> %2B
  VER_URL=${VER//\+/\%2B}

  # Build Filename
  local FILENAME=cef_binary_${VER}_macosx64${DISTRIBUTION}
  local FILENAME_URL=cef_binary_${VER_URL}_macosx64${DISTRIBUTION}

  if [ "$TYPE" == "osx" ] ; then
    FILENAME=cef_binary_${VER}_macosx64${DISTRIBUTION}
    FILENAME_URL=cef_binary_${VER_URL}_macosx64${DISTRIBUTION}
  elif [ "$TYPE" == "vs" ] || [ "$TYPE" == "msys2" ] ; then
    FILENAME=cef_binary_${VER}_windows64${DISTRIBUTION}
    FILENAME_URL=cef_binary_${VER_URL}_windows64${DISTRIBUTION}
  fi

  # Download
  echo "Downloading ${FILENAME}"

  curl -O "http://opensource.spotify.com/cefbuilds/${FILENAME_URL}.tar.bz2"
  curl -O "http://opensource.spotify.com/cefbuilds/${FILENAME_URL}.tar.bz2.sha1"

  # Unpacking and cleaning
  echo "TODO: check against the SHA"
  # if [ "$(shasum $FILENAME.tar.gz | awk '{print $1}')" == "$(cat $FILENAME.tar.gz.sha1)" ] ;  then  
  echo "Unpacking"
  tar -xf $FILENAME_URL.tar.bz2
  mv $FILENAME cef
  rm $FILENAME_URL.tar.bz2
  rm $FILENAME_URL.tar.bz2.sha1
  # else
  #   echoError "Invalid shasum for $FILENAME."
  # fi
}

# prepare the build environment, executed inside the lib src dir
function prepare() {

  if [ "$TYPE" == "osx" ] ; then
    cmake -G "Xcode" -DUSE_SANDBOX=Off
  elif [ "$TYPE" == "vs" ] || [ "$TYPE" == "msys2" ] ; then

    # Set Runtime Library from /MT to /MD
    # Setting `-DCEF_RUNTIME_LIBRARY_FLAG=/MD` doesn't seem to work?
    sed -i -e 's/CEF_RUNTIME_LIBRARY_FLAG \"\/MT\"/CEF_RUNTIME_LIBRARY_FLAG \"\/MD\"/g' cmake/cef_variables.cmake

    # Disable Sandbox because cef_sandbox.lib is already compiled with /MT
    #cmake -G "Visual Studio 14 2015 Win64" -DUSE_SANDBOX=Off # VS 2015
    cmake -G "Visual Studio 15 2017 Win64" -DUSE_SANDBOX=Off

  fi

}

# executed inside the lib src dir
function build() {

  if [ "$TYPE" == "osx" ] ; then
    # Get info abuout xcode project
    # xcodebuild -list -project cef.xcodeproj 

    xcodebuild -target libcef_dll_wrapper -configuration Release -project cef.xcodeproj/

  elif [ "$TYPE" == "vs" ] || [ "$TYPE" == "msys2" ] ; then
     #"/c/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" -target:libcef_dll_wrapper -p:"Configuration=Release;Platform=x64" cef.sln  # VS2015
     #"/c/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" -target:libcef_dll_wrapper -p:"Configuration=Debug;Platform=x64" cef.sln  # VS2015
     "/c/Program Files (x86)/Microsoft Visual Studio/2017/Community/MSBuild/15.0/Bin/MSBuild.exe" -target:libcef_dll_wrapper -p:"Configuration=Release;Platform=x64" cef.sln
     "/c/Program Files (x86)/Microsoft Visual Studio/2017/Community/MSBuild/15.0/Bin/MSBuild.exe" -target:libcef_dll_wrapper -p:"Configuration=Debug;Platform=x64" cef.sln
  fi
}

# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {

  mkdir -pv $1/include/
  mkdir -pv $1/lib/

  # Copy header
  cp -Rv include/.  $1/include/

  # Copy libs/files
  if [ "$TYPE" == "osx" ] ; then
    mkdir -pv $1/lib/osx

    cp -RHv "Release/Chromium Embedded Framework.framework"  $1/lib/osx/
    cp -RHv "libcef_dll_wrapper/Release/libcef_dll_wrapper.a"  $1/lib/osx/
    cp -RHv "Release/cef_sandbox.a"  $1/lib/osx/

    # Need to build the cef_helper_mac, can only do this after stuff was copied
    xcodebuild -target cef_helper_mac -configuration Release -project $1/../../cef_helper_mac/cef_helper_mac.xcodeproj/

    # Not needed anymore, we're building our own helper
    #cp -RHv "tests/cefclient/Release/cefclient.app/Contents/Frameworks/cefclient Helper.app"  $1/lib/osx/
  
  elif [ "$TYPE" == "vs" ] || [ "$TYPE" == "msys2" ] ; then

    mkdir -pv $1/lib/vs/x64/Release
    cp -RHv "Release/libcef.lib"  $1/lib/vs/x64/Release/
    cp -RHv "libcef_dll_wrapper/Release/libcef_dll_wrapper.lib"  $1/lib/vs/x64/Release/

    mkdir -pv $1/lib/vs/x64/Debug
    cp -RHv "Release/libcef.lib"  $1/lib/vs/x64/Debug/  # no `libcef.lib` in Debug
    cp -RHv "libcef_dll_wrapper/Debug/libcef_dll_wrapper.lib"  $1/lib/vs/x64/Debug/
    
    mkdir -pv $1/export/vs/x64
    cp -RHv "Release/."  $1/export/vs/x64/
    cp -RHv "Resources/."  $1/export/vs/x64/
    rm $1/export/vs/x64/*.lib
  fi
}

# executed inside the lib src dir
function clean() {
  #echoWarning "TODO: clean"
  
  if [ "$TYPE" == "osx" ] ; then
    xcodebuild clean -project cef.xcodeproj/
  elif [ "$TYPE" == "vs" ] || [ "$TYPE" == "msys2" ] ; then
    #"/c/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" cef.sln -t:"Clean" # VS2015
    "/c/Program Files (x86)/Microsoft Visual Studio/2017/Community/MSBuild/15.0/Bin/MSBuild.exe" cef.sln -t:"Clean"
  fi

  rm -f CMakeCache.txt

}
