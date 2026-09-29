*** Variables ***
# Target settings mapped from system benchmarks
${TARGET_DEV}     gst-010005781934
${MAC_ADDR}       E6:E6:C7:A8:32:14
${AUTH_KEY}       AT+MFGSECAUTH=1,*QBOXcnuuEqil3Rl

# Update this path to match your installation (use JLink.exe for Windows, JLinkExe for Linux/macOS)
${JLINK_EXE_PATH}    C:\\Program Files\\SEGGER\\JLink\\JLink.exe
${TARGET_DEVICE}     nRF52840_xxAA
# ${TARGET_DEVICE}     STM32U575RI
${INTERFACE}         SWD
${SPEED_KHZ}         4000
${SCRIPT_PATH}       ${CURDIR}/generated_flash.jlink
