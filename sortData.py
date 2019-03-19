from shutil import copyfile
import os

def createFolder():
    path = "/tmp/year"
    try:  
        os.mkdir(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
    else:  
        print ("Successfully created the directory %s " % path)

# Create Folders for storing new data!

# Folder 1 - 7
# Ax.jpg
for x in range(6):
    folderUrl = "LegacyDatabase/"+ str(x+1)





#copyfile(src, dst)