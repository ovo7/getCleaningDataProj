#download file and place it in DC_Project folder
if(!file.exists("DC_Project")){
        dir.create("DC_Project")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl, destfile = "./DC_Project/proj.zip", method = "curl")
datedownloaded <- date()

## > datedownloaded
## [1] "Sat Apr  9 16:21:12 2016"

##Unzip file
unzip ("proj.zip", exdir = "./DC_Project")

#files in "UCI HAR Dataset". retriving files
path.rf <- file.path("./DC_Project", "UCI HAR Dataset")

files <- list.files(path.rf, recursive = TRUE)

#Only using these files
#[14]"test/subject_test.txt" 
#[15]"test/X_test.txt"  
#[16]test/y_test.txt" 
#[26]"train/subject_train.txt"  
#[27]train/X_train.txt" 
#[28]train/y_train.txt"

##reading data from the files into variables
#activities
dataATest <- read.table(file.path(path.rf, "test", "y_test.txt"), header = FALSE)
dataATrain <- read.table(file.path(path.rf, "train", "y_train.txt"), header = FALSE)

#subjects
dataSTest <- read.table(file.path(path.rf, "test", "subject_test.txt"), header = FALSE)
dataSTrain <- read.table(file.path(path.rf, "train", "subject_train.txt"), header = FALSE)

#features
dataFTest <- read.table(file.path(path.rf, "test", "X_test.txt"), header = FALSE)
dataFTrain <- read.table(file.path(path.rf, "train", "X_train.txt"), header = FALSE)

#view properties
str(dataATest)
str(dataATrain)

str(dataSTrain)
str(dataSTest)

str(dataFTest)
str(dataFTrain)

##1.merging the training and the test sets to create one data set.
#row binding data tables
dataAct <- rbind(dataATrain, dataATest)
dataSubj <- rbind(dataSTrain, dataSTest)
dataFeat <- rbind(dataFTrain, dataFTest)

#setting names to variables
names(dataSubj) <- c("subject")
names(dataAct) <- c("activity")

dataFeatNames <- read.table(file.path(path.rf, "features.txt"), head = FALSE)
##veiw properties of dataFeatNames
#str(dataFeatNames)
names(dataFeat) <- dataFeatNames$V2

##merging columns to form data set
datacombined <- cbind(dataSubj, dataAct)
ccdata <- cbind(dataFeat, datacombined)

##2. Extracts only the measurements on the mean and standard deviation for each measurement
#subsetting names of features by measurements on the mean and sd
#With mean() or std()
subdataFeatNames <- dataFeatNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeatNames$V2)]

#subsetting ccdata frame by selected names of features

selNames <- c(as.character(subdataFeatNames), "subject", "activity")
ccdata <-subset(ccdata, select = selNames)
##view properties
#str(ccdata)

##3.Uses descriptive activity names to name the activities in the data set
#read activity names from activiy_labels.txt
actLabels <- read.table(file.path(path.rf, "activity_labels.txt"), header = FALSE)

ccdata$activity <- factor(ccdata$activity) ;
ccdata$activity <- factor(ccdata$activity, labels = as.character(actLabels$V2))

#check
head(ccdata$activity,30)

##4. Appropriately labels the data set with descriptive variable names.

#originals were labelled using descriptive naames. 
#names of features will be now labelled using descriptive variable names

#prefix t replaced by time
names(ccdata) <- gsub("^t", "time", names(ccdata))
#prefix f is replaced by frequency
names(ccdata) <- gsub("^f", "frequency", names(ccdata))
#Gyro is replaced by Gyroscope
names(ccdata) <- gsub("Gyro", "Gyroscope", names(ccdata))
#Acc is replaced by Accelerometer
names(ccdata) <- gsub("Acc", "Accelerometer", names(ccdata))
#Mag is replaced by Magnitude
names(ccdata) <- gsub("Mag", "Magnitude", names(ccdata))
#Bodybody is replaced by Body
names(ccdata) <- gsub("BodyBody", "Body", names(ccdata))
#check
#names(ccdata)

##5.From the data set in step 4, creates a second, independent tidy 
##data set with the average of each variable for each activity and each subject.

#library(plyr)
ccdata2 <- aggregate(. ~subject + activity, ccdata, mean)
ccdata2 <- ccdata[order(ccdata2$subject, ccdata2$activity),]
write.table(ccdata2, file = "tidydata.txt", row.names = FALSE)
