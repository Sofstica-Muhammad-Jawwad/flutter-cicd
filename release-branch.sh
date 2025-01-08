#!/bin/sh

function info() {
    cat <<EOF

    Please enter [1] [2] [3] for required version increment

    For Major Increment: 1
    For Minor Increment: 2
    For Patch Increment: 3

EOF
}

function error() {
    red='\033[0;31m'
    echo ${red}Invalid Argument: Please run the command next time you want to increment your Android and iOS version${red}
}

info

yello='\033[0;33m'
# Clear the color after that
clear='\033[0m'

echo $yello
read -p "Enter your choice: " input
echo ''
echo $clear

function incrementIosVersion() {
    # ios version
    existing_version_ios=$(cat ios/Runner.xcodeproj/project.pbxproj | grep MARKETING_VERSION | head -1 | awk -F ' = ' '{print $2}' | sed 's/;//g')

    #ios build number
    existing_code_ios=$(cat ios/Runner.xcodeproj/project.pbxproj | grep CURRENT_PROJECT_VERSION | head -1 | awk -F ' = ' '{print $2}' | sed 's/;//g')

    # increment build number ios
    new_code_ios=$existing_code_ios
    let "new_code_ios++"

    # split version number ios
    major=$(echo $existing_version_ios | awk -F '.' '{print $1}')
    minor=$(echo $existing_version_ios | awk -F '.' '{print $2}')
    patch=$(echo $existing_version_ios | awk -F '.' '{print $3}')


    # incrementing the specific version based on input
    if [ "$1" == '1' ]; then
        let "major++"
        minor=0
        patch=0
    elif [ "$1" == '2' ]; then
        let "minor++"
        patch=0
    elif [ "$1" == '3' ]; then
        let "patch++"
    fi

    # joining the versions (major.minor.patch)
    new_version_ios=${major}.${minor}.${patch}

    # copying the version into the file
    sed "s/MARKETING_VERSION = ${existing_version_ios}/MARKETING_VERSION = ${new_version_ios}/g" ios/Runner.xcodeproj/project.pbxproj > ios_version_number

    # copying the build number into the file
    sed "s/CURRENT_PROJECT_VERSION = ${existing_code_ios}/CURRENT_PROJECT_VERSION = ${new_code_ios}/g" ios_version_number > ios_version_code

    # copying data to ios/Runner.xcodeproj/project.pbxproj again to retain formatting
    cat ios_version_code >ios/Runner.xcodeproj/project.pbxproj

    rm ios_version_code ios_version_number

    # Set the color variable
    green='\033[0;32m'
    # Clear the color after that
    clear='\033[0m'

    echo "${green}iOS Version updated successfully!${clear}"
}

function incrementAndroidVersion() {
    existing_version_with_code=$(cat pubspec.yaml | grep version: | awk -F 'version:' '{print $2}' | sed  's/ //g')

    # fetching version for android
    existing_version_android=$(echo $existing_version_with_code | awk -F '+' '{print $1}')

    # fetching code for android
    existing_code_android=$(echo $existing_version_with_code | awk -F '+' '{print $2}')
    
    # increment build number
    new_code_android=$existing_code_android
    let "new_code_android++"

    # split version number
    major=$(echo $existing_version_android | awk -F '.' '{print $1}')
    minor=$(echo $existing_version_android | awk -F '.' '{print $2}')
    patch=$(echo $existing_version_android | awk -F '.' '{print $3}')

    # incrementing the specific version based on input
    if [ "$1" == '1' ]; then
        let "major++"
        minor=0
        patch=0
    elif [ "$1" == '2' ]; then
        let "minor++"
        patch=0
    elif [ "$1" == '3' ]; then
        let "patch++"
    fi

    # joining the versions (major.minor.patch)
    new_version_android=${major}.${minor}.${patch}+${new_code_android}

    # replacing the current version with the new one
    # and storing the output to android_version
    sed "s/${existing_version_with_code}/${new_version_android}/g" pubspec.yaml >android_version

    # copying data to pubspec.yaml again to retain formatting
    cat android_version >pubspec.yaml

    rm android_version

    # Set the color variable
    green='\033[0;32m'
    # Clear the color after that
    clear='\033[0m'

    echo "${green}Android Version updated successfully!${clear}"
}

function createReleaseBranch() {
    # Extract the version from pubspec.yaml (without the build number)
    new_version_android=$(grep "version:" pubspec.yaml | awk -F ' ' '{print $2}' | cut -d '+' -f 1)
    new_version_ios=$(grep "version:" pubspec.yaml | awk -F ' ' '{print $2}' | cut -d '+' -f 1)

    # Prompt user for release branch choice
    echo "Select a release type to create a branch:"
    echo "1. android-release"
    echo "2. ios-release"
    read -p "Enter your choice (1 or 2): " release_choice

    if [ "$release_choice" == "1" ]; then
        # Create android-release branch
        branch_name="release/${new_version_android}-android"
        git checkout -b "$branch_name"
        git push origin "$branch_name"
        echo "Branch ${branch_name} created and pushed to remote!"

    elif [ "$release_choice" == "2" ]; then
        # Create ios-release branch
        branch_name="release/${new_version_ios}-ios"
        git checkout -b "$branch_name"
        git push origin "$branch_name"
        echo "Branch ${branch_name} created and pushed to remote!"
    else
        echo "Invalid choice. No branch will be created."
        exit 1
    fi

    # Delete the local branch
    git checkout main  # Switch back to main branch
    git branch -D "$branch_name"  # Delete local branch
    echo "Local branch ${branch_name} deleted!"
}

if [ "$input" == '' ]; then 
    error
    exit
fi

if (( $input > 0 )) && (( $input < 4 )); then
    incrementAndroidVersion $input
    echo ''
    incrementIosVersion $input
    echo ''
    createReleaseBranch  # Create the release branch based on the user's choice
    echo ''
else 
    error
    exit
fi
