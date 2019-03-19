# Split Database into a Testing and Training Dataset

from shutil import copyfile
import os

# Array of ML Classes
classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y']

# Create a folder in the Training and Testing Data Folder
def createTestFolder(x):
    path = "./Testing/"+str(x)
    try:  
        os.mkdir(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
    else:  
        print ("Successfully created the directory %s " % path)

def createTrainFolder(x):
    path = "./Training/"+str(x)
    try:  
        os.mkdir(path)
    except OSError:  
        print ("Creation of the directory %s failed" % path)
    else:  
        print ("Successfully created the directory %s " % path)

# Create Folders for storing new data!
for char in classes:
    createTestFolder(char)
    createTrainFolder(char)

print("--------- Begin Sorting ---------")

# Folder 1 - 7
# Ax.jpg

for classifier in classes:
    folderUrl = "./Database/"+ classifier
    files = os.listdir(folderUrl)
    # 70 images per dataset
    # 56 images for train
    # 14 images each for validation

    count = 0
    for file in files:
        if file != ".DS_Store":
                count += 1
                # Get the first character
                firstChar = file[1]

                # Move image to the correct place
                src = folderUrl + "/"+ file
                if count <= 56:
                    dst = "./Training/" + firstChar + "/"+ file
                else:
                    dst = "./Testing/" + firstChar + "/"+ file
                copyfile(src, dst)

print("\nDone")






#copyfile(src, dst)