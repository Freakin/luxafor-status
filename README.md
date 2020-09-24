# Luxafor Status

The [Luxafor Bluetooth](https://luxafor.com/bluetooth-busy-light-availability-indicator/) is a bluetooth status light which can be used to indicate availability to those around you.

This is designed to check whether user is active in a Webex meeting (`status=meeting`), and if so, set the Luxafor status light to red.  If user is not in a meeting (`status=inactive`) then the light will be set to green.

Copy `vars_example.sh` to `vars.sh` and update with appropriate variables.  You'll need to get a persistent Webex access token by setting up a [New Bot](https://developer.webex.com/my-apps/new/bot)

The `update-status.sh` script should be scheduled every minute.