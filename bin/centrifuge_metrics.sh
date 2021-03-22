#!/bin/env bash


## from pavian reports

for i in *_pavian_report_filtered.csv ; do
    samplename=$(echo "$i" | awk -F"_pavian_report_filtered.csv" '{print $1}')
    ## human metrics
    human_classified=$(grep -w "G" $i | grep -w "Homo" | cut -f1 | tr -d " ")
    human_classified_reads=$(grep -w "G" $i | grep -w "Homo" | cut -f2 )
    ## bacteria metrics
    bacteria_classified=$(grep -w "D" $i | grep -w "Bacteria" | cut -f1 | tr -d " ")
    bacteria_classified_reads=$(grep -w "D" $i | grep -w "Bacteria" | cut -f2 )
## root bacteria reads        
    echo "$samplename|$human_classified|$human_classified_reads|$bacteria_classified|$bacteria_classified_reads " >> pavian_metrics.csv
    ## taxa amount
    amount_of_taxa_class=$(grep -w "C" $i | wc -l )
    amount_of_taxa_phyla=$(grep -w "P" $i | wc -l )
    amount_of_taxa_genus=$(grep -w "G" $i | wc -l )
    amount_of_taxa_sepcies=$(grep -w "S" $i | wc -l )

        
    echo "$samplename|$amount_of_taxa_class|$amount_of_taxa_phyla|$amount_of_taxa_genus|$amount_of_taxa_sepcies" >> taxa_metrics.csv
## root bacteria reads
done

sed -i '1s/.*/samplename|human_classified|human_classified_reads|bacteria_classified|bacteria_classified_reads\n&/' pavian_metrics.csv
sed -i '1s/.*/samplename|class_total|phyla_total|genus_total|species_total\n&/' taxa_metrics.csv

for i in 1.Read_quality/*/*_read_quality.txt ; do
    samplename=$(basename $i)
    Read_length_N50=$(grep -w "Read length N50" $i | cut -d ":" -f2 )
    Number_of_reads=$(grep -w "Number of reads" $i | cut -d ":" -f2 )
    Mean_read_length=$(grep -w "Mean read length" $i | cut -d ":" -f2 )
    echo "$samplename|$Read_length_N50|$Number_of_reads|$Mean_read_length|" >> nanoplot_comparison.csv


done

sed -i '1s/.*/samplename|Read_length_N50|Number_of_reads|Mean_read_length|\n&/' nanoplot_comparison.csv