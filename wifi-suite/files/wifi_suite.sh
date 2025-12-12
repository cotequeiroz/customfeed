#!/bin/sh
# shellcheck disable=SC3060,SC3001,SC3028

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
LEASEFILE=$(uci get dhcp.@dnsmasq[0].leasefile 2>/dev/null)
LEASEFILE="${LEASEFILE:-/tmp/dhcp.leases}"

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
	"") sae_group="-${GREY}undef" sae_hash=  ;;
	 1) sae_group="-${GREY}FF768" sae_hash=-SHA256  ;;
	 2) sae_group="-${GREY}FF1024" sae_hash=-SHA256  ;;
	 3) sae_group="-${GREY}EC2N-155" sae_hash=-SHA256  ;;
	 4) sae_group="-${GREY}EC2N-185" sae_hash=-SHA256  ;;
	 5) sae_group="-${RED}FF1536" sae_hash=-SHA256  ;;
	 6) sae_group="-${RED}sect163r1" sae_hash=-SHA256  ;;
	 7) sae_group="-${RED}K163" sae_hash=-SHA256  ;;
	 8) sae_group="-${BRIGHT_RED}B283" sae_hash=-SHA384  ;;
	 9) sae_group="-${BRIGHT_RED}K283" sae_hash=-SHA384  ;;
	10) sae_group="-${BRIGHT_RED}B409" sae_hash=-SHA512  ;;
	11) sae_group="-${BRIGHT_RED}K409" sae_hash=-SHA512  ;;
	12) sae_group="-${BRIGHT_RED}B571" sae_hash=-SHA512  ;;
	13) sae_group="-${BRIGHT_RED}K571" sae_hash=-SHA512  ;;
	14) sae_group="-${BRIGHT_RED}FF2048" sae_hash=-SHA256  ;;
	15) sae_group=-FF3072 sae_hash=-SHA384  ;;
	16) sae_group=-FF4096 sae_hash=-SHA512  ;;
	17) sae_group=-FF6144 sae_hash=-SHA512  ;;
	18) sae_group=-FF8192 sae_hash=-SHA512  ;;
	19) sae_group=-P256 sae_hash=-SHA256  ;;
	20) sae_group=-P384 sae_hash=-SHA384  ;;
	21) sae_group=-P521 sae_hash=-SHA512  ;;
	22) sae_group="-${GREY}FF1024q160" sae_hash=-SHA256  ;;
	23) sae_group="-${RED}FF2048q224" sae_hash=-SHA256  ;;
	24) sae_group="-${RED}FF2048q256" sae_hash=-SHA256  ;;
	25) sae_group="-${BRIGHT_RED}P192" sae_hash=-SHA256  ;;
	26) sae_group="-${BRIGHT_RED}P224" sae_hash=-SHA256  ;;
	27) sae_group="-${BRIGHT_RED}BP224" sae_hash=-SHA256  ;;
	28) sae_group="-${YELLOW}BP256" sae_hash=-SHA256  ;;
	29) sae_group="-${YELLOW}BP384" sae_hash=-SHA384  ;;
	30) sae_group="-${YELLOW}BP512" sae_hash=-SHA512  ;;
	31) sae_group=-X25519 sae_hash=-SHA256  ;;
	32) sae_group=-X448 sae_hash=-SHA512  ;;
	*)  sae_group="-${GREY}group=$sae_group" sae_hash= ;;
  esac
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
	00-0f-ac-8) akm="${GREEN}SAE${sae_group}-SHA256" ;;
	00-0f-ac-9) akm="${BRIGHT_GREEN}FT-SAE${sae_group}-SHA256"  ;;
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
	00-0f-ac-24) akm="${GREEN}SAE${sae_group}${sae_hash}" ;;
	00-0f-ac-25) akm="${BRIGHT_GREEN}FT-SAE${sae_group}${sae_hash}"  ;;
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
    color="${BRIGHT_GREEN}"
  elif [ "$1" -ge -67 ]; then
    color=
  elif [ "$1" -gt -80 ]; then
    color="${YELLOW}"
  elif [ "$1" -gt -90 ]; then
    color="${BRIGHT_RED}"
  else
    color="${RED}"
  fi
  echo "${color}$1dBm${color:+${RESET}}"
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

print_assoc() {
  if [ -z "$last_ack_signal" ]; then
    signal="${signal:-${GREY} ? ${RESET}}"
  else
    signal="${signal}(${last_ack_signal})"
  fi
  get_akm "$akm_int"
  get_pairwise "$pairwise_int"
  [ -z "$identity" ] && \
    identity=$(sed -n -e "/$assoc.*# /{s/.*# //;p;q}" /etc/config/wireless)
  [ -z "$identity" ] && \
    identity=$(sed -n -e "/ $assoc /{s/.* $assoc [^ ]\\+ \\([^ ]\\+\\).*/\\1/;p;q}" \
		   "${LEASEFILE:-/tmp/dhcp.leases}")
  printf "%-8s: %s %s%s %s %s%s/%s%s %s\n" \
	 "$socket" "$assoc" "$signal" "$inactive_sec" "$mode" "$akm" "$eap_type" \
	 "$pairwise" "$flags" "$identity"
}

cd /var/run/hostapd || exit 2
IFS=
echo "${HOSTNAME}: Associated wifi stations:"
for socket in *; do
  [ -S "$socket" ] || continue
  [ "$socket" = "global" ] && continue
  hw_mode=$(hostapd_cli -i "$socket" status | grep "^hw_mode=" | cut -f 2 -d"=") || continue
  assoc=
  while read -r line; do
    val="${line##*=}"
    case "${line%%=*}" in
	??:??:??:??:??:??)			
		[ -n "$assoc" ] && print_assoc
		akm="${GREY}undef${RESET}"
		akm_int=
		assoc="${line}"
		eap_type=
		flags=
		identity=
		inactive_sec=
		last_ack_signal=
		mode="${GREY}unknown${RESET}"
		pairwise="${GREY}undef${RESET}"
		pairwise_int=
		sae_group=
		signal=
		;;
	AKMSuiteSelector)
		akm_int="${val}"
		;;
	flags)
		parse_flags "${val}"
		;;
	inactive_msec)
		inactive_sec=" ($((val/1000))s)"
		;;
	last_ack_signal)
		last_ack_signal=$(get_signal "${val}")
		;;
	signal)
		signal=$(get_signal "${val}")
		;;
	dot1xAuthSessionUserName)
		identity="${val}"
		;;
	dot11RSNAStatsSelectedPairwiseCipher)
		pairwise_int="${val}"
		;;
	last_eap_type_as)
		get_eap_type "${val}"
		;;
	sae_group)
		get_curve "${val}"
		;;
    esac
  done < <(hostapd_cli -i "$socket" all_sta)
  [ -n "$assoc" ] && print_assoc
done
