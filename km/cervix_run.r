# Load necessary libraries
library(dplyr)
library(readxl)
library(reticulate)
source("C:/km_curve.r")
source("C:/txt_to_xlsx.r")

# Define the path to your directory containing the files
# This is manually created by the user based on the Clinical Data downloaded
file_path <- "C:/prepared_excel_km_data_cervix/"

# Get the list of file names in the directory (including only the relevant files)
files <- list.files(file_path, full.names = TRUE)

for (file in files) {
    file_name <- basename(file) # Get the filename from the full path
    name_parts <- strsplit(file_name, "_")[[1]]

    # Extract parts
    tag <- name_parts[2]
    curve_type <- name_parts[3]
    dataset_type <- sub("\\.csv$", "", name_parts[4]) # Remove the ".xlsx" extension

    curve_data <- read.csv(file)
    curve_output_file <- paste0("C:/km_curves/", tag, "_", curve_type, "_", dataset_type, ".png")


    title <- paste(tag, curve_type, toupper(dataset_type))

    # Call the generate_km_curve function to generate and save the Kaplan-Meier curve
    generate_km_curve(curve_data, curve_output_file, title)
}
