Your data assumes it was downloaded from cbioportal as a .txt document. 
Run process_and_plot_data.r to iterate over the list of raw text documents downloaded.
It will write out the converted txt to xlsx, the xlsx document prepared to be plotted, and then will save the plots

Note the files have important naming conventions:
{group breakdown}_{type of plot}_{dataset}_{gene name}
e.g 50th Percentile_disease free_ TCGA LUAD_MIEN1

For the cervix_run.r, this assumes genomic data commons data has been extracted and manually processed to a file that can be run by process_and_plot_data

Note file paths for reading and writing must be adjusted to the user's preference.