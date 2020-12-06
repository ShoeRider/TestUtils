"""
python3 -m pytest TestTools_test.py
"""
import os
import pytest
import sys
import errno
import os
import re

def ClearTempFolder(TempFolder):
    TempUniqueImageManager = TempFolder()
    dir_path = os.path.dirname(os.path.realpath(inspect.getfile(TempUniqueImageManager.__class__)))+"/Temp"
    TempUniqueImageManager.__del__()
    shutil.rmtree(dir_path)
    os.mkdir(dir_path)

def IsTempFolderEmpty(Class):
    dir_path     = os.path.dirname(os.path.realpath(inspect.getfile(Class.__class__)))+"/Temp"
    Class.__del__()
    FileList    = [file for file in os.listdir(dir_path)]
    Files       = len(FileList)
    if Files!=0:
        #print(FileList)
        raise NameError("Test Directory not cleared! Contains:"+str(Files)+" File(s)")


""" Simple utility to help create Tests for projects. """
class TestTools():
    def __init__(self,TestDirectory,TestFile):
        Path = os.path.join(TestDirectory,TestFile)
        self.SourcePath          = self.MakePath(os.path.join(Path,"Source"))
        self.ResultPath          = self.MakePath(os.path.join(Path,"Result"))
        self.Instance_SourcePath = ""
        self.Instance_ResultPath = ""
        pass

    def DeclareTest(self,Name):
        self.Instance_SourcePath = self.MakePath(os.path.join(self.SourcePath,Name))
        self.Instance_ResultPath = self.MakePath(os.path.join(self.ResultPath,Name))
        return self.CleanFolder(self.Instance_ResultPath)


    def IsDir(self,Path):
        return os.path.exists(Path)

    def WriteTempFile(self,Path):
        f = open(Path, "w")
        f.write("Some Text")
        f.close()

    def Exists(self,Path):
        return os.path.exists(Path)

    def RemoveFile(self,Path):
        return os.remove(Path)

    def RemoveFolder(self,Path):
        for root, dirs, files in os.walk(Path):
            for file in files:
                os.remove(os.path.join(root, file))
    def Remove(self,Path):
        if self.Exists(Path):
            if (os.path.isfile(path)):
                self.RemoveFile(path)
            elif os.path.isdir(path):
                self.RemoveFile(path)
        else:
            raise NameError("Path does not exist")

    def CleanFolder(self,Path):
        for root, dirs, files in os.walk(Path):
            for file in files:
                os.remove(os.path.join(root, file))

    def MakePath(self,Path):
        ConstructedPath = "/"
        for PartialPath in Path.split("/"):
            ConstructedPath = os.path.join(ConstructedPath,PartialPath+"/")
            #print(f"ConstructedPath:{ConstructedPath} Path:{PartialPath}")
            if(not os.path.isdir(ConstructedPath)):
                try:
                    os.mkdir(ConstructedPath)
                except OSError as exc:
                    if exc.errno != errno.EEXIST:
                        raise
                    pass
        return ConstructedPath

    #os.path.dirname(os.path.realpath(__file__))
    def RefreshFolder(self,Path):
        if (os.path.isdir(Path)):
            #ClearDestinationFolder(ResultDir)
            os.system(f"rm -r {Path}")
            #if (os.path.isdir(Path)):
            #    raise NameError(f"Failed to Delete Folder:{Path}")
        os.mkdir(Path)
        if not(os.path.isdir(Path)):
            raise NameError(f"Failed to Create Folder:{Path}")

    def GetFileName(self,Path):
        #os.path.basename
        return os.path.basename(Path)

    def GetFilesInDir(self,Path):
        return [f for f in os.listdir(Path) if os.path.isfile(os.path.join(Path, f))]

    def Copy(self,Source,Destination):
        #Source

        for root, dirs, files in os.walk(ResultPath):
            for file in files:
                os.remove(os.path.join(root, file))

    def DeterminePython(self):
        try:
            Command = "python " + ProgramDirectory + "ImageManager.py"
            ErrorCode = os.system(Command)
            if(ErrorCode):
                Command = ""
        except Exception as Exc:
            raise NameError(str(Exc) + 'Something unexpected happened.')
