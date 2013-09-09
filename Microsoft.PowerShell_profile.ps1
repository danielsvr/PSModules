$profilepath = Split-Path $PROFILE -parent
powershell -NoProfile -Command "cd $profilepath; git pull"
