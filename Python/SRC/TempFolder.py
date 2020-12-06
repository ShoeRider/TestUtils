import os
import uuid
import shutil

import platform
import sys

def linux_distribution():
  try:
    return platform.linux_distribution()
  except:
    return "N/A"

print("""Python version: %s
dist: %s
linux_distribution: %s
system: %s
machine: %s
platform: %s
uname: %s
version: %s
mac_ver: %s
""" % (
    sys.version.split('\n'),
    str(platform.dist()),
    linux_distribution(),
    platform.system(),
    platform.machine(),
    platform.platform(),
    platform.uname(),
    platform.version(),
    platform.mac_ver(),
))
#UseRamDisk
# False: creates FlatFolder for temp Files
""" Simple utility to create a temporary folder for projects. """
class TempFolder():
    def __init__(self,Directory="",UseRamDisk=False,RamDiskSize="2G",*args, **kwargs):
        self.Directory    = Directory
        self.UseRamDisk   = UseRamDisk
        self.RamDiskSize  = RamDiskSize
        self.GetSetDir()

        #
    def MountWindowsRAMDISK(self):
        raise NameError("TO Be implemented")
    def UnMountWindowsRAMDISK(self):
        raise NameError("TO Be implemented")

    def MountLinuxRAMDISK(self):
        os.system("sudo mkdir /mnt/ramdisk")
        os.system("sudo mount -t tmpfs -o rw,size=2G tmpfs /mnt/ramdisk")
        os.system("df -h")
    def UnMountLinuxRAMDISK(self):
        os.system("sudo umount /mnt/ramdisk")

    def SetGetRAMDISK(self):
        if platform.system() == "Windows":
            raise NameError("TO Be implemented")
        elif platform.system() == "Linux":
            self.MountLinuxRAMDISK()

        return 0



    def SetGetFlatFolder(self):
        #Directory
        self.DirectoryPath = os.path.join(os.path.dirname(os.path.abspath(__file__)),self.Directory)
        #raise NameError(str(self.DirectoryPath))
        #os.path.join(Directory,"/Temp/",str(uuid.uuid4())+"/")
        #self.TempFolder     = os.path.join(str(self.DirectoryPath),"/Temp/"+str(uuid.uuid4())+"/")
        self.TempFolder     = self.DirectoryPath+"/Temp/"+str(uuid.uuid4())+"/"

        #raise NameError(str(self.DirectoryPath)+":"+str(self.TempFolder))

        if not(os.path.exists(self.DirectoryPath)):
            os.mkdir(self.DirectoryPath)

        if not(os.path.exists(self.DirectoryPath+ "/Temp/")):
            os.mkdir(os.path.dirname(self.DirectoryPath+ "/Temp/"))
        if not(os.path.exists(self.TempFolder)):
            os.mkdir(self.TempFolder)
        return self.TempFolder

    def GetSetDir(self):
        try:
            self.TempFolder
        except:
            if self.UseRamDisk:
                self.MakeRAMDISKDIR()
            else:
                self.MakeDir()

        return self.TempFolder

    def GetTempFolder(self):
        return self.TempFolder

    """__del__ runs when class is deleted """
    def __del__(self):
        if(os.path.exists(self.TempFolder)):
            shutil.rmtree(self.TempFolder)
            os.remove(self.TempFolder)
        #print("__"+self.TempFolder)

    def EmptyTempFolder(self):
        shutil.rmtree(self.TempFolder)
        os.mkdir(self.TempFolder)

        return 0
