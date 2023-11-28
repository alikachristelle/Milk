# Load required packages
if (require("plumber")) {
  require("plumber")
} else {
  install.packages("plumber", dependencies = TRUE,
                   repos = "https://cloud.r-project.org")
}
# Load required packages
library(randomForest)
library(plumber)

# Load your saved Random Forest model
loaded_random_forest_model <- readRDS("trained_rf_model.rds")

# Define the Plumber API endpoint for your model
# This assumes your Random Forest model is used for milk prediction

#* @apiTitle Milk Prediction Model API
#* @apiDescription Used to predict the milk grade based on features.

#* @param pH Value for Symptom 1
#* @param Temperature Value for Symptom 2
#* @param Taste Value for Symptom 3
#* @param Odor Value for Symptom 4
#* @param Fat Value for Symptom 5
#* @param Turbidity Value for Symptom 6
#* @param Colour Value for Symptom 7

#* @get /predict_milk

predict_milk <- function(pH, Temprature,Taste, Odor,
                            Fat, Turbidity, Colour) {
  # Create a data frame using the input features
  input_data <- data.frame(
    pH = as.numeric(pH),
    Temprature = as.numeric(Temprature),
    Taste = as.numeric(Taste),
    Odor = as.numeric(Odor),
    Fat = as.numeric(Fat),
    Turbidity = as.numeric(Turbidity),
    Colour = as.numeric(Colour)
  )
  
  # Make a prediction based on the input data using the loaded Random Forest model
  predictions <- predict(loaded_random_forest_model, input_data)
  return(predictions)
}
