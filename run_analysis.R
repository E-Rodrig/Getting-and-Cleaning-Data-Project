# Load required libraries
library(dplyr)

# Step 1: Download and unzip the dataset
if(!file.exists("./courseraproject")) {
    dir.create("./courseraproject")
}
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./courseraproject/initialdataset.zip")
unzip(zipfile = "./courseraproject/initialdataset.zip", exdir = "./courseraproject")

# Step 2: Load the data
# Load the feature names (columns for the data)
features <- read.table("./courseraproject/UCI HAR Dataset/features.txt", col.names = c("index", "feature"))

# Load the activity labels
activity_labels <- read.table("./courseraproject/UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity"))

# Load the training and test datasets
# Training data
x_train <- read.table("./courseraproject/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./courseraproject/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./courseraproject/UCI HAR Dataset/train/subject_train.txt")

# Test data
x_test <- read.table("./courseraproject/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./courseraproject/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./courseraproject/UCI HAR Dataset/test/subject_test.txt")

# Step 3: Merge the training and test datasets
# Merge X (measurements), Y (activities), and subject data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Step 4: Extract only the measurements on the mean and standard deviation for each measurement
# Get column names of the data (features)
colnames(x_data) <- features$feature

# Extract columns that contain "mean" or "std" in their name
selected_columns <- grep("mean\\(\\)|std\\(\\)", features$feature)
x_data <- x_data[, selected_columns]

# Step 5: Use descriptive activity names to name the activities in the data set
y_data$activity <- activity_labels$activity[y_data$V1]

# Step 6: Appropriately label the data set with descriptive variable names
colnames(x_data) <- gsub("^t", "time", colnames(x_data))  # Replace 't' with 'time' for time-based measurements
colnames(x_data) <- gsub("^f", "frequency", colnames(x_data))  # Replace 'f' with 'frequency' for frequency-based measurements
colnames(x_data) <- gsub("Acc", "Accelerometer", colnames(x_data))  # Replace 'Acc' with 'Accelerometer'
colnames(x_data) <- gsub("Gyro", "Gyroscope", colnames(x_data))  # Replace 'Gyro' with 'Gyroscope'
colnames(x_data) <- gsub("Mag", "Magnitude", colnames(x_data))  # Replace 'Mag' with 'Magnitude'
colnames(x_data) <- gsub("BodyBody", "Body", colnames(x_data))  # Replace 'BodyBody' with 'Body'

# Combine the data into one data frame
full_data <- cbind(subject_data, y_data$activity, x_data)

# Step 7: Create a second, independent tidy data set with the average of each variable for each activity and each subject
# Assign column names to the combined dataset
colnames(full_data)[1:2] <- c("subject", "activity")

# Create tidy dataset using dplyr to group by subject and activity, then calculate mean
tidy_data <- full_data %>%
    group_by(subject, activity) %>%
    summarise_all(list(mean = ~mean(.)))

# Step 8: Write the tidy data to a file
write.table(tidy_data, "./getcleandata/tidy_data.txt", row.names = FALSE)
