#!/bin/sh

ansi() {
  printf "\033[%sm" "$1"
}

RESET=$(ansi 0)
RED=$(ansi 31)
BRIGHT_RED=$(ansi 91)
YELLOW=$(ansi 93)
GREEN=$(ansi 32)
BRIGHT_GREEN=$(ansi 92)
GREY=$(ansi 90)

cd /var/run/hostapd || exit 2
# shellcheck disable=SC3028
echo "${HOSTNAME}: Associated wifi stations' AKM suites:"
for socket in *; do
  [ -S "$socket" ] || continue
  [ "$socket" = "global" ] && continue
  hw_mode=$(hostapd_cli -i "$socket" status | grep "^hw_mode=" | cut -f 2 -d"=")
  for assoc in $(hostapd_cli -i "$socket" list_sta); do
    mfp=
    suite=$(hostapd_cli -i "$socket" sta "$assoc" | grep "AKMSuiteSelector" | cut -f 2 -d"=")
    flags=$(hostapd_cli -i "$socket" sta "$assoc" | grep "^flags=" | cut -f 2 -d"=")
    signal=$(hostapd_cli -i "$socket" sta "$assoc" | grep "^signal=" | cut -f 2 -d"=")
    if [ $((signal)) -ge 0 ]; then
      signal="$GREY ? "
    elif [ "$signal" -ge -50 ]; then
      signal="${BRIGHT_GREEN}${signal}"
    elif [ "$signal" -ge -67 ]; then
      :
    elif [ "$signal" -gt -80 ]; then
      signal="${YELLOW}${signal}"
    elif [ "$signal" -gt -90 ]; then
      signal="${BRIGHT_RED}${signal}"
    else
      signal="${RED}${signal}"
    fi
    signal="${signal}dBm${RESET}"
    echo "$flags" | grep -q '\[MFP]' || mfp="${BRIGHT_RED}[no-MFP]${RESET}"
    if echo "$flags" | grep -q '\[HE]'; then
      mode="${BRIGHT_GREEN}Wi-Fi 6${RESET}"
    elif echo "$flags" | grep -q '\[VHT]'; then
      mode="Wi-Fi 5"
    elif echo "$flags" | grep -q '\[HT]'; then
      mode="${YELLOW}Wi-Fi 4${RESET}"
    elif [ "$hw_mode" = a ]; then
      mode="${BRIGHT_RED}802.11a${RESET}"
    elif echo "$flags" | grep -q '\[NonERP]'; then
      mode="${RED}802.11b${RESET}"
    else
      mode="${BRIGHT_RED}802.11g${RESET}"
    fi
    case "$suite" in
        00-0f-ac-1) if [ -z "$mfp" ]; then akm="${GREEN}"; else akm=; fi; akm="${akm}802.1x"  ;;
        00-0f-ac-2) akm="${YELLOW}WPA-PSK"  ;;
        00-0f-ac-3) if [ -z "$mfp" ]; then akm="${BRIGHT_GREEN}"; else akm="${GREEN}"; fi; akm="${akm}FT-802.1x"  ;;
        00-0f-ac-4) akm="${GREEN}WPA-PSK-FT"  ;;
        00-0f-ac-5) akm="${GREEN}802.1x-SHA256"  ;;
        00-0f-ac-6) akm=WPA-PSK-SHA256  ;;
        00-0f-ac-7) akm=TDLS  ;;
        00-0f-ac-8) akm="${GREEN}WPA3-SAE"  ;;
        00-0f-ac-9) akm="${BRIGHT_GREEN}FT-SAE"  ;;
        00-0f-ac-10) akm=AP-PEER-KEY  ;;
        00-0f-ac-11) akm="${GREEN}802.1x-suite-B"  ;;
        00-0f-ac-12) akm="${GREEN}802.1x-suite-B-192"  ;;
        00-0f-ac-13) akm="${BRIGHT_GREEN}FT-802.1x-SHA384"  ;;
        00-0f-ac-14) akm="${GREEN}FILS-SHA256"  ;;
        00-0f-ac-15) akm="${GREEN}FILS-SHA384"  ;;
        00-0f-ac-16) akm="${BRIGHT_GREEN}FT-FILS-SHA256"  ;;
        00-0f-ac-17) akm="${BRIGHT_GREEN}FT-FILS-SHA384"  ;;
        00-0f-ac-18) akm="${GREEN}OWE"  ;;
        00-0f-ac-19) akm="${GREEN}FT-WPA2-PSK-SHA384"  ;;
        00-0f-ac-20) akm=WPA2-PSK-SHA384  ;;
        *) akm="${GREY}undefined" ;;
    esac
    akm="${akm}${RESET}"
    printf "%-8s: %s signal=%s %s AKM suite: %s (%s) %s\n" \
           "$socket" "$assoc" "$signal" "$mode" "$suite" "$akm" "$mfp"
  done
done
