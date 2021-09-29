#!/bin/sh
# Copyright (C) 2021 Eneas Ulir de Queiroz <cotequeiroz@gmail.com>
# SPDX-License: GPL-2.0-or-later

handle_signal()
{
    kill %
}

trap handle_signal 10 # USR1

grep 'Rekeying PTK' /dev/kmsg | while IFS= read -r line; do
    MAC=$(echo "$line" | sed 's/.*STA \([^ ]\+\) .*/\1/')
    for i in $(ubus list 'hostapd.*' | sed 's/hostapd\.//'); do
        iw "$i" station get "$MAC" > /dev/null 2>&1 || continue
        echo hostapd_cli -i "$i" disassociate "$MAC"
        hostapd_cli -i "$i" disassociate "$MAC"
    done
done &
# If we just run in the foreground, the grep and |while processes
# will be left running after the service stops.  One way around
# the problem is to fork and wait, trapping SIGUSR1 to kill it.
wait %
