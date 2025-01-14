#!/usr/bin/env bash

# This script is used on main repo via travis.
# It enables travis jobs to store builds on S3 for release packaging

function setup {
    x_aws_credentials
    x_aws_install
    x_aws_env
    
}

function synchronize_down {
    "/c/Program Files/Amazon/AWSCLI/bin/aws" s3 sync s3://fritzing/"$TRAVIS_BUILD_NUMBER" "$HOME/$TRAVIS_BUILD_NUMBER"
}

function synchronize_up {
    "/c/Program Files/Amazon/AWSCLI/bin/aws" s3 sync "$HOME/$TRAVIS_BUILD_NUMBER" s3://fritzing/"$TRAVIS_BUILD_NUMBER"
}

function cleanup {
    "/c/Program Files/Amazon/AWSCLI/bin/aws" s3 rm --recursive s3://fritzing/"$TRAVIS_BUILD_NUMBER" # clean up after ourselves
}

function x_aws_install {
    case "$TRAVIS_OS_NAME" in
        linux*)
            pip install --user awscli
            ;;
        osx*)
            pip3 install --user awscli
            ;;
        windows*)
            choco install awscli
            # type "C:/ProgramData/chocolatey/logs/chocolatey.log"
            ;;
    esac
}

function x_aws_env {
    case "$TRAVIS_OS_NAME" in
        linux*)
            export PATH=$HOME/.local/bin:$PATH
            ;;
        osx*)
            export PATH=$HOME/Library/Python/3.7/bin:$PATH
            ;;
        windows*)
            export PATH="$PATH:$USERPROFILE/AppData/Local/Programs/Python/Python37/Scripts:/c/Program Files/Amazon/AWSCLI/bin"
            ;;
    esac
}

function x_aws_credentials {
    mkdir -p "$HOME"/.aws
    cat > "$HOME"/.aws/credentials << EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL
}

echo "Running deploy task '$1' on $TRAVIS_OS_NAME ( $OSTYPE )"
$1;

