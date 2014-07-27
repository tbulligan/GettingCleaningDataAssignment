# Define file name variables
data.file <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
local.data.file <- './original-dataset.zip'
local.data.dir <- './UCI HAR Dataset'
tidy.data.file <- './tidy-UCI-HAR-dataset.csv'
tidy.avgs.data.file <- './tidy-UCI-HAR-avgs-dataset.csv'

## Data collection

# Check if starting data exists, else download
if (!file.exists(local.data.file)) {
  download.file(data.file, local.data.file, method = "curl")
  print(paste(local.data.file, "downloaded"))
}

# Check data retrieval successful, else stop
if (!file.exists(local.data.file)) {
  stop(paste("Could not retrieve", local.data.file))
}
  
# Check if starting data is uncompressed, else uncompress
if (!file.exists(local.data.dir)) {
  unzip(local.data.file)
  print(paste(local.data.file, "uncompressed"))
}

# Check if uncompression successful, else stop
if (!file.exists(local.data.dir)) {
  stop(paste("Could not extract data from", local.data.file))
}

# Read activity labels
activity.labels <- read.table(paste(local.data.dir, "activity_labels.txt", sep = "/"), col.names = c("id", "activity"))

# Read feature labels
feature.labels <- read.table(paste(local.data.dir, "features.txt", sep = "/"), col.names = c("id", "feature"))

# Read training set
training.set <- read.table(paste(local.data.dir, "train", "X_train.txt", sep = "/"), col.names = feature.labels$feature)

# Read training labels
training.labels <- read.table(paste(local.data.dir, "train", "y_train.txt", sep = "/"), col.names = "activity")

# Read training subjects
training.subjects <- read.table(paste(local.data.dir, "train", "subject_train.txt", sep = "/"), col.names = "subject")

# Read test set
test.set <- read.table(paste(local.data.dir, "test", "X_test.txt", sep = "/"), col.names = feature.labels$feature)

# Read test labels
test.labels <- read.table(paste(local.data.dir, "test", "y_test.txt", sep = "/"), col.names = "activity")

# Read test subjects
test.subjects <- read.table(paste(local.data.dir, "test", "subject_test.txt", sep = "/"), col.names = "subject")

# Merge training and test sets
temp.set <- rbind(training.set, test.set)
temp.labels <- rbind(training.labels, test.labels)
subjects <- rbind(training.subjects, test.subjects)

# Purge everything but means and standard deviations from temp set
temp.set <- temp.set[, grep("-mean\\(\\)|-std\\(\\)", feature.labels$feature)]

# Convert temp activity labels from numbers to names
temp.labels$activity <- activity.labels[temp.labels$activity,]$activity

# Merge temp sets and temp labels
tidy.data.set <- cbind(subjects, temp.labels, temp.set)

# Dump data set containing merged training and test data
write.csv(tidy.data.set, tidy.data.file)

# Compute the averages grouped by subject and activity
tidy.avgs.data.set <- aggregate(tidy.data.set[, 3:dim(tidy.data.set)[2]],
                                list(tidy.data.set$subject,
                                     tidy.data.set$activity),
                                mean)
names(tidy.avgs.data.set)[1:2] <- c('subject', 'activity')

# Dump data set containing averages grouped by subject and activity
write.csv(tidy.avgs.data.set, tidy.avgs.data.file)