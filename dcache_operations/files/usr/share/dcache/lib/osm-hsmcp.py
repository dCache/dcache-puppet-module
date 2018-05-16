#!/usr/bin/python 
# osm anbindung an dcacheinstanz
# uri [scheme:][//authority][path][?query][#fragment]
# 
# Version       Datum   Aenderung
#-----------------------------------------------------------------------------
# 0.1           '09     initial
# 0.2           08.09   beseitigung von bugs
# 0.3           12.09   null byte files, duplicate write
# 0.4           01.10   write bitfileid check verfeinert und korrekte rc code auswertung
# 0.5           02.10   multi uri auswertung, osm-timeout , leere files
# 0.6           05.10   split aufruf auswertung von '='
# 0.7           10.10   error 8 bzw 173 (label invalid) und returncode
# 0.72          02.11   error in filesize test                        
# 0.73          06.11   error 183 mehrere kopien
# 0.74          04.12   benutzung von mehrere kopien bei bad, offlines tapes
# 0.75          05.12   duplikat herstellen / entweder dupstore oder dupgroup
# 0.76          07.12   duplikat herstellen / ueber sgroup tag
# 0.77          09.12   bitfile im success log ausgeben
# 0.78          10.15   keine Ausgabe von PNFS pfad im syslog  und smallfile uri check fix fuer parsen
# 0.79          01.16   keine kopie lesbar und keine weitere vorhanden 
# 0.80          07.16   checksum uebergabe aus dem dcache
import os
import sys
import string
import time
import getopt
import commands
import syslog

# osm error definitions for local disk IO errors
# fehlercodes
VERSION_STRING="osm-hsmcp.py v0.80"
OSM_ETOBIG=8
OSM_EUNKNOWN=9
OSM_ENOSPACE=74
OSM_ETAPEIO=81
OSM_EIOSPACE=120
OSM_TOFFLINE=150
OSM_ENOSERVER=166
OSM_EINLABEL=173
OSM_BCONNECT=187
OSM_EIOREAD =242
OSM_EIOWRITE=243
#
OSM_TIMEOUT=86400
# loglevel 
# 0 = normal 
# 1 = verbose 
# 2 = debug
loglevel=0
#default
dupli="none"

def osmlog(tofile):
  lt=time.localtime()
  lf=open('/var/log/osmcp.log', 'a+')
  dtime = time.strftime("%d.%m.%Y %H:%M:%S", lt)
  lf.write("%s %s\n" % (dtime,tofile))
  lf.close()

def usage():
  osmlog(VERSION_STRING)
  osmlog("Usage : put|get <pnfsId> <filePath> [-si=<storageInfo>] [-uri=<uri>] [-dupli=none/store/group/tag] [-key[=value] ...]")  

def GetUri(feld,llevel):
  urio,urio1=string.split(uri[llevel],'?')
  uriopt=string.split(urio1,'&')
  for o in uriopt:
    optb,arg=string.split(o,'=')
    if ((optb in ['store','group','bfid','tape','pos']) & (optb == feld)):
      return arg

def GetStorageInformation(feld):
  for o in siopt:
    if ((o[:4] != "osm:") & (len(o)>0)):
      optb,arg=string.split(o,'=',1)
      if (((optb == "hsm")|(optb == "stored")|(optb == "size")|(optb == "store")|(optb == "group")|(optb == "path")|(optb == "uid")|(optb == "mode")|(optb == "size")|(optb =="flag-c")) & (optb == feld)):
        return arg
  return "none"

