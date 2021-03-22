process nanoplot {
    label 'minimap2'
    publishDir "${params.output}/${params.readqcdir}/${name}/", mode: 'copy', pattern: "*.bam"
    
    input:
      tuple val(name), path(fastq_file)
      tuple val(file), path(fasta_reference)
    output:
      tuple val(name), path("*.bam") optional true
    script:
      """
        minimap2 -t ${task.cpus} -ax map-ont ${fasta_reference} ${fastq_file} | samtools view -hbF4 | samtools sort -@ ${task.cpus} > ${name}.bam
      """
} 