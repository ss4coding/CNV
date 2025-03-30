#!/bin/bash

# Get the gene_file_paths passed from the Python script
gene_file_paths_string=$1
IFS=' ' read -r -a FOLDERS <<< "$gene_file_paths_string"  # Convert the string back to an array

# Iterate over each folder
for FOLDER in "${FOLDERS[@]}"
do
  COUNTFILE=1

  # Navigate to each folder
  cd "$FOLDER" || continue  # Skip folder if cd fails

  OUTPUTFILENAME="countreport.csv"

  # Add "ID" column to the CSV header
  echo "Subject ID, Tumor Count(wxs), Blood Count(wxs), Ratio(Tumor Count/Blood Count)(wxs), ID" >> ${OUTPUTFILENAME}

  echo "In folder ${FOLDER}"

  for TUMORFILE in *-01A_*.bam
  do
    BLOODFILE=`echo ${TUMORFILE} | sed 's/-01A_/-10A_/'`
    SOLIDTISSUE=`echo ${TUMORFILE} | sed 's/-01A_/-11A_/'`
    echo "Processing file ${COUNTFILE}"

    if test -f ${BLOODFILE}
    then
        COUNTFILE=`expr ${COUNTFILE} + 1`
        SUBJECTID=`echo ${TUMORFILE}`
        # Get ID by removing the last 18 characters from SUBJECTID
        ID=`echo ${SUBJECTID} | rev | cut -c 19- | rev`

        echo -n "${SUBJECTID}," >>${OUTPUTFILENAME}
        COUNTTUMOR=`samtools view -c -F 260 ${TUMORFILE}`
        COUNTBLOOD=`samtools view -c -F 260 ${BLOODFILE}`
        echo -n "${COUNTTUMOR},${COUNTBLOOD}," >>${OUTPUTFILENAME}
        RATIO=`python ../computeratio.py ${COUNTTUMOR}  ${COUNTBLOOD}`
        echo -n "${RATIO}," >>${OUTPUTFILENAME}
        echo ${ID} >>${OUTPUTFILENAME}

    elif test -f ${SOLIDTISSUE}
    then
        COUNTFILE=`expr ${COUNTFILE} + 1`
        SUBJECTID=`echo ${TUMORFILE}`
        # Get ID by removing the last 18 characters from SUBJECTID
        ID=`echo ${SUBJECTID} | rev | cut -c 19- | rev`

        echo -n "${SUBJECTID}," >>${OUTPUTFILENAME}
        COUNTTUMOR=`samtools view -c -F 260 ${TUMORFILE}`
        COUNTSOLIDTISSUE=`samtools view -c -F 260 ${SOLIDTISSUE}`
        echo -n "${COUNTTUMOR},${COUNTSOLIDTISSUE}," >>${OUTPUTFILENAME}
        RATIO=`python ../computeratio.py ${COUNTTUMOR} ${COUNTSOLIDTISSUE}`
        echo -n "${RATIO}," >>${OUTPUTFILENAME}
        echo ${ID} >>${OUTPUTFILENAME}

        echo "Solid tissue sample found"
    else
        echo "Cannot find matching blood or solid tissue sample for ${TUMORFILE}, File Number ${COUNTFILE}"
    fi
  done

  # Return to the parent directory
  cd - || exit
done