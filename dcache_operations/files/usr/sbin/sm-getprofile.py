#!/usr/bin/python

import json
import re
import subprocess
import sys

# A helper function that executes a programm and returns the output
def execute(params):
    try:
        proc = subprocess.Popen(params, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        # if returncode != 0 exit script
        if proc.returncode:
            sys.exit(proc.returncode)
        return out
    except:
        sys.exit(1)

try:
    # SMcli localhost -c "show storageArray profile;"
    summary = execute(['SMcli', 'localhost', '-c', 'show storageArray profile;'])

    # Finding list of all disks
    diskDataLines = re.search(r'\s*Physical Disk\s*\n.*\s*\n((.|\n)*)\n*(SNMP SUMMARY|DISK POOLS)', summary).group(1).splitlines()

    # Find aditional array information
    arrayInfo = re.search(r'\s*Storage Array\s+Storage Array Name:\s+([\w|-]+)\s+Current Package Version:\s+([\d|.]+)\s+Current NVSRAM Version:\s+([\w|-]+)', summary).groups()

    disks = set()
    # Add disk "Manufacturer-ProductId-Version" into a set
    for disk in diskDataLines:
        dataChunks = re.split(r'\s{2,}', disk.strip())
        if len(dataChunks) != 7:
            continue
        disks.add('%s-%s-%s' % (dataChunks[1], dataChunks[2], dataChunks[5]))


    # Define JSON Output
    output = dict()

    output['array_disks'] = list(disks)
    output['array_name'] = arrayInfo[0]
    output['array_nvsram_version'] = arrayInfo[2]
    output['array_package_version'] = arrayInfo[1]

    # Print JSON
    print(json.dumps(output))
except:
    #Empty JSON
    print('{}')
