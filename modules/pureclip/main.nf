
process call_peaks {
    
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

process combine_control_bam {
    container "tdnipper/bioinformatics:star"

    input:
    path(files)

    output:
    tuple path("*_sorted.bam"), path("*_sorted.bai"), emit: combined_bam

    script:
    """
    samtools merge -o combined_input.bam ${files} -@ ${task.cpus}

    samtools sort -o combined_input_sorted.bam combined_input.bam -@ ${task.cpus}

    samtools index -o combined_input_sorted.bai combined_input_sorted.bam -@ ${task.cpus}
    """
}
