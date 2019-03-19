# Convert LegacyDatabase to a useable database for coreML!

from shutil import copyfile
import os

# Array of ML Classes
classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

# Create a folder in the Training Data Folder
def createFolder(x):
    path = "./Database/"+str(x)
    try:  
        os.mkdir(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
    else:  
        print ("Successfully created the directory %s " % path)

# Create Folders for storing new data!
for char in classes:
    createFolder(char)

print("--------- Begin Sorting ---------")

# Folder 1 - 7
# Ax.jpg
for x in range(7):
    folderUrl = "./LegacyDatabase/"+ str(x+1)
    print (folderUrl)
    for file in os.listdir(folderUrl):
        if file != ".DS_Store":
                # Get the first character
                firstChar = file[0]

                # Move image to the correct place
                src = folderUrl + "/"+ file
                dst = "./Database/" + firstChar + "/"+ str(x) + file
                copyfile(src, dst)

print("\nDone")






#copyfile(src, dst)