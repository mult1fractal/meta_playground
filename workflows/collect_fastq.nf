include { collect_fastq } from './process/collect_fastq'
include { demultiplex } from './process/demultiplex'

workflow collect_fastq_wf {
    take: 
        fastq_dir  
    main:
        if ( params.demultiplex ) { collect_fastq(demultiplex(fastq_dir)) }
        else collect_fastq(fastq_dir)
       // collect_fastq(demultiplexed_fastq_dir.out)

        if (params.single) { fastq_channel = collect_fastq.out }
        else { fastq_channel = collect_fastq.out
                            .map { it -> it[1] }
                            .flatten()
                            .map { it -> [ it.simpleName, it ] }
        }

    emit: fastq_channel
} 