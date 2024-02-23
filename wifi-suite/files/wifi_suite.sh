#!/bin/sh
# shellcheck disable=SC3060,SC3001

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

parse_flags() {
  nomfp=" ${BRIGHT_RED}[!MFP]${RESET}"
  flags=
  mode=
  [ -n "$1" ] || return
  [ -z "${1/*\[MFP]*}" ] && nomfp=
  [ -n "${1/*\[AUTH]*}" ] && flags="${flags}[!AUTH]"
  [ -n "${1/*\[ASSOC]*}" ] && flags="${flags}[!ASSOC]"
  [ -n "${1/*\[AUTHORIZED]*}" ] && flags="${flags}[!AUTHORIZED]"
  [ -n "${1/*\[WMM]*}" ] && flags="${flags}[!WMM]"
  if [ -z "${1/*\[HE]*}" ]; then
    mode="${BRIGHT_GREEN}Wi-Fi 6${RESET}"
  elif [ -z "${1/*\[VHT]*}" ]; then
    mode="Wi-Fi 5"
  elif [ -z "${1/*\[HT]*}" ]; then
    mode="${YELLOW}Wi-Fi 4${RESET}"
  elif [ "$hw_mode" = a ]; then
    mode="${BRIGHT_RED}802.11a${RESET}"
  elif [ -z "${1/*\[NonERP]*}" ]; then
    mode="${RED}802.11b${RESET}"
  else
    mode="${BRIGHT_RED}802.11g${RESET}"
  fi
  [ -n "$flags" ] && flags="${GREY}${flags}${RESET}"
}

get_akm() {
  suite="$1"
  case "$1" in
        00-0f-ac-1) if [ -z "$nomfp" ]; then akm="${GREEN}"; else akm=; fi; akm="${akm}802.1x"  ;;
        00-0f-ac-2) akm="${YELLOW}WPA-PSK"  ;;
        00-0f-ac-3) if [ -z "$nomfp" ]; then akm="${BRIGHT_GREEN}"; else akm="${GREEN}"; fi; akm="${akm}FT-802.1x"  ;;
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
        *)           akm="${GREY}undefined"  ;;
  esac
  akm="${akm}${RESET}"
}

get_signal() {
      if [ $(($1)) -ge 0 ]; then
	return
      elif [ "$1" -ge -50 ]; then
        signal="${BRIGHT_GREEN}"
      elif [ "$1" -ge -67 ]; then
        signal=
      elif [ "$1" -gt -80 ]; then
        signal="${YELLOW}"
      elif [ "$1" -gt -90 ]; then
        signal="${BRIGHT_RED}"
      else
        signal="${RED}"
      fi
      signal="${signal}$1"
}

get_eap_type() {
  eap_type="${1/*(/(}"
  if [ "$eap_type" = "(TLS)" ]; then
    eap_type="${BRIGHT_GREEN}(TLS)${RESET}"
  elif [ "$eap_type" = "(unknown)" ]; then
    eap_type="${GREY}(unknown)${RESET}"
  fi
}

cd /var/run/hostapd || exit 2
# shellcheck disable=SC3028
echo "${HOSTNAME}: Associated wifi stations' AKM suites:"
DEFAULT_IFS="$IFS"
for socket in *; do
  [ -S "$socket" ] || continue
  [ "$socket" = "global" ] && continue
  hw_mode=$(hostapd_cli -i "$socket" status | grep "^hw_mode=" | cut -f 2 -d"=")
  for assoc in $(hostapd_cli -i "$socket" list_sta); do
    signal="$GREY ? "
    mode="${GREY}unknown${RESET}"
    suite=
    akm="${GREY}undefined${RESET}"
    identity=
    eap_type=
    nomfp=
    IFS=
    while read -r line; do
      case "${line%%=*}" in
          AKMSuiteSelector)		suite="${line##*=}"		;;
	  flags)			parse_flags "${line##*=}"	;;
	  signal)			get_signal "${line##*=}"	;;
	  dot1xAuthSessionUserName)	identity="${line##*=}"		;;
	  last_eap_type_as)		get_eap_type "${line##*=}"	;;
      esac
    done < <(hostapd_cli -i "$socket" sta "$assoc")
    IFS="$DEFAULT_IFS"
    signal="${signal}dBm${RESET}"
    get_akm "$suite"
    [ -n "$identity" ] || {
      identity=$(sed -n -e "/$assoc.*# /{s/.*# //;p;q}" /etc/config/wireless)
    }
    printf "%-8s: %s signal=%s %s AKM suite: %s (%s)%s%s %s %s\n" \
           "$socket" "$assoc" "$signal" "$mode" "$suite" "$akm" "$nomfp" "$flags" "$identity" "${eap_type}"
  done
done
