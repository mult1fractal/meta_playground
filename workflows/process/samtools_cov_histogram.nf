process nanoplot {
    label 'samtools'
    publishDir "${params.output}/${params.readqcdir}/${name}/", mode: 'copy', pattern: "*.txt"
    
    input:
      tuple val(name), path(bam_file)
    output:
      tuple val(name), path("*.txt") optional true
    script:
      """
        samtools sort ${bam_file} > ${name}_sorted.bam
        samtools coverage -m ${name}_sorted.bam  > ${name}_histogram_coverage.txt
      """
} 