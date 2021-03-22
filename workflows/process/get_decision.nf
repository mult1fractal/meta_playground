process get_decision {
    publishDir "${params.output}/decision_files", mode: 'copy', pattern: "*_${name}_read_id.txt"
    label 'ubuntu'
    input:
        tuple val(name), path(read_until)
    output:
        tuple val(name), path("*_${name}_read_id.txt")
    script:
        """
        ## get all decisions of read until file
        cat ${read_until} | tail -n+2 | cut -d"," -f8 | sort -u > decision_list.txt

        ##  create read- id list per decision
        while read line; do  
            grep -w "\$line" ${read_until} | cut -d"," -f6 > "\$line"_${name}_read_id.txt 
            done < decision_list.txt
        """
}