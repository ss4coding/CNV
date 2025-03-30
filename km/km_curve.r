# Load necessary libraries
library(survival)
library(survminer)

# Function to generate and save Kaplan-Meier survival curves with dynamic title
generate_km_curve <- function(data, output_file, title) {
    # Ensure that Time and Status are in correct format (numeric)
    data$Time <- as.numeric(data$Time)
    data$Status <- as.numeric(data$Status)

    # Fit Kaplan-Meier curve by 'Group' column and specify data
    km_fit <- survfit(Surv(time = data$Time, event = data$Status) ~ Group, data = data) # Reference 'Group' directly in formula

    # Start PNG device with higher resolution (dpi) and larger size
    png(filename = output_file, width = 1600, height = 1200, res = 150) # Increased width, height, and resolution

    # Create Kaplan-Meier plot with risk table
    km_plot <- ggsurvplot(
        km_fit, # Kaplan-Meier fit model
        data = data, # The data used for fitting
        pval = TRUE, # Display p-value for log-rank test
        pval.coord = c(50, 1), # Position of p-value (top-right corner) #FOR MY TCGA use (50, 0.95), use (10, 0.95) for CGCI
        pval.size = 12, # Larger font size for the p-value
        conf.int = FALSE, # Remove confidence intervals
        risk.table = TRUE, # Include risk table
        risk.table.col = "black", # Color-code risk table by group
        risk.table.fontsize = 10, # Set risk table text size
        risk.table.title = "", # Get rid of the risk table title
        risk.table.height = 0.25, # Adjust risk table height to match larger text
        risk.table.y.text = FALSE, # Change labels on risk table to just be the color
        legend.title = "Group", # Title for the legend
        legend.labs = levels(data$Group), # Labels for groups
        title = title, # Dynamically set title here
        xlab = "Months Elapsed", # X-axis label
        ylab = "Survival Probability", # Y-axis label
        palette = c("black", "gray"), # Black-and-white palette
        font.x = 32, # X-axis font size
        font.y = 32, # Y-axis font size
        font.tickslab = 32, # Font size for axis ticks
        font.title = 20, # Title font size
        font.legend = 16, # Legend font size
        font.risk.table = 32, # Increase the risk table font size
        theme = theme_bw(base_size = 16) # Black and white theme for minimalistic look
    )

    # Customize the risk table theme for larger X-axis ticks
    km_plot$table <- km_plot$table +
        theme(
            axis.title.y = element_blank(), # Remove the Y-axis title
            axis.text.x = element_text(size = 28), # Increase font size for risk table X-axis ticks
            axis.title.x = element_text(size = 28) # Increase font size for the risk table X-axis label
        )

    print(km_plot)


    # Close the PNG device to save the file
    dev.off()
}
