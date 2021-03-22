process create_decision_fastqs {
    publishDir "${params.output}/fastqs_separated/", mode: 'copy', pattern: "*.fastq"
    label 'seqkit'
    input:
        tuple val(name), path(fastq)
        tuple val(decision), path(decision_file)
    output:
        tuple val(name), path("*.fastq")
    script:
        """
        for i in ${decision_file} ; do
            decision=\$(echo "\$i" | cut -d "_" -f1 )
            seqkit grep --pattern-file \$i ${fastq} >> \$decision_${name}.fastq
        done
        """
}
// https://bioinformatics.cvr.ac.uk/essential-awk-commands-for-next-generation-sequence-analysis/