import pytest
import os
import cv2
import shutil
import sys
import random
import filecmp
import inspect


SelfName          = os.path.basename(__file__)
TestFile          = SelfName.split(".")[0]
ProgramDirectory  = os.path.dirname(os.path.realpath(__file__))
TestDirectory     = os.path.join(ProgramDirectory,"Tests")
#sys.path.append('../..')

from TestTools import TestTools
TT = TestTools(TestDirectory,TestFile)
#SourcePath        = TT.MakePath(os.path.join(ProgramDirectory,SelfBase,"Source")+"/")
#ResultPath        = TT.MakePath(os.path.join(ProgramDirectory,SelfBase,"Result"))




"""
def test_test():
	try:
		print()
	except:
		raise NameError("?")

def test__init__():
	try:
		B = TempFolder()
		IsTempFolderEmpty(B)

	except Exception as Exc:
		raise NameError(str(Exc))
"""
