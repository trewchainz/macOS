#!/bin/zsh
#update curl via brew
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
checkCurl=$( /usr/bin/su - "$currentUser" -c '/opt/homebrew/bin/brew list curl' )

#run if user is logged in, exit if not
if [[ $currentUser != "loginwindow" ]]; then
    #if $checkCurl returns non-empty, update curl
    if [[ ! -z $checkCurl ]]; then
        #command line tools for Xcode is a dependency of brew
        echo "Checking Command Line Tools for Xcode"
        #install command line tools if not present
        xcode-select -p &> /dev/null
        if [ $? -ne 0 ]; then
            echo "command line tools for Xcode not found. installing from softwareupdate..."
            # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
            touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
            PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
            softwareupdate -i "$PROD" --verbose;
        fi
        echo "curl is installed via brew, updating..."
        #install new version of curl
        /usr/bin/su - "$currentUser" -c '/opt/homebrew/bin/brew install curl'
    else
        echo "curl isn't installed via brew, exiting..."
    fi
else
    echo "no user is logged in, exiting..."
fi
