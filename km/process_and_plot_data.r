# Load necessary libraries
library(dplyr)
library(readxl)
library(reticulate)
source("C:/km_curve.r")
source("C:/txt_to_xlsx.r")

# NOTE: File paths need to be changed here and in txt_to_xlsx.r

# Take the .txt files and convert them into the proper .xlsx document
# Define the path to your directory containing the .txt files
txt_file_path <- "C:/raw_km_data_cesc/"

# Get the list of .txt files in the directory
txt_files <- list.files(txt_file_path, pattern = "\\.txt$", full.names = TRUE)

# Iterate over each file and call the process_file function
for (file in txt_files) {
    process_file(file)
}

print("Finished converting all documents from .txt to .xlsx")


# Define the path to your directory containing the files
file_path <- "C:/raw_excel_km_data_cesc/"

# Get the list of file names in the directory (including only the relevant files)
files <- list.files(file_path, full.names = TRUE)

# Iterate over each file
for (file in files) {
    # Extract tag and curve_type from the file name using regular expressions
    # Example: For "1.5_disease_free.xlsx", extract 1.5 as tag, disease_free as curve_type
    file_name <- basename(file) # Get the filename from the full path
    name_parts <- strsplit(file_name, "_")[[1]]

    # Extract tag (before _disease_free, _overall, etc.) and curve_type (disease_free, overall, etc.)
    tag <- name_parts[1]
    curve_type <- name_parts[2]
    dataset_type <- name_parts[3]
    gene_name <- sub("\\.xlsx$", "", name_parts[4]) # Remove the ".xlsx" extension

    # Read the bottom and top sheets for the file
    bottom_data <- read_excel(file, sheet = "bottom")
    top_data <- read_excel(file, sheet = "top")

    # Add a new 'Group' column to each dataset based on tag and curve_type
    bottom_data <- bottom_data %>% mutate(Group = paste0("bottom", tag))
    top_data <- top_data %>% mutate(Group = paste0("top", tag))

    # Combine the datasets
    combined_data <- bind_rows(bottom_data, top_data)

    # Clean and adjust the data
    # Convert 'Status' to numeric (1 = deceased, 0 = censored) and ensure 'Time (months)' is numeric
    combined_data <- combined_data %>%
        mutate(
            Status = ifelse(Status == "deceased", 1, 0), # Replace "alive" with 0 if applicable
            `Time (months)` = as.numeric(`Time (months)`) # Ensure 'Time (months)' is numeric
        )

    # Rename the 'Time (months)' column to 'Time' for consistency
    combined_data <- combined_data %>% rename(Time = `Time (months)`)

    # Define the output file name dynamically based on the tag and curve_type
    excel_output_file <- paste0("C:/prepared_excel_km_data_cesc/", "prepared_", tag, "_", curve_type, "_", dataset_type, "_", gene_name, ".csv")

    # Save the cleaned and processed data to a CSV file
    write.csv(combined_data, excel_output_file, row.names = FALSE)

    # Define the output file name dynamically based on the tag and curve_type
    curve_output_file <- paste0("C:/temp_output/", tag, "_", curve_type, "_", dataset_type, "_", gene_name, ".png")

    # Dynamically set the title
    title <- paste(tag, curve_type, toupper(dataset_type), toupper(gene_name))

    # Call the generate_km_curve function to generate and save the Kaplan-Meier curve
    generate_km_curve(combined_data, curve_output_file, title)

    # Print message indicating completion for this file
    print(paste("Data further processed and Kaplan-Meier plot saved as:", title))
}
