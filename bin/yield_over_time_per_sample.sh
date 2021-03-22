#!/bin/env bash


# checks folderstriucture: eg. 115_deep_seq/throughput*.csv
# yield oer time
for i in */throughput*.csv ; do
    samplename=$(basename $i | cut -d "." -f1 )
    tail -n+2 $i | cut -d "," -f 1,8 > tmp_"$samplename".csv
    awk -v d="$samplename" -F"," 'BEGIN { OFS = "," } {$3=d; print}' tmp_"$samplename".csv > final_"$samplename".csv
done

cat final*.csv > yield_over_time.csv
sed -i '1s/.*/time,estimated_bases,sample\n&/' yield_over_time.csv
rm tmp* final*

# read over time
for i in */throughput*.csv ; do
    samplename=$(basename $i | cut -d "." -f1 )
    tail -n+2 $i | cut -d "," -f 1,2 > tmp_"$samplename".csv
    awk -v d="$samplename" -F"," 'BEGIN { OFS = "," } {$3=d; print}' tmp_"$samplename".csv > final_"$samplename".csv
done

cat final*.csv > reads_over_time.csv
sed -i '1s/.*/time,reads,sample\n&/' reads_over_time.csv
rm tmp* final*


# throughput*.csv
#Experiment Time (minutes),Reads,Basecalled Reads Passed,Basecalled Reads Failed,Basecalled Reads Skipped,Selected Raw Samples,Selected Events,Estimated Bases,Basecalled Bases,Basecalled Samples,
