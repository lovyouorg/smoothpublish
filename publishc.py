#!usr/bin/env python
import os
import sys
if(len(sys.argv)<2):
	print("please input a arguments")
	sys.exit(1)
arg0=sys.argv[1] # argv[0] is .py file
arg1=sys.argv[2]
arg2=sys.argv[3]

os.system('/opt/publish/publishc.sh '+arg0+' '+arg1+' '+arg2)
