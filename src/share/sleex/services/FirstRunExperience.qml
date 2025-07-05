pragma Singleton

import "root:/modules/common/functions/file_utils.js" as FileUtils
import "root:/modules/common"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    property string firstRunFilePath: `${Directories.state}/sleex/user/first_run.txt`
    property string firstRunScriptPath: `/usr/share/sleex/firstRun.sh`
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property string defaultWallpaperPath: FileUtils.trimFileProtocol(`${Directories.home}/.sleex/wallpapers/sakura.png`)
    property string welcomeNotifTitle: "Welcome to Sleex!"
    property string welcomeNotifBody: "First run? 👀 For a list of keybinds, hit Super + F1"

    function load() {
        firstRunFileView.reload()
    }

    function enableNextTime() {
        Quickshell.execDetached(["bash", "-c", `rm -f ${root.firstRunFilePath}`]) 
    }
    function disableNextTime() {
        Quickshell.execDetached(["bash", "-c", `echo ${root.firstRunFileContent} > ${root.firstRunFilePath}`])
    }

    function handleFirstRun() {
        setFirstWpp.running = true
        execFirstRunScript.running = true
        firstNotify.running = true
    }


    FileView {
        id: firstRunFileView
        path: Qt.resolvedUrl(firstRunFilePath)
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                root.handleFirstRun()
                firstRunFileView.setText(root.firstRunFileContent)
            }
        }
    }

    Process {
        id: setFirstWpp
        command: ["bash", "-c", `${Directories.wallpaperSwitchScriptPath} ${root.defaultWallpaperPath}`]
    }
    Process {
        id: execFirstRunScript
        command: ["bash", "-c", `${root.firstRunScriptPath}`]
    }
    Process {
        id: firstNotify
        command: ['bash', '-c', `sleep 0.5; notify-send '${root.welcomeNotifTitle}' '${root.welcomeNotifBody}' -a 'Sleex' &`]
    }
    
}
