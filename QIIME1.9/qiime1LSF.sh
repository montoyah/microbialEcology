#!/bin/sh
### General options (taken from http://www.hpc.dtu.dk/?page_id=2723)
### -- specify queue --
##BSUB -q queueName
### -- set the job Name --
#BSUB -J jobName
### -- Number of cores to use--
#BSUB -n 24
### -- specify that we need 2GB of memory per core/slot --
##BSUB -R "rusage[mem=2GB]"
### -- specify that we want the job to get killed if it exceeds 3 GB per core/slot --
##BSUB -M 3GB
### -- set walltime limit: hh:mm --
#BSUB -W 200:00
### -- set the email address --
# please uncomment the following line and put in your e-mail address,
# if you want to receive e-mail notifications on a non-default address
##BSUB -u emailAddress
### -- send notification at start --
##BSUB -B
### -- send notification at completion --
#BSUB -N
### -- Specify the output and error file. %J is the job-id --
### -- -o and -e mean append, -oo and -eo mean overwrite --
#BSUB -o jobName_%J.out


source activate qiime1

path=/path/to/folder # This path contains the directories "cutadapt_results" (or quivalent quality controled data),
# "1_contigs", "2_qualityControl", "3_pickedOTUs"

# Construct contigs
multiple_join_paired_ends.py -i path/cutadapt_results/ -o path/1_contigs/ -p /home/oemontoy/qiime/parameters_files/qiime_parameters_pairing_50bp.txt

# Quality control
multiple_split_libraries_fastq.py -i path/1_contigs/ -o path/2_qualityControl -p /home/oemontoy/qiime/parameters_files/qiime_multiple_split_libraries.txt --include_input_dir_path --remove_filepath_in_name

# Make OTUs and assign taxonomy
pick_open_reference_otus.py -i path/2_qualityControl/seqs.fna -o path/3_pickedOTUs -p /home/oemontoy/qiime/parameters_files/open_ref_otus_parameters_silva128.txt -a -f

# Get per-sample summary stats
biom summarize-table -i path/3_pickedOTUs/otu_table_mc2.biom -o path/4_biomSummary/otu_table_mc2_summary_stats.txt

# Transform OTU/taxa table (otu_table_mc2.biom) into .csv
biom convert -i path/3_pickedOTUs/otu_table_mc2_w_tax.biom -o path/3_pickedOTUs/otu_table_mc2_w_tax.csv --to-tsv --header-key taxonomy
