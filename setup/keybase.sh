#!/usr/bin/env bash

keybase pgp export | gpg --import
keybase pgp export --secret | gpg --import --allow-secret-key-import
