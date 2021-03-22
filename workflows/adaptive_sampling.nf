include { get_decision } from './process/get_decision'
include { create_decision_fastqs } from './process/create_decision_fastqs'

workflow adaptive_sampling_wf {
    take:   fastq_gz
            read_until 

    main:   separated_fastqs = create_decision_fastqs(fastq_gz, get_decision(read_until))

        

    emit: separated_fastqs
} 