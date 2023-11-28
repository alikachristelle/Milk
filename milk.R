#loading of library
library(readr)
library(dplyr)
library(ggplot2)
library(caret)
library(glmnet)

# Load data from a CSV file
library(readr)
data <- read_csv("data/milknew.csv")
View(data)

#Issue 1: Descriptive analysis

# Frequency table of Grades
grade_frequency <- table(data$Grade)
print(grade_frequency)

# Mean
mean_temperature <- mean(data$Temprature)

# Median
median_temperature <- median(data$Temprature)

# Calculate the mode of temperature for each group
mode_temperature_by_group <- data %>%
  group_by(Grade) %>%
  summarize(mode_temperature = mode(Temprature))

# Display the results
print(paste("Mean Temperature:", mean_temperature))
print(paste("Median Temperature:", median_temperature))
print(paste("Mode Temperature:", mode_temperature_by_group))

# Measures of Distribution:
pH_range <- range(data$pH)

# Variance
pH_variance <- var(data$pH)

# Display the results
print(paste("pH Range:", paste(pH_range, collapse = " - ")))
print(paste("Variance of pH:", pH_variance))

# Measures of Relationship:
# Correlation coefficient
correlation_coefficient <- cor(data$pH, data$Temprature)

# Display the correlation coefficient
print(paste("Correlation Coefficient between pH and Temperature:", correlation_coefficient))

#Issue 2: Inferential statistics
# Perform ANOVA on Grade based on pH
#anova_result <- aov(Grade ~ pH, data = data)

# Summary of ANOVA results
#summary(anova_result)

#Issue 3

# Scatter plot of pH vs. Temperature with color by Grade
ggplot(data, aes(x = pH, y = Temprature, color = Grade)) +
  geom_point() +
  labs(title = "Scatter Plot of pH vs. Temperature", x = "pH", y = "Temperature")

# Boxplot of pH by Grade
ggplot(data, aes(x = Grade, y = pH, fill = Grade)) +
  geom_boxplot() +
  labs(title = "Boxplot of pH by Grade", x = "Grade", y = "pH")

# Check for missing values in the dataset
missing_values <- any(is.na(data))
print(missing_values)

# Standardize 'Temprature' column
data$temprature_standardized <- scale(data$Temprature)

#Issue 5

#Data Splitting

# Splitting data into training (70%) and testing (30%) sets
set.seed(123)
trainIndex <- createDataPartition(data$Grade, p = 0.7, list = FALSE)
training_set <- data[trainIndex, ]
testing_set <- data[-trainIndex, ]

#Cross validation
# Define the training control
train_control <- trainControl(method = "cv", number = 10)

sum(is.na(training_set$Grade))

training_set$Grade <- as.factor(training_set$Grade)

#Model training Random Forest
# Train a Random Forest model
library(randomForest)
rf_model <- train(Grade ~ ., data = training_set, method = "rf", trControl = train_control)

# Make predictions on the testing set
predictions <- predict(rf_model, newdata = testing_set)

# Train an SVM model
library(e1071)
svm_model <- train(Grade ~ ., data = training_set, method = "svmRadial", trControl = train_control)

#Model sampling and comparison
# Define the control parameters for resampling
train_control <- trainControl(method = "cv", number = 10)  # 10-fold cross-validation

# List of trained models
models_list <- list(
  Random_Forest = rf_model,
  SVM = svm_model
)

# Compare model performance using resampling techniques
results <- resamples(models_list, control = train_control)

# Summarize and compare model performance metrics (e.g., accuracy, sensitivity, specificity)
summary(results)

#Issue 7: Bagging search
# Using bagging for Random Forest
library(caret)

bagged_rf <- train(
  Grade ~ .,
  data = training_set,
  method = "rf",
  trControl = trainControl(method = "boot", number = 10),  # Using bootstrapping for bagging
  #bagControl = bagControl(method = "boot", number = 10)  # Number of bags
)

# Save the trained model in RDS format
saveRDS(rf_model, file = "trained_rf_model.rds")
