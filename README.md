# sh-shelly-check-firmware

Do you need a simple way to check firmware updates for Shelly smart plugs without complicating things with dependencies? This is your script.

It only requires having the command-line tools curl and jq installed.

You need to have access credentials (password) configured for your Shelly device and have the RPC API enabled. The script assumes that all devices share the same credentials (password).

## INSTALL

Copy **shelly-check-firmware.sh** to **/usr/local/bin**

Add exec permissions to **shelly-check-firmware.sh**

> sudo chmod +x /usr/local/bin/shelly-check-firmware.sh

Copy **shelly-check-firmware.conf** to **/usr/local/etc** and customize/edit your settings

## USAGE

### Manual launch:

> sh /usr/local/bin/shelly-check-firmware.sh /usr/local/etc/shelly-check-firmware.conf

## TODO

create debian package
