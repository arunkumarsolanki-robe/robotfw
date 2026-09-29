*** Settings ***
Library    SerialLibrary
Library    String
Library           Process
Library           OperatingSystem
Resource          variables.robot

*** Variables ***
${OUTPUT_DIR}    ${CURDIR}/../Output
${PORT}          COM32          # Or /dev/ttyUSB0 on Linux
${BAUD}          115200
${TERMINATOR}    \r\n

*** Keywords ***
Connect To Nordic Device
# 1. Clean up any existing port sessions first
    delete all ports
    Add Port    ${PORT}    baudrate=${BAUD}    timeout=2
    Open Port   ${PORT}
    Reset Input Buffer    ${PORT}
    Send AT Command    AT+MFGSECAUTH=1,*QBOXcnuuEqil3Rl
#Authorize Device
#    [Documentation]    Sends the MFG Security Auth code to enable write commands.
#    ${auth_cmd} =    Set Variable    AT+MFGSECAUTH=1,asu'zfzU{Mj#O[4V
#    Log To Console    \nSending Auth Code...
#    ${status} =       Send AT Command    ${auth_cmd}

#    # If successful, the device should return "OK"
#    IF    '${status}' != 'OK'
#        Fatal Error    Device Authorization Failed! State: ${status}
#    END
#    Log To Console    Authorization Successful. Device is now in Write Mode.

Send AT Command
    [Arguments]    ${command}
    # 1. Send the command
    Write Data     ${command}${TERMINATOR}    encoding=utf-8

    # 2. Read the response (currently coming in as Hex)
    ${hex_response} =  Read Until    ${TERMINATOR}

    # 3. Convert Hex to String (Removes spaces and decodes)
    ${clean_hex} =     Remove String    ${hex_response}    ${SPACE}
    ${bytes} =         Evaluate    bytes.fromhex('${clean_hex}')
    ${response} =      Evaluate    $bytes.decode('utf-8')

    Log    Decoded Response: ${response}
    RETURN    ${response}

Select hex file and create jLink script for flash the DUT
    [Arguments]    ${hex_or_bin_file}
    Log To Console    ${\n}--- Starting Hardware Flashing Sequence ---
    
    # 1. Verify file exists
    File Should Exist    ${hex_or_bin_file}    msg=The firmware file '${hex_or_bin_file}' was not found!
    
    # 2. Build the script using explicit newline breaks
    # This prevents syntax errors inside the J-Link engine
    ${script_content}=    Catenate    SEPARATOR=${\n}
    ...    ExitOnError 1
    ...    r
    ...    h
    ...    erase
    ...    loadfile "${hex_or_bin_file}"
    ...    r
    ...    g
    ...    q
    Create File    ${SCRIPT_PATH}    ${script_content}
    
Set the Device for the J-Link tool
    ${process}=    Run Process    ${JLINK_EXE_PATH}    
    ...    -device         ${TARGET_DEVICE}    
    ...    -if             ${INTERFACE}    
    ...    -speed          ${SPEED_KHZ}    
    ...    -autoconnect    1    
    ...    -CommanderScript    ${SCRIPT_PATH}
    
    # Extract only the exact properties you need right away
    Set Suite Variable    $JLINK_OUTPUT    ${process.stdout}
    Set Suite Variable    $JLINK_RC        ${process.rc}
    
Cleanup jLink file from current directory
    Remove File    ${SCRIPT_PATH}
    
Verify Flash Result
    Log To Console    ${\n}=== J-LINK HARDWARE OUTPUT ===
    Log To Console    ${JLINK_OUTPUT}
    Log To Console    ============================
    Should Be Equal As Integers    ${JLINK_RC}    0    
    ...    msg=JLink process exited with code ${JLINK_RC}. See the hardware output printed above!


