#!/usr/bin/env python

# Managed by Puppet (dcache::array). Do NOT edit!

import sys

def usage():
    print "usage example: {0} desy14 desy15 TEMPLATE_FILE".format( sys.argv[0] )
    sys.exit(2)

if len( sys.argv ) != 4:
    usage()

array_host1 = sys.argv[1].strip()
array_host2 = sys.argv[2].strip()
template_file = sys.argv[3].strip()

if '.desy.de' in array_host1:
    array_host1=array_host1.split(".")[0]

if '.desy.de' in array_host2:
    array_host2=array_host2.split(".")[0]

if 'dcache-' in array_host1:
    array_host1=array_host1[7:]

if 'dcache-' in array_host2:
    array_host2=array_host2[7:]

if not array_host1.isalnum():
    usage()

if not array_host2.isalnum():
    usage()

if array_host1 == array_host2:
    usage()

config_template = open( template_file, 'r').read()

config = config_template % {
    'hostprefix' : 'dcache-',
    'host1' : array_host1,
    'host2' : array_host2,
}

print config

#f = open('dcache-{0}-{1}-array.cfg'.format( array_host1, array_host2 ), 'w')
#f.write( config )
#f.close()
