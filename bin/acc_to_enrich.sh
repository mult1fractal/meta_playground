cat 115_VT0_deep_seq_ada-sam.fastq_centrifuge_filtered.out | cut -f2 | sort -u | head -n -4 > accessions_to_enrich.txt
head -n -4 variable to each files

while read line; do
# reading each line
    #echo "$line" 
    #echo "___"
    esearch -db nucleotide -query $line | efetch -format fasta > fasta/"$line".fasta 
    sleep 10
done < accessions_to_enrich.txt



while IFS= read -r line
    do
    esearch -db nucleotide -query $line | efetch -format fasta > fasta/"$line".fasta 
done < accessions_to_enrich.txt#



#get best hits > 100 reads to enrich
cat 115_VT0_deep_seq_ada-sam.fastq_pavian_report_filtered.csv | grep -w "S" | cut -f1,2,6 | tr "\t" "," | tr -s " " | awk -v z="0.01" '$1>=z' | awk '{sub(/^ +/,""); gsub(/, /,",")}1' | sort -k1,1 -k2,2n | wc -l