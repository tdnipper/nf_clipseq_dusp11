
process call_peaks {

    debug = true
    
    container "tdnipper/bioinformatics:pureclip"

    publishDir "${projectDir}/output/results/pureclip", mode: "symlink", pattern: "*.bed"
    // publishDir "${projectDir}/output/logs/pureclip", mode: "symlink", pattern: "*log*"

    input:
    tuple val(sample), path(reads), path(index)
    tuple path(ibam), path(ibai)
    output:
    tuple val(sample), path("*_xlinks.bed"), path("*_regions.bed"), emit: peaks
    // path ("*log*"), emit: logs

    script:
    """
    pureclip -i ${reads} -bai ${index} -g ${params.hybrid_genome_file} -o ${sample}_xlinks.bed -or ${sample}_regions.bed -ibam ${ibam} -ibai ${ibai} -nt ${task.cpus} -iv 'chr1;chr2;chr3'
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
