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
  flags=
  redflags=
  greyflags=
  mode=
  [ -n "$1" ] || return
  [ -n "${1/*\[MFP]*}" ] && redflags="[!MFP]"
  [ -n "${1/*\[AUTH]*}" ] && greyflags="[!AUTH]"
  [ -n "${1/*\[ASSOC]*}" ] && greyflags="${greyflags}[!ASSOC]"
  [ -n "${1/*\[AUTHORIZED]*}" ] && greyflags="${greyflags}[!AUTHORIZED]"
  [ -n "${1/*\[WMM]*}" ] && redflags="${redflags}[!WMM]"
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
  flags="${redflags:+${BRIGHT_RED}${redflags}}${greyflags:+${GREY}${greyflags}}"
  flags="${flags}${flags:+${RESET}}"
}

get_curve() {
  case "$1" in
	"") sae_group="-${GREY}undef"  ;;
	19) sae_group="-${GREEN}p256-SHA256"  ;;
	20) sae_group="-${BRIGHT_GREEN}p384-SHA386"  ;;
	21) sae_group="-${BRIGHT_GREEN}p521-SHA512"  ;;
	25) sae_group="-${BRIGHT_RED}p192-SHA256"  ;;
	26) sae_group="-${YELLOW}p224-SHA256"  ;;
	28) sae_group="-${GREEN}Bp256-SHA256"  ;;
	29) sae_group="-${BRIGHT_GREEN}Bp384-SHA384"  ;;
	30) sae_group="-${BRIGHT_GREEN}Bp512-SHA512"  ;;
	*)  sae_group="-${GREY}group=$sae_group" ;;
  esac
  sae_group="${sae_group}${RESET}"
}

get_akm() {
  case "$1" in
	"") return  ;;
	00-0f-ac-1) akm="${YELLOW}802.1x-SHA1"  ;;
	00-0f-ac-2) akm="${YELLOW}PSK-SHA1"  ;;
	00-0f-ac-3) akm="${BRIGHT_GREEN}FT-802.1x-SHA256"  ;;
	00-0f-ac-4) akm="${GREEN}FT-PSK-SHA256"  ;;
	00-0f-ac-5) akm="${GREEN}802.1x-SHA256"  ;;
	00-0f-ac-6) akm=PSK-SHA256  ;;
	00-0f-ac-7) akm=TDLS-SHA256  ;;
	00-0f-ac-8) akm="${GREEN}SAE${sae_group}" ;;
	00-0f-ac-9) akm="${BRIGHT_GREEN}FT-SAE${sae_group}"  ;;
	00-0f-ac-10) akm=APPeerKey-SHA256  ;;
	00-0f-ac-11) akm=802.1x-suite-B-SHA256  ;;
	00-0f-ac-12) akm="${GREEN}802.1x-suite-B-192-SHA384"  ;;
	00-0f-ac-13) akm="${BRIGHT_GREEN}FT-802.1x-SHA384"  ;;
	00-0f-ac-14) akm="${GREEN}FILS-SHA256"  ;;
	00-0f-ac-15) akm="${GREEN}FILS-SHA384"  ;;
	00-0f-ac-16) akm="${BRIGHT_GREEN}FT-FILS-SHA256"  ;;
	00-0f-ac-17) akm="${BRIGHT_GREEN}FT-FILS-SHA384"  ;;
	00-0f-ac-18) akm="${GREEN}OWE"  ;;
	00-0f-ac-19) akm="${GREEN}FT-PSK-SHA384"  ;;
	00-0f-ac-20) akm=PSK-SHA384  ;;
	*)	     akm="${GREY}AKM:$1"  ;;
  esac
  akm="${akm}${RESET}"
}

