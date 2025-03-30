PRIOR TO RUNNING YOUR CODE
1. Make a folder for all your genes to be run in. Within that folder include run_multiple_files.py, computeratio.py, gdcslice.sh, rename.py, luadcount.sh, indexbamfiles.sh, your_sample_sheet.csv, token.txt, and manifest.txt
    - You can choose to add folders for all the genes, but it is not necessary. If you have a folder with the name made already, ensure it is empty for safety.
2. In run_multiple_files.py fill in: 
    - "the_file_path_you_wish_to_write_to": "the chromosomal location" (fill in as many as you want, but be aware that limits have not been tested)
    - token_path, manifest_path, sample_sheet_path
        - Realize that sample_sheet should be a csv
        - FYI, ./ indicates the directory you are running the code from. Hence bullet #1's instructions.
3. In gdcslice_for_multiple_files.sh, you will need to adjust the array size per the instructions there
4. Run with python run_multiple_files.py (requires module load apps/python/3.6.2)

Note file paths for reading and writing must be adjusted to the user's preference.