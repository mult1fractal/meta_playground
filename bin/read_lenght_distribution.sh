

# yield oer time
for i in */sequencing_summary*.txt ; do
    samplename=$(basename $i | cut -d "." -f1 )
    tail -n+2 $i | cut -f3,14 > tmp_"$samplename".tsv
    awk -v d="$samplename" 'BEGIN { OFS = "\t" } {$3=d; print}' tmp_"$samplename".tsv > final_read_dis_"$samplename".tsv
    sed -i '1s/.*/read_id\tsequence_lenght\tsample\n&/' final_read_dis_"$samplename".tsv
done


