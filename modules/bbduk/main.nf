// Define ribofile using path in config params
ribofile = file(params.ribofile)

process bbduk {
    tag "preprocessing"
    tag "decon"

    container "quay.io/biocontainers/bbmap:38.22--h470a237_0"

    publishDir "${projectDir}/output/logs/bbduk", mode: "symlink", pattern: "*stats.txt"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}_ribodepleted.fastq.gz"), emit: ribodepleted_reads
    path "*_stats.txt", emit: logs

    script:
    """
    bbduk.sh in1=${reads[0]} out1=${sample}_ribodepleted.fastq.gz ref=${ribofile} stats=${sample}_stats.txt 
    """
}
