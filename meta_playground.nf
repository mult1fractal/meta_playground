#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* 
* Author: KEK
*/

/************************** 
* HELP messages & checks
**************************/

/* 
Nextflow version check  
Format is this: XX.YY.ZZ  (e.g. 20.07.1)
change below
*/

XX = "20"
YY = "10"
ZZ = "0"

if ( nextflow.version.toString().tokenize('.')[0].toInteger() < XX.toInteger() ) {
println "\033[0;33mporeCov requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}
else if ( nextflow.version.toString().tokenize('.')[1].toInteger() == XX.toInteger() && nextflow.version.toString().tokenize('.')[1].toInteger() < YY.toInteger() ) {
println "\033[0;33mporeCov requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}



// profile helps
    if ( workflow.profile == 'standard' ) { exit 1, "NO EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }
    if (params.profile) { exit 1, "--profile is WRONG use -profile" }
    if (
        workflow.profile.contains('singularity') ||
        workflow.profile.contains('nanozoo') ||
        workflow.profile.contains('ukj_cloud') ||
        workflow.profile.contains('docker')
        ) { "engine selected" }
    else { println "No engine selected:  -profile EXECUTER,ENGINE" 
           println "using native installations" }
    if (
        workflow.profile.contains('nanozoo') ||
        workflow.profile.contains('ukj_cloud') ||
        workflow.profile.contains('local')
        ) { "executer selected" }
    else { exit 1, "No executer selected:  -profile EXECUTER,ENGINE" }

    if (workflow.profile.contains('local')) {
        println "\033[2m Using $params.cores/$params.max_cores CPU threads [--max_cores]\u001B[0m"
        println " "
    }
    if ( workflow.profile.contains('singularity') ) {
        println ""
        println "\033[0;33mWARNING: Singularity image building sometimes fails!"
        println "Multiple resumes (-resume) and --max_cores 1 --cores 1 for local execution might help.\033[0m\n"
    }

// params help
if (!workflow.profile.contains('test_fastq') && !workflow.profile.contains('test_fast5') && !workflow.profile.contains('test_fasta')) {
    if (!params.fasta &&  !params.fast5 &&  !params.fastq &&  !params.fastq_pass ) {
        exit 1, "input missing, use [--fasta] [--fastq] [--fastq_pass] or [--fast5]"}
    if ((params.fasta && ( params.fastq || params.fast5 )) || ( params.fastq && params.fast5 )) {
        exit 1, "To many inputs: please us either: [--fasta], [--fastq] or [--dir]"} 
if ( (params.cores.toInteger() > params.max_cores.toInteger()) && workflow.profile.contains('local')) {
        exit 1, "More cores (--cores $params.cores) specified than available (--max_cores $params.max_cores)" }
}
/************************** 
* INPUTs
**************************/

// fastq raw input direct from basecalling
    if (params.fastq_pass && params.list && !workflow.profile.contains('test_fastq')) { 
        fastq_dir_ch = Channel
        .fromPath( params.fastq_pass, checkIfExists: true )
        .splitCsv()
        .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true, type: 'dir')] }
    }
    else if (params.fastq_pass && !workflow.profile.contains('test_fastq')) { 
        fastq_dir_ch = Channel
        .fromPath( params.fastq_pass, checkIfExists: true, type: 'dir')
        .map { file -> tuple(file.simpleName, file) }
    }


// samples input 
    if (params.samples) { samples_input_ch = Channel
        .fromPath( params.samples, checkIfExists: true)
        .splitCsv(header: true, sep: ',')
        .map { row -> tuple ("barcode${row.barcode[-2..-1]}", "${row._id}")}
        .view()
    }

    if (params.read_until) { read_until_input_ch = Channel
        .fromPath( params.read_until, checkIfExists: true)
        .map { file -> tuple(file.simpleName, file) }
        .view()
    }

    if (params.fastq) { fastq_file_ch = Channel
        .fromPath( params.fastq, checkIfExists: true)
        .map { file -> tuple(file.simpleName, file) }
        .view()
    }
    // extended input
    // if (params.samples && params.extended) { 
    //     extended_input_ch = Channel.fromPath( params.samples, checkIfExists: true)
    //     .splitCsv(header: true, sep: ',')
    //     .collectFile() {
    //                 row -> [ "extended.csv", row.'_id' + ',' + row.'Submitting_Lab' + ',' + row.'Isolation_Date' + ',' + 
    //                 row.'Seq_Reason' + ',' + row.'Sample_Type' + '\n']
    //                 }
    // }
    else { extended_input_ch = Channel.from( ['deactivated', 'deactivated'] ) }


/************************** 
* MODULES
**************************/

// include { get_fast5 } from './modules/get_fast5_test_data.nf'
// include { get_nanopore_fastq } from './modules/get_fastq_test_data.nf'
// include { get_fasta } from './modules/get_fasta_test_data.nf'
// include { align_to_reference } from './modules/align_to_reference.nf'
// include { split_fasta } from './modules/split_fasta.nf'

/************************** 
* Workflows
**************************/

include { collect_fastq_wf } from './workflows/collect_fastq.nf'
include { emit_fastq_wf } from './workflows/emit_fastq.nf'
include { adaptive_sampling_wf } from './workflows/adaptive_sampling'
include { read_qc_wf } from './workflows/read_qc'




/************************** 
* MAIN WORKFLOW
**************************/

workflow {

        // fastq input via dir and or files
        //if ( (params.fastq || params.fastq_pass) || workflow.profile.contains('test_fastq')) { 
            if (params.fastq_pass && !params.fastq) { fastq_input_raw_ch = collect_fastq_wf(fastq_dir_ch) }
            if (!params.fastq_pass && params.fastq) { fastq_input_raw_ch = fastq_file_ch }

            // raname barcodes based on --samples input.csv
                if (params.samples) { fastq_input_ch = fastq_input_raw_ch.join(samples_input_ch).map { it -> tuple(it[2],it[1])}.view() }
                else if (!params.samples) { fastq_input_ch = fastq_input_raw_ch }
            
            //  safe renamed.fastq.gz    
            //emit_fastq_wf(fastq_input_ch)

            // adaptive sampling analysis
            if ( params.read_until ) { adaptive_sampling_wf(emit_fastq_wf.out, read_until_input_ch) }
            if ( params.fastq && params.read_qc) { read_qc_wf(fastq_input_ch) }
            // read_qc_wf(fastq_input_ch)
            // read_classification_wf(fastq_input_ch)
           }   // fasta_input_ch = artic_ncov_wf(fastq_input_ch)[0]
        

  
/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    
nextflow run sample_me.nf --samples test_data/sequencing_output/115_VT0_deep_seq_ad-sam_barcode_overview.csv --fastq_pass test_data/sequencing_output/fastq_pass/ --demultiplex -profile local,docker -work-dir work/ --cores 10 --output results/demultiplex_test
    
nextflow run sample_me.nf --samples test_data/sequencing_output/115_VT0_deep_seq_ad-sam_barcode_overview.csv --fastq_pass test_data/sequencing_output/fastq_pass/ --demultiplex --read_until test_data/sequencing_output/read_until_FAP76673_e0481cad.csv -profile local,docker -work-dir work/ --cores 10 --output results/adaptive_sempling_decisions    
    
## for nanoplot
nextflow run sample_me.nf --fastq 'results/11*/*fastq.gz' --read_qc -profile local,docker -work-dir work/ --cores 10 --output results/nanoplot    
    
    """.stripIndent()
}