def GetDataFromHsm():
  if (loglevel!=0): 
    osmlog ("GET %s - startet - %s" % (PnfsID,VERSION_STRING))
  if (loglevel==1): 
    osmlog  (("restore from %s to %s" % (PnfsID,PnfsPathFile))) 
  llevel=0
  if ((GetStorageInformation("hsm") == "osm") & (GetStorageInformation("stored")=="true")):
    crc=GetStorageInformation("flag-c")
    while llevel < level :
      osmbitfile=GetUri("bfid",llevel)
      osmstore=GetUri("store",llevel)
      if (loglevel==2):
        osmlog ("GET %s -si  = %s " % (PnfsID,siopt))
      if (loglevel!=0):
        osmlog ("GET %s -uri = %s " % (PnfsID,uri))
      if (osmbitfile == '*'):
        osmlog("GET %s - touch %s" % (PnfsID,PnfsPathFile))
        outputerror,output=commands.getstatusoutput("touch %s" % PnfsPathFile)
      else:
        if ((osmbitfile.count(':') == 1) & (len(osmbitfile) == 73)):
          osmlog("GET %s - is smallfile Uri %s" % (PnfsID,osmbitfile))
        if ((osmbitfile.count('.') == 2) & (len(osmbitfile) == 34)):
          outputerror,output=commands.getstatusoutput("osmcp -v -S %s -t %s -B %s %s" % (osmstore,OSM_TIMEOUT,osmbitfile,PnfsPathFile))
          if outputerror > 256:
            outputerror/=256
        else:
          output="bitfile is wrong"
          outputerror=OSM_EIOREAD
      if (loglevel==2):
        osmlog("GET %s - osmcp -S %s -t %s -B %s %s %s" % (PnfsID,osmstore,OSM_TIMEOUT,osmbitfile,PnfsPathFile,outputerror))
        osmlog("GET %s - %s"%(PnfsID,output))
      if (outputerror == 0):
        osmlog ("GET %s - %s succesfully ended" % (PnfsID,osmbitfile))
        sys.exit(0)
      elif (outputerror == OSM_EIOSPACE):
        osmlog ("GET %s - unsuccesfully ended error 41" % PnfsID)
      elif (outputerror == OSM_EIOREAD):
        osmlog ("GET %s - unsuccesfully ended error 42" % PnfsID)
      elif ((outputerror == OSM_EIOWRITE) | (outputerror == OSM_ETAPEIO)):
        osmlog ("GET %s - unsuccesfully ended error 43" % PnfsID)
        sys.exit(43)
      elif (outputerror == OSM_TOFFLINE):
        osmlog ("GET %s - Tape is offline " % PnfsID)
      elif (outputerror == OSM_BCONNECT) or (outputerror==OSM_EINLABEL):
        osmlog ("GET %s - broken connection " % PnfsID)
      outputerror,output=commands.getstatusoutput("rm %s" % PnfsPathFile)
      llevel = llevel + 1
#   keines der kopien lesbar
    if (llevel >= level ):
      osmlog ("GET %s - %s unsuccesfully ended error 45" % (PnfsID,osmbitfile))
      sys.exit(45)
  else:
    osmlog ("GET %s - touch empty file " % PnfsID)
    outputerror,output=commands.getstatusoutput("touch %s" % PnfsPathFile)


