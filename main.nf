include {trim} from "./modules/fastp/main.nf"
raw_reads = Channel.fromPath(params.raw_reads)

process reads_with_samplename{
    // This process takes a channel of filepaths and returns a channel of tuple (samplename), (filepath) for downstream ease of naming
    input: 
    path (raw_reads)

    output:
    tuple val(sample), path(raw_reads), emit: reads

    script:
        sample = raw_reads.baseName.replaceAll(/\.fastq$/, "")
        """
        echo ${sample}
        """
}


workflow {
    reads = reads_with_samplename(raw_reads)
    reads.view()
}