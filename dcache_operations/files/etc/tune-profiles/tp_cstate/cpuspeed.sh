#!/bin/bash

# Managed by Puppet (gpfs)
# Do NOT edit, changes will be overwritten!

. /usr/lib/tuned/functions

start() {
    cpupower idle-set -D 3
    cpupower frequency-set -g performance
    return 0
}

stop() {
    cpupower idle-set -E
    cpupower frequency-set -g powersave
    return 0
}

process $@
