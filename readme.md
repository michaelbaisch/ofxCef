
# ofxCEF

An attempt to get CEF working in openframeworks as an alternative to awesomium, berkelium, etc. [More info on CEF](https://bitbucket.org/chromiumembedded/cef) [wiki](https://bitbucket.org/chromiumembedded/cef/wiki/Home)

**Note**: If you are using openFrameworks version `0.9.8` switch to `make_it_work_0.9.8` branch.

## Installation

The CEF library is not directly included in the addon. The reason for this is a combination of two factors: The CEF source changes quite often and the build is quite big (min 100 mb). So to stay up-to-date ofxCEF would often need to include a new CEF build, which would make this repository very large.

To avoid this the CEF library has to build manually. Luckily there is a [apothecary](https://github.com/openframeworks/apothecary) script to automate this process.

### macOS – Xcode

Tested with Xcode 9.4, macOS High Sierra 10.13.5, of_v0.10.0 – 64 Bit Build

**Requirements**

`cmake` install with [brew](https://brew.sh):
  
```bash
brew install cmake
```

**Setup**

```bash
cd of_v0.10.1_osx_release/scripts/
git clone https://github.com/openframeworks/apothecary
cd apothecary/apothecary
./apothecary update ofxCef
```

`apothecary` has a bug where the path for [copying addon libraries is wrong](https://github.com/openframeworks/apothecary/issues/116). Until this is fixed you can comment line 1222: `IS_CUSTOM_LIBS_DIR=1` and it should work.

This will download, build and setup the directory structure for the CEF library.
The script will download the builds from [Automated Builds from Spotify](http://opensource.spotify.com/cefbuilds/index.html). You can set the version `VER` in `scripts/formulas/cef.sh`.


Now you can use the examples or the ProjectGenerator.

**ProjectGenerator**

After creating a new project with the ProjectGenerator you have to do a few simple manual steps:

1. In the project settings go to Build Phases. There we need another `Run Script` build phase. Press the `+` then `New Run Script Phase`. In there goes:

	```
    install_name_tool -change "@rpath/Frameworks/Chromium Embedded Framework.framework/Chromium Embedded Framework" "@executable_path/../Frameworks/Chromium Embedded Framework.framework/Chromium Embedded Framework" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}"
    rsync -aved "$OF_PATH/addons/ofxCef/libs/cef/lib/osx/cef_helper_mac.app" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/"
    rm -rf "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper*.app"
    # Helper Apps
    cp -R "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/cef_helper_mac.app" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper.app"
    mv "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper.app/Contents/MacOS/cef_helper_mac" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper.app/Contents/MacOS/$PRODUCT_NAME Helper"
    # GPU Helper
    cp -R "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/cef_helper_mac.app" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (GPU).app"
    mv "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (GPU).app/Contents/MacOS/cef_helper_mac" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (GPU).app/Contents/MacOS/$PRODUCT_NAME Helper (GPU)"
    # Plugin Helper
    cp -R "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/cef_helper_mac.app" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Plugin).app"
    mv "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Plugin).app/Contents/MacOS/cef_helper_mac" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Plugin).app/Contents/MacOS/$PRODUCT_NAME Helper (Plugin)"
    # Renderer Helper
    cp -R "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/cef_helper_mac.app" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Renderer).app"
    mv "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Renderer).app/Contents/MacOS/cef_helper_mac" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/$PRODUCT_NAME Helper (Renderer).app/Contents/MacOS/$PRODUCT_NAME Helper (Renderer)"
    
    rm -rf "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Frameworks/cef_helper_mac.app"

	```
	
	![Screenshot Xcode Script Phase](images/screenshot-xcode-script-phase.png)
	
4. On the left in the source tree select now each `.cpp` file in `addons/ofxCef/src` and set the type in the file inspector to `Objective-C++ Source`.
	
	![Screenshot Xcode Objective-C Sources](images/screenshot-xcode-objc-sources.png)
	
**Note on the `cef_helper_mac`**

If you change any of the following sources you have to rebuild the `cef_helper_mac`:

- `process_helper_mac.cpp`
- `ofxCEFClientApp.cpp/.h`
- `ofxCEFV8ExtensionHandler.cpp/.h`
- `cefListV8Converter.cpp/.hpp`


<br />

### Windows – Visual Studio

Tested with VS 2017, Windows 10 Pro, of_v0.10.0 – 64 Bit Build

**Requirements**

`cmake` install from [here](https://cmake.org/download/)
 
`git shell` install from [here](https://git-scm.com/download/win). Check `Git Bash Here` within `Windows Explorer integration` when asked in the installation process.

**Setup**

Navigate to `of_v0.10.0_vs2017_release/scripts/` then right click in the Explorer and select `Git Bash Here`. Then use this command:

```bash
git clone https://github.com/openframeworks/apothecary
cd apothecary/apothecary
./apothecary update ofxCef
```

`apothecary` has a bug where the path for [copying addon libraries is wrong](https://github.com/openframeworks/apothecary/issues/116). Until this is fixed you can comment line 1222: `IS_CUSTOM_LIBS_DIR=1` and it should work.

This will download, build and setup the directory structure for the CEF library.
The script will download the builds from [Automated Builds from Spotify](http://opensource.spotify.com/cefbuilds/index.html). You can set the version `VER` in `scripts/formulas/cef.sh`.

Now you can use the examples or the ProjectGenerator.

**ProjectGenerator**

After creating a new project with the ProjectGenerator you have to do one simple manual step:

Open the project properties, change `Configuration` to `All Configurations` and `Platforms` to `All Platforms`. In `Build Events` > `Post-Build Event` set `Command Line` with <Edit…> to:
    
```
for /d %%f in ("$(OF_ROOT)\libs\*") do (if exist "%%f\lib\vs\$(Platform_Actual)\*.dll" (robocopy "%%f\lib\vs\$(Platform_Actual)" "$(ProjectDir)bin" "*.dll" /njs /njh /np /fp /bytes ))
robocopy "$(OF_ROOT)/addons/ofxCef/libs/cef/export/vs/$(Platform_Actual)/" "$(ProjectDir)bin/" "*" /E /njs /njh /np /fp /bytes
if errorlevel 1 exit 0 else exit %errorlevel%
```

![Screenshot VS Post-Build Event](images/screenshot-vs-post-build-event.png)

<br />

### Cleaning up

The apothecary build directory still contains the CEF sources from which the CEF library is build. If you want to clean that up and get some disk space back you can use: 

```bash
./apothecary remove ofxCef
```

<br />

### Updating CEF library

If you want to update to the latest CEF library you first also need to delete the old CEF sources (so apothecary won't skip the download of the new version):

```bash
./apothecary remove ofxCef
```

Then you need to set the `VER` variable in `scripts/formulas/cef.sh` to the version you want to use from [Automated Builds from Spotify](http://opensource.spotify.com/cefbuilds/index.html). After that you need to rerun:

```bash
./apothecary update ofxCef
```


<br />
<br />

## Usage


### Minimal

`main.cpp`

Add `initofxCEF()` before and `CefShutdown()` after the existing code:

```cpp
int main( ){
    
    int argc = 0;
    char** argv = NULL;
    int exit_code = initofxCEF(argc, argv);
    if (exit_code >= 0) {
        return exit_code;
    }


    ofSetupOpenGL(1024,768,OF_WINDOW);      // <-------- setup the GL context

    // this kicks off the running of my app
    // can be OF_WINDOW or OF_FULLSCREEN
    // pass in width and height too:
    ofRunApp(new ofApp());


    CefShutdown();
}
```


`ofApp.h`

add `#include "ofxCEF.h"` and an ofxCef instance `ofxCEF cef`:

```cpp
#include "ofMain.h"
#include "ofxCEF.h"

class ofApp : public ofBaseApp{

    …

    ofxCEF cef;
};
```


`ofApp.cpp`

```cpp
//--------------------------------------------------------------
void ofApp::setup(){
    string url = "https://duckduckgo.com";
    cef.setup(url);
}

//--------------------------------------------------------------
void ofApp::update(){
    updateCEF();
}

//--------------------------------------------------------------
void ofApp::draw(){
    cef.draw();
}
```

<br />

### Communicate with JS

See the `example-communication` for further info.

**Send data to JS**

```cpp
cef.executeJS("dataFromOF(\"keyReleased in OF: " + ofToString(key) + "\")");
```


**Bind JS function to method in OF**

```cpp
cef.bind("dataToOF", this, &ofApp::gotMessageFromJS);
```


<br />
<br />

## Examples

* **Simple:** Just the minimum needed to load and view a page
* **Multi:** Tech demo creating many instances (might helpful to find bugs)
* **Communication:** How to send and receive data from a page (JS)


<br />
<br />

## Known Issues
	
- CEF hijacks the menu bar and makes it unusable, among other things cmd+q isn't working anymore (macOS only).
- The current version isn't showing anything on macOS Mojave (10.14.1). For some reason OnPaint isn't called anymore. https://magpcss.org/ceforum/viewtopic.php?f=6&t=16371&start=20