def PutDataToHsm():
  osmstore=""
  osmstored=""
  osmgroup=""
  osmgroupd=""
  osmbitfile=""
  osmbitfiled=""
  global dupli
  if (loglevel!=0):
    osmlog ("PUT %s - startet - %s" % (PnfsID,VERSION_STRING))
  if (GetStorageInformation("hsm") =="osm") :
    osmtype=GetStorageInformation("hsm")
    osmstore=GetStorageInformation("store")
    osmgroup=GetStorageInformation("group")
    osmsize=GetStorageInformation("size")
    crc=GetStorageInformation("flag-c")
    if (loglevel==2):
      osmlog ("PUT %s - si = %s " % (PnfsID,siopt))
      osmlog ("PUT %s - %s %s %s %s" % (PnfsID,osmtype,osmstore,osmgroup,osmsize))
    if (osmgroup.count('/') == 1):
      dupli="tag"
    if (dupli not in ["tag","store","group"]):
      dupli="none"
    out2=0
    if (osmsize=="0"):
      osmbitfile="*" 
      outputerror=0
      output="dummy null byte file"
    else: 
      if (dupli == "none"):
        if (loglevel==2):
          osmlog("PUT %s - no duplicate" % PnfsID)
      else:
        osmstored=osmstore
        osmgroupd=osmgroup
        if (dupli == "store"):
          osmstored+="-d"
        if (dupli == "group"):
          osmgroupd+="-d"
        if (dupli == "tag"):
          osmgroup,duposm=osmgroup.split('/')
          osmstored,osmgroupd=duposm.split(':')
        if (loglevel==2):
          osmlog("PUT %s - %s duplicate %s %s" % (PnfsID,dupli,osmstored,osmgroupd))
        # kopie wird geschrieben
        if (loglevel!=0):
           osmlog(("PUT %s - start write of %s to store: %s group: %s  %s" % (PnfsID,PnfsID,osmstored,osmgroupd,osmsize)))
        outputerror,output=commands.getstatusoutput("osmcp -v -C %s -S %s -t %s -G %s -P %s %s" % (crc,osmstored,OSM_TIMEOUT,osmgroupd,PnfsID,PnfsPathFile))
        out2=os.WEXITSTATUS(outputerror)
        if (outputerror>256):
          outputerror/=256
        if (output.count('data transfer completed') == 1):
          for i in output.split():
            if ((i.count('.') == 2) & (len(i) == 34)):
              osmbitfiled=i
        else:
          output="bitfile is wrong"
      if (loglevel!=0):
        osmlog(("PUT %s - start write of %s to store: %s group: %s  %s" % (PnfsID,PnfsID,osmstore,osmgroup,osmsize)))
      outputerror,output=commands.getstatusoutput("osmcp -v -C %s -S %s -t %s -G %s -P %s %s" % (crc,osmstore,OSM_TIMEOUT,osmgroup,PnfsID,PnfsPathFile))
      out2=os.WEXITSTATUS(outputerror)
      if (outputerror>256):
        outputerror/=256
      if (output.count('data transfer completed') == 1):
        for i in output.split():
          if ((i.count('.') == 2) & (len(i) == 34)):
            osmbitfile=i
      else:
        output="bitfile is wrong"
    if (loglevel==2):
      osmlog("PUT %s - osmcp -v -C %s -S %s -t %s -G %s -P %s %s %s" % (PnfsID,crc,osmstore,OSM_TIMEOUT,osmgroup,PnfsID,PnfsPathFile,outputerror))
      osmlog("PUT %s - %s %s OS: %s" % (PnfsID,outputerror,output,out2))
    if (outputerror != 0):
      if (loglevel==2):
        osmlog("PUT %s - finished with error %s" % (PnfsID,outputerror))
      if (outputerror == OSM_ETOBIG):
        osmlog("PUT %s - File to big " % PnfsID)
        sys.exit(41)
      elif (outputerror == OSM_ENOSPACE):
        osmlog("PUT %s - No space in storage level - retry " % PnfsID)
        sys.exit(74)
      elif (outputerror == OSM_ENOSERVER):
        osmlog("PUT %s - Osm part not running - retry " % PnfsID)
        sys.exit(166)
      elif (outputerror == OSM_EINLABEL):
        osmlog("PUT %s - Osm tapelabel kaputt - retry " % PnfsID)
        sys.exit(173)
      elif (outputerror == OSM_EUNKNOWN):
        osmlog("PUT %s - bitfile is wrong" % PnfsID)
        sys.exit(30)
      else:
        osmlog("PUT %s - unspecified error - deactivate %s" % (PnfsID,outputerror))
        sys.exit(30)
    else:
      osmtape='XXXXX'
      tapepos='X:X'
      if (loglevel==2):
        osmlog("PUT %s - error %s" % (PnfsID,outputerror))
      dcfile=GetStorageInformation("path")
      dcowner=GetStorageInformation("uid")
      dcmode=GetStorageInformation("mode") 
      osmlen=GetStorageInformation("size")
      #syslog.openlog ('DESY-PNFS',0,syslog.LOG_LOCAL5);
      #syslog.syslog ("DESY-PNFS ID %s /%s %s %s %s %s %s %s" % (PnfsID,dcfile,dcowner,dcmode,osmstore,osmgroup,osmbitfile,osmlen));
      #syslog.closelog() 
      if (loglevel!=0):
        osmlog ("PUT %s - ended" % PnfsID)
      if (dupli == "none"):
        print ("%s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s" % (osmtype,osmtype,osmstore,osmgroup,osmbitfile,osmtape,tapepos))
        osmlog ("PUT %s - %s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s"%(PnfsID,osmtype,osmtype,osmstore,osmgroup,osmbitfile,osmtape,tapepos))
      else:
        print ("%s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s\n %s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s"
                % (osmtype,osmtype,osmstore,osmgroup,osmbitfile,osmtape,tapepos,osmtype,osmtype,osmstored,osmgroupd,osmbitfiled,osmtape,tapepos))
        osmlog ("PUT %s - duplikat - %s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s %s://%s/?store=%s&group=%s&bfid=%s&vol=%s&pos=%s"%(PnfsID,osmtype,osmtype,osmstore,osmgroup,osmbitfile,osmtape,tapepos,osmtype,osmtype,osmstored,osmgroupd,osmbitfile,osmtape,tapepos))
        osmlog ("PUT %s - original and duplikat ended" % PnfsID)
      sys.exit(0)
 
# main part of the script 

if len(sys.argv) < 3:
   usage()
   sys.exit()

PnfsID=sys.argv[2]
PnfsPathFile=sys.argv[3]
crc="false"
uri=["","","","","","","","",""]
level=0
if (loglevel == 2):
  osmlog(sys.argv)
for opt in sys.argv:
  if (opt[:4] == "-si="):
    si=opt[4:]
    siopt=string.split(si,';')
  if (opt[:5] == "-uri="):
    uri[level]=opt[5:]
    level=level+1
  if (opt[:5] == "-crc="):
    crc=opt[5:]
  if (opt[:7] == "-dupli="):
    dupli=opt[7:]
if (string.upper(sys.argv[1])=="GET"):
  # kein uri  parameter parsen aus SI
  if (level == 0):
    osmlog ("GET - no URI parse SI %s" % siopt)
    for subsi in siopt:
      if (subsi.count(':') >= 1):
        if (subsi[:3] == "osm"):
          uri[level]=subsi
          level=level+1
  GetDataFromHsm()
else:
  if (string.upper(sys.argv[1])=="PUT"):
    PutDataToHsm()
  else:
    usage()
    osmlog ("Error in parameters")
    log.close()
    sys.exit(1)
