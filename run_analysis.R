# You should create one R script called run_analysis.R that does the following.

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation 
#    for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

setwd('c://Users/Kevin/Dropbox/Coursera/Getting and Cleaning Data/Project/')

zipUrl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
zipFile = 'UCI HAR Dataset.zip'
if (!file.exists(zipFile)){
    download.file(zipUrl, zipFile, method = 'curl')
}
filePath = 'UCI HAR Dataset'
if (!file.exists(filePath)){
    unzip(zipFile)
}
files = list.files(filePath, recursive = TRUE)
files

#####
# the files will be worked on
#
# "activity_labels.txt"  
# "features.txt" 
# "test/subject_test.txt"   
# "test/X_test.txt"                             
# "test/y_test.txt"    
# "train/subject_train.txt"                     
# "train/X_train.txt"                           
# "train/y_train.txt" 
#
#####

#####
# load subject data
subject_train = read.table(file.path(filePath, 'train', 'subject_train.txt'))
subject_test = read.table(file.path(filePath, 'test', 'subject_test.txt'))

# load activity data
activity_train = read.table(file.path(filePath, 'train', 'y_train.txt'))
activity_test = read.table(file.path(filePath, 'test', 'y_test.txt'))

# load feature data

feature_train = read.table(file.path(filePath, 'train', 'x_train.txt'))
feature_test = read.table(file.path(filePath, 'test', 'x_test.txt'))

#####
# combine each category
subject = rbind(subject_train, subject_test)
activity = rbind(activity_train, activity_test)
feature = rbind(feature_train, feature_test)

#####
# labels data set
feature_names = read.table(file.path(filePath, 'features.txt'))
activity_label = read.table(file.path(filePath, 'activity_labels.txt'))

names(feature) = feature_names[,2]
names(subject) = 'subjectID'
names(activity) = 'activityID'
names(activity_label) = c('subjectID', 'activityID')
activity$activityID = factor(activity$activityID, activity_label$subjectID, 
                             activity_label$activityID)

#####
# combine data set
df = cbind(feature, subject, activity)

##### 
# subset the data
selectCol = grepl('mean\\(\\)|std\\(\\)|subjectID|activity', colnames(df))
df = df[,selectCol]

#####
# rename column to be readable
names(df) = gsub('^t', 'time', names(df))
names(df) = gsub('^f', 'frequency', names(df))
names(df) = gsub('Acc', 'Accelerometer', names(df))
names(df) = gsub('Gyro', 'Gyroscope', names(df))
names(df) = gsub('Mag', 'Magnitude', names(df))
names(df) = gsub('BodyBody', 'Body', names(df))

##### 
# create a second, independent tidy data set
library(plyr)
df2 = aggregate(.~ subjectID + activityID, df, mean)
df2 = df2[order(df2$subjectID, df2$activityID),]
write.table(df2, file = 'tidydata.txt', row.name = FALSE)

