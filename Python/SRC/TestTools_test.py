"""
Import Line:
sys.path.append('../..')
from TestTools import TestTools


Test:
python3 -m pytest TestTools_test.py
"""

import pytest
import os
import cv2
import shutil
import sys




SelfName          = os.path.basename(__file__)
TestFile          = SelfName.split(".")[0]
ProgramDirectory  = os.path.dirname(os.path.realpath(__file__)) #+ "/Data/TestResults/"
TestDirectory     = os.path.join(ProgramDirectory,"Tests")

#sys.path.append('../..')
from TestTools import TestTools
TT = TestTools(TestDirectory,TestFile)



def test__init__():
    try:
        TT = TestTools(TestDirectory,TestFile)
    except Exception as Exc:
        raise NameError(str(Exc))

def test_NewTest():
    try:
        Test = TT.DeclareTest("NewTest")
        assert (TT.Exists(ProgramDirectory)),                    f"TestTools.Exists Returned False Expected True \n {ProgramDirectory} Should Exists"

    except Exception as Exc:
        raise NameError(str(Exc))


"""
def test_Exists():
    try:
        Test = TT.NewTest()
        assert (TT.Exists(ProgramDirectory)),                    f"TestTools.Exists Returned False Expected True \n {ProgramDirectory} Should Exists"
        FalsePath = ProgramDirectory+"/NonExistantDir/"
        assert not(TT.Exists(FalsePath)),    f"TestTools.Exists Returned True Expected  False\n {FalsePath} Should Not Exists"

        TempPath = ProgramDirectory+"/Testfile2.txt"
        TT.WriteTempFile(TempPath)
        assert  (TT.Exists(TempPath)),                            f"TestTools.Exists Returned False Expected True \n {TempPath} Should Exists"
        FalsePath = ProgramDirectory+"/FalseFile.txt"
        assert not(TT.Exists(FalsePath)),f"TestTools.Exists Returned True Expected  False\n {FalsePath} Should Not Exists"

    except Exception as Exc:
        raise NameError(str(Exc))

def test_CleanFolder():
    try:
        TempDestination = ResultPath + "CleanFolder/"
        TempTxtFile =  TempDestination + "Testfile.txt"
        TT.WriteTempFile(TempTxtFile)

        TT.CleanFolder(TempDestination)
        List = TT.GetFilesInDir(TempDestination)
        assert (len(List) == 0),                    f"CleanFolder: Failed\n Expected: 0 \n Recieved: {(len(List))}"

    except Exception as Exc:
        raise NameError(str(Exc))


def test_WriteTempFile():
    try:
        TT = TestTools()
        TempPath = ProgramDirectory+"/Testfile3.txt"
        TT.WriteTempFile(TempPath)
        if not(TT.Exists(TempPath)):
            raise NameError(f"TestTools.WriteTempFile: Failed\n Expected to create: {TempPath}")
    except Exception as Exc:
        raise NameError(str(Exc))

#TOIMPLEMENT
def test_FolderExists():
    try:
        Logfolder = os.path.join(ResultPath,"Results_01")
        if not(os.path.exists(Logfolder)):
            os.mkdir(Logfolder)


        os.mkdir(os.path.join(Logfolder,"Results_01"))
        if not(os.path.exists(CheckPath)):
            raise NameError("Failed to see Folder:"+CheckPath)

        #TT.RefreshFolder(CheckPath)
        #if not(os.path.exists(CheckPath)):
        #    raise NameError("Failed to see Folder:"+CheckPath)

    except Exception as Exc:
        raise NameError(str(Exc))
"""
