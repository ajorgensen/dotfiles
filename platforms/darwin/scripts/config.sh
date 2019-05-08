#!/bin/bash

HOME_DIR=$1

# configure npm
 npm config set prefix "${HOME_DIR}/.npm-global"
