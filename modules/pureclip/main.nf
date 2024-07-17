
process call_peaks {
    
    container "tdnipper/bioinformatics:pureclip"

    publishDir "${projectDir}/output/results/pureclip/bed", mode: "symlink", pattern: "*.bed"
    // publishDir "${projectDir}/output/logs/pureclip", mode: "symlink", pattern: "*log*"

    input:
    tuple val(sample), path(reads), path(index)
    // tuple path(ibam), path(ibai)
    output:
    tuple val(sample), path("*_xlinks.bed.gz"), path("*_regions.bed.gz"), emit: peaks
    // path ("*log*"), emit: logs
    val(true), emit: status

    script:
    """
    pureclip -i ${reads} -bai ${index} -g ${params.hybrid_genome_file} -o ${sample}_xlinks.bed -or ${sample}_regions.bed -nt ${task.cpus} -iv 'chr1;chr2;chr3'

    gzip ${sample}_xlinks.bed

    gzip ${sample}_regions.bed
    """
}
// pureclip cut out : -ibam ${ibam} -ibai ${ibai} 

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
