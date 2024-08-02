
process call_peaks {
    
    container "tdnipper/bioinformatics:pureclip"

    publishDir "${projectDir}/output/results/pureclip/bed", mode: "symlink", pattern: "*.bed.gz"

    input:
    tuple val(sample), path(reads), path(index)
    output:
    tuple val(sample), path("*_xlinks.bed.gz"), path("*_regions.bed.gz"), emit: peaks
    val(true), emit: status

    script:
    """
    pureclip -i ${reads} -bai ${index} -g ${params.hybrid_genome_file} -o ${sample}_xlinks.bed -or ${sample}_regions.bed -nt ${executor.cpus} -iv 'chr1;chr2;chr3'

    gzip ${sample}_xlinks.bed

    gzip ${sample}_regions.bed
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
    samtools merge -o combined_input.bam ${files} -@ ${executor.cpus}

    samtools sort -o combined_input_sorted.bam combined_input.bam -@ ${executor.cpus}

    samtools index -o combined_input_sorted.bai combined_input_sorted.bam -@ ${executor.cpus}
    """
}
