#!/bin/zsh
#update curl via brew
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
checkCurl=$( /usr/bin/su - "$currentUser" -c '/opt/homebrew/bin/brew list curl' )

#command liine tools for Xcode is a dependency of brew
echo "Checking Command Line Tools for Xcode"
# Only run if the tools are not installed yet
# To check that try to print the SDK path
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
    echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose;
else
    echo "Command Line Tools for Xcode have been installed."
fi
#run if user is logged in, exit if not
if [[ $currentUser != "loginwindow" ]]; then
    #if $checkCurl returns non-empty, install curl
    if [[ ! -z $checkCurl ]]; then
        echo "curl is installed via brew, updating..."
        #install curl
        /usr/bin/su - "$currentUser" -c '/opt/homebrew/bin/brew install curl'
    else
        echo "curl isn't installed via brew..."
    fi
else
    echo "no user is logged in..."
fi