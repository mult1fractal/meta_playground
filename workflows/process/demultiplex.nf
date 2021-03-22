process demultiplex {

        if (workflow.profile.contains('docker')) {
            container = 'nanozoo/guppy_gpu:4.4.1-1--a3fcea3'
        }

        //publishDir "${params.output}/${name}/", mode: 'copy'
    input:
        tuple val(name), path(dir)
    output:
        tuple val(name), path("fastq"), emit: demultiplexed_fastq_dir
    script:
        """
        Barcode_kit=${"SQK-RPB004"}

        guppy_barcoder -t ${task.cpus} -i ${dir} -s fastq --trim_barcodes --barcode_kits \$Barcode_kit
        ## eventually add gzip for bacodes
        """
}


