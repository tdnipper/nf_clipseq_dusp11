process dedup {

    container "tdnipper/bioinformatics:umi-tools"
    containerOptions = '--entrypoint=""'

    publishDir "output/logs/umi-tools", method: "symlink", pattern: "*.log"

    input:
    tuple val(sample), path(sorted_bam), path(bai)
    val (signal)

    output:
    tuple val(sample), path("*_dedup.bam"), emit: reads
    path("*.log"), emit: logs

    script:
    """
    umi_tools dedup -I ${sorted_bam} -S ${sample}_dedup.bam \
    --method=directional \
    --extract-umi-method=read_id \
    --umi-separator=rbc: \
    --log ${sample}_dedup.log \
    --error ${sample}_dedup_error.log
    """
}

process index {

    maxForks = 1

    container "tdnipper/bioinformatics:star"

    input: 
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("*.bam"), path("*.bai"), emit: reads

    script:
    """
    samtools sort ${reads} -o ${sample}_sorted_dedup.bam -@ ${params.cpus}
    
    samtools index ${sample}_sorted_dedup.bam -o ${sample}_sorted_dedup.bai -@ ${params.cpus}
    """
}
