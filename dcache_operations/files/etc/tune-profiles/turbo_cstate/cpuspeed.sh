#!/bin/bash

# Managed by Puppet (dcache)
# Do NOT edit, changes will be overwritten!

. /usr/lib/tuned/functions

start() {
    cpupower idle-set -D 0
    cpupower frequency-set -g performance
    return 0
}

stop() {
    cpupower idle-set -E
    cpupower frequency-set -g powersave
    return 0
}

process $@
