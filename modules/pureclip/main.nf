
process call_peaks{
    
    container "tdnipper/bioinformatics:pureclip"

    publishDir "${projectDir}/output/results/pureclip", mode: "symlink", pattern: "*.bed"

    input:
    tuple val(sample), path(reads), path(index)
    tuple val(sample), path(controlFile)
    output:
    tuple val(sample), path("*_xlinks.bed"), path("*_regions.bed"), emit: peaks

    script:
    """
    pureclip -i ${reads} -bai ${index} -g ${params.hybrid_genome_file} -o ${sample}_xlinks -or ${sample}_regions -nt ${task.cpus}
    """
}
