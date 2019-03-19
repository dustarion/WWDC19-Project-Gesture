# Convert LegacyDatabase to a useable database for coreML!

from shutil import copyfile
import os

# Array of ML Classes
classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

# Create a folder in the Training Data Folder
def createFolder(x):
    path = "/Database/"+x
    try:  
        os.mkdir(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
    else:  
        print ("Successfully created the directory %s " % path)

# Create Folders for storing new data!
for char in classes:
    createFolder(char)

# Folder 1 - 7
# Ax.jpg
# for x in range(6):
#     folderUrl = "LegacyDatabase/"+ str(x+1)





#copyfile(src, dst)