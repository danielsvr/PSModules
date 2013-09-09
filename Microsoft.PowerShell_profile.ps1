$profilepath = Split-Path $PROFILE -parent
& {cd $profilepath; git pull}