get_pairwise() {
  case "$1" in
	"") return  ;;
	00-0f-ac-0) pairwise="${RED}Use-group-cipher"  ;;
	00-0f-ac-1) pairwise="${RED}WEP-40"  ;;
	00-0f-ac-2) pairwise="${BRIGHT_RED}TKIP"  ;;
	00-0f-ac-4) pairwise=CCMP-128  ;;
	00-0f-ac-5) pairwise="${RED}WEP-104"  ;;
	00-0f-ac-6) pairwise=BIP-CMAC-128  ;;
	00-0f-ac-7) pairwise="${GREY}group-traffic-disallowed"  ;;
	00-0f-ac-8) pairwise="${GREEN}GCMP-128"  ;;
	00-0f-ac-9) pairwise="${BRIGHT_GREEN}GCMP-256"  ;;
	00-0f-ac-10) pairwise="${GREEN}CCMP-256"  ;;
	00-0f-ac-11) pairwise="${GREEN}BIP-GMAC-128"  ;;
	00-0f-ac-12) pairwise="${BRIGHT_GREEN}BIP-GMAC-256"  ;;
	00-0f-ac-13) pairwise="${GREEN}BIP-CMAC-256"  ;;
	*)	     pairwise="${GREY}Pairwise:$1"  ;;
  esac
  pairwise="${pairwise}${RESET}"
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
  eap_num="${1%% *}"
  eap_type="${1##*\(}"
  eap_type="${eap_type%)}"
  case "$eap_num" in
	13)				color="${BRIGHT_GREEN}"	;; # TLS
	21 |25 |43 |50 |55)		color="${GREEN}"	;; # TTLS PEAP FAST AKA' TEAP
	1 |46 |47 |49 |51 |52 |53 |254)	color=			;; # Unauth-TLS/WSC PAX PSK IKEv2 GPSK PWD EKE Expanded-Types
	18 |23 |48)			color="${YELLOW}"	;; # SIM AKA SAKE
	17 |26)				color="${BRIGHT_RED}"	;; # LEAP MSCHAPv2
	4 |5 |6)			color="${RED}"		;; # MD5, OTP, GTC
	0 |2 |3 |33 |38 |255)		color="${GREY}"		;; # Reserved, Notification, NAK, TLV, TNC, Experimental
	*)				color=; eap_type="${eap_type}($eap_num)"  ;;
  esac
  eap_type="-${color}EAP-${eap_type}${color:+$RESET}"
}

cd /var/run/hostapd || exit 2
# shellcheck disable=SC3028
echo "${HOSTNAME}: Associated wifi stations:"
DEFAULT_IFS="$IFS"
for socket in *; do
  [ -S "$socket" ] || continue
  [ "$socket" = "global" ] && continue
  hw_mode=$(hostapd_cli -i "$socket" status | grep "^hw_mode=" | cut -f 2 -d"=") || continue
  for assoc in $(hostapd_cli -i "$socket" list_sta); do
    signal="$GREY ? "
    mode="${GREY}unknown${RESET}"
    akm_int=
    akm="${GREY}undef${RESET}"
    pairwise_int=
    pairwise="${GREY}undef${RESET}"
    identity=
    eap_type=
    flags=
    sae_group=
    IFS=
    while read -r line; do
      val="${line##*=}"
      case "${line%%=*}" in
	  AKMSuiteSelector)			akm_int="${val}"	;;
	  flags)				parse_flags "${val}"	;;
	  signal)				get_signal "${val}"	;;
	  dot1xAuthSessionUserName)		identity="${val}"	;;
	  dot11RSNAStatsSelectedPairwiseCipher)	pairwise_int="${val}"	;;
	  last_eap_type_as)			get_eap_type "${val}"	;;
	  sae_group)				get_curve "${val}"	;;
      esac
    done < <(hostapd_cli -i "$socket" sta "$assoc")
    IFS="$DEFAULT_IFS"
    signal="${signal}dBm${RESET}"
    get_akm "$akm_int"
    get_pairwise "$pairwise_int"
    [ -z "$identity" ] && identity=$(sed -n -e "/$assoc.*# /{s/.*# //;p;q}" /etc/config/wireless)
    [ -z "$identity" ] && identity=$(grep "$assoc" /tmp/dhcp.leases 2>/dev/null | awk '{print $4}')
    printf "%-8s: %s signal=%s %s %s%s/%s%s %s\n" \
	   "$socket" "$assoc" "$signal" "$mode" "$akm" "$eap_type" "$pairwise" "$flags" "$identity"
  done
done
