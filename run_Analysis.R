
#install.packages("reshape2")
#install.packages("downloader")
#install.packages("RCurl")

#install.packages("memisc")


library(memisc)
library(reshape2)
library(RCurl)

filename <- "getdata_dataset.zip"

# Download the dataset
if (!file.exists(filename)){
  URL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(URL, filename, method="auto")
}  
# Unzip the dataset
unzip(filename) 


# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

featuresData <- read.table("UCI HAR Dataset/features.txt")
featuresData[,2] <- as.character(featuresData[,2])

# Extract only the data on mean and standard deviation
selectedFeatures <- grep(".*mean.*|.*std.*", features[,2])
selectedFeatures.names <- features[selectedFeatures,2]

# Replace the '-mean' with 'Mean', '-std' with 'Std' and '[-()]' with ''
selectedFeatures.names = gsub('-mean', 'Mean', selectedFeatures.names)
selectedFeatures.names = gsub('-std', 'Std', selectedFeatures.names)
selectedFeatures.names <- gsub('[-()]', '', selectedFeatures.names)


# Load the datasets
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[selectedFeatures]
trainActivitiesData <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjectsData <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubjectsData, trainActivitiesData, trainData)


testData <- read.table("UCI HAR Dataset/test/X_test.txt")[selectedFeatures]
testActivitiesData <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjectsData <- read.table("UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjectsData, testActivitiesData, testData)

# merge datasets and add labels
mergedData <- rbind(trainData, testData)
colnames(mergedData) <- c("subject", "activity", featuresWanted.names)


# turn activities & subjects into factors
mergedData$activity <- factor(mergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

write.table(mergedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


Write(codebook(mergedData),
      file="mergedData_codebook.md")


