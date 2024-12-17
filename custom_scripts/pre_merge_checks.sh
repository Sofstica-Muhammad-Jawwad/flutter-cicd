#!/bin/sh

green='\033[0;32m'
red='\033[0;31m'
clear='\033[0m'

if ! dart format --set-exit-if-changed .; then
    echo "${red}Error: dart format failed. Please run 'dart format .' before merge to format your code.${clear}"
    exit 1
fi

if ! flutter analyze; then
    echo "${red}Error: flutter analyze found errors or warnings. Please fix the errors before pushing the code using 'flutter analyze'.${clear}"
    exit 1
fi

if ! flutter test; then
    echo "${red}Error: flutter test failed. Please fix failing tests before pushing the code.${clear}"
    exit 1
fi

echo "${green}All checks passed${clear}"
exit 0
