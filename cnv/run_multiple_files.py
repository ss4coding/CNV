# NOTE: this code is intended to be run in a folder with:
    # computeratio.py, gdcslice.sh, rename.py, luadcount.sh, indexbamfiles.sh, your_sample_sheet.csv, token.txt, and manifest.txt
    # There should also be as many folders within this folder titled with their gene name
    # Note that if the folder is not present, one will be made with the name provided (done in gdcslice.sh)
    # Note that if you have the folder with content already present you should clear it out prior to running
#TODO: You MUST correct the array size in the gdcslice.sh filed at the top

import os
import subprocess
import time

# TODO: FOR USER map the ouptut file path to the chromosomal location
output_folder_to_gene = {
   "/path/": "chr17:39728510-39730532",
   "/path/": "chr17:58556678-58692045"}

# TODO: JUST PUT THE NAME OF YOUR token.txt, manifest.txt, AND sample_sheet.txt IN THE RESPECTIVE SPOTS
token_path = "./token.txt"
manifest_path = "./manifest.txt"
sample_sheet_path = "./your_sample_sheet.csv"

# Get sorted list of gene file paths from output_folder_to_gene
gene_file_paths = list(output_folder_to_gene.keys())

# Define sbatch script for gdcslice.sh
def run_sbatch_script(script_name, args):
    try:
        # Submit the bash script using sbatch and get the job ID
        print(f"Submitting {script_name} using sbatch...")
        result = subprocess.run(['sbatch', script_name] + args, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        job_id = result.stdout.split()[-1]  # Extract job ID from the output
        print(f"{script_name} submitted with job ID: {job_id}")
        
        # Wait for the job to complete
        while True:
            time.sleep(10)  # Check job status every 10 seconds
            job_status = subprocess.run(['squeue', '--job', job_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            if job_status.stdout.strip() == "":
                print(f"{script_name} completed successfully.")
                break  # Exit the loop when the job is no longer in the queue
            else:
                print(f"{script_name} is still running...")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while running {script_name}: {e}")
        exit(1)

# Define rename.py script
def run_python_script(script_name, args):
    try:
        # Run the python script and wait for it to complete
        print(f"Running {script_name}...")
        result = subprocess.run(['python3', script_name] + args, check=True)
        print(f"{script_name} completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while running {script_name}: {e}")
        exit(1)

# Define sh script for luadcount.sh
def run_bash_script(script_name, args):
    try:
        # Run the bash script directly
        print(f"Running {script_name}...")
        result = subprocess.run(['sh', script_name] + args, check=True)
        print(f"{script_name} completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while running {script_name}: {e}")
        exit(1)


# Step 1: Pass output_folder_to_gene, manifest_path, token_path to gdcslice.sh
for output_folder in list(output_folder_to_gene.keys()):
    chromosomal_location=output_folder_to_gene[output_folder]
    gdcslice_args = [
    output_folder, 
    chromosomal_location,
    manifest_path,
    token_path
]
    run_sbatch_script('gdcslice_for_multiple_files.sh', gdcslice_args)
    print(f"Finished writing to {output_folder}")
    
    # Adding a 10-second pause with a message
    print("Taking extra pause of 10 seconds")
    time.sleep(10)

# Step 2: Run rename.py (python)
rename_args = [sample_sheet_path, " ".join(gene_file_paths)]
run_python_script('rename_for_multiple_files.py', rename_args)
print("Done with rename.py for all genes")

# Step 3: Run luadcount.sh using sh
luadcount_args = [" ".join(gene_file_paths)]  # Join paths into a single string
run_bash_script('luadcount_for_multiple_files.sh', luadcount_args)

print("All scripts completed successfully.")

