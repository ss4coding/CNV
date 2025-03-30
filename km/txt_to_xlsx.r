# Load required libraries
library(readr)
library(writexl)

# Function to process a file and save it into Excel
process_file <- function(file_path) {
    # Read the entire .txt file as raw text
    content <- read_lines(file_path)

    # Initialize empty lists to hold data for sections (A) and (B)
    section_A_data <- list()
    section_B_data <- list()

    # Flags to track whether we are in section A or B
    in_section_A <- FALSE
    in_section_B <- FALSE

    # Loop through each line to identify and separate sections (A) and (B)
    for (line in content) {
        line <- trimws(line)
        if (line == "") {
            next # Skip empty lines
        }

        # Capture the section label (A) or (B) along with following identifier
        if (grepl("\\(A\\)", line)) {
            in_section_A <- TRUE
            in_section_B <- FALSE
            section_A_desc <- trimws(sub(".*\\(A\\)(.*)", "\\1", line)) # Get the string after (A)
            next # Skip the header line
        }

        if (grepl("\\(B\\)", line)) {
            in_section_A <- FALSE
            in_section_B <- TRUE
            section_B_desc <- trimws(sub(".*\\(B\\)(.*)", "\\1", line)) # Get the string after (B)
            next # Skip the header line
        }

        # Add lines to the appropriate section data based on the flags
        if (in_section_A) {
            section_A_data <- append(section_A_data, list(line))
        }

        if (in_section_B) {
            section_B_data <- append(section_B_data, list(line))
        }
    }

    # Convert the data for each section into a data frame (tab-separated)
    create_dataframe <- function(section_data) {
        if (length(section_data) == 0) {
            return(data.frame()) # Return empty data frame if no data
        }
        # Convert all lines into character data for splitting
        section_data_char <- as.character(section_data)

        # Split data into columns and assign header to first row
        data_split <- strsplit(section_data_char, "\t")
        header <- data_split[[1]]
        data <- do.call(rbind, data_split[-1])
        df <- as.data.frame(data, stringsAsFactors = FALSE)
        colnames(df) <- header
        return(df)
    }

    # Function to assign section to sheet ("top" or "bottom") based on its descriptor
    # NOTE: this will depend on how you labeled groups in cbioportal
    assign_sheet <- function(section_desc) {
        if (grepl("bottom|not|under", section_desc, ignore.case = TRUE)) {
            return("bottom")
        } else if (grepl("top|andup", section_desc, ignore.case = TRUE)) {
            return("top")
        }
        return(NULL) # If no clear indicator, do not assign
    }

    # Assign section A and B to correct sheet based on their description
    section_A_sheet <- assign_sheet(section_A_desc)
    section_B_sheet <- assign_sheet(section_B_desc)

    # Initialize list for storing sheets
    sheets <- list()

    # Add section A data to the correct sheet if assigned
    if (!is.null(section_A_sheet)) {
        section_A_df <- create_dataframe(section_A_data)
        if (nrow(section_A_df) > 0) {
            sheets[[section_A_sheet]] <- section_A_df
        }
    }

    # Add section B data to the correct sheet if assigned
    if (!is.null(section_B_sheet)) {
        section_B_df <- create_dataframe(section_B_data)
        if (nrow(section_B_df) > 0) {
            sheets[[section_B_sheet]] <- section_B_df
        }
    }

    # Define output Excel file path (replace .txt with .xlsx)
    file_name <- gsub(".txt", ".xlsx", basename(file_path))
    output_path <- file.path("C:/raw_excel_km_data_cesc/", file_name)

    # Save the processed data into Excel with top and bottom sheets
    if (length(sheets) > 0) {
        write_xlsx(sheets, output_path)
    }
}

# Get list of all .txt files in the target directory
directory_path <- "C:/raw_km_data_cesc"
txt_files <- list.files(directory_path, pattern = "\\.txt$", full.names = TRUE)

# Process each .txt file
for (txt_file in txt_files) {
    process_file(txt_file)
}
