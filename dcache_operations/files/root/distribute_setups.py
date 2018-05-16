#!/usr/bin/env python

import xml.etree.ElementTree as ET
import fileinput, string, sys, os, argparse

parser = argparse.ArgumentParser(description='Distribute pool setups among the pools on this node.')
parser.add_argument('--test', dest='test_run', action='store_true')
parser.set_defaults(test_run=False)

args = parser.parse_args()
test_run = args.test_run

tree = ET.parse('/etc/dcache/all.pools.setup.xml')
pools = tree.getroot()

for pool in pools:
        print "Distribution setup file for", pool[0].text
	filename = pool[1].text + '/setup'
	if test_run :
		filename += '.puppet'
        setup_file = open( filename,'w' )
        setup_file.write( pool[2].text )
        setup_file.close()
