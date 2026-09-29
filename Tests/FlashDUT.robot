*** Settings ***
Resource          ../Resource/nordic_ble_keywords.resource

*** Variables ***
# Update this to the exact path of your compiled .hex or .bin file
${FIRMWARE_FILE}  ${CURDIR}/../Data/NordicApp1.hex

*** Test Cases ***
Verify Firmware Flashing by jLink
    [Documentation]    Dynamically generates the command script, clears flash, loads firmware, and reboots the target chip.
    [Tags]             Hardware    Flashing
    Select hex file and create jLink script for flash the DUT    ${FIRMWARE_FILE}
    Set the Device for the J-Link tool
    Verify Flash Result
    Cleanup jLink file from current directory
