process star_align {

    container "tdnipper/bioinformatics:star"

    publishDir "${workflow.projectDir}/output/logs/star", mode: 'symlink', pattern: "*Log.out"
    publishDir "${workflow.projectDir}/output/logs/star", mode: "symlink", pattern: "*Log.final.out"
    publishDir "${projectDir}/output/results/genecounts", mode: "symlink", pattern: "*ReadsPerGene*"
    publishDir "${projectDir}/output/results/transcript_counts", mode: "symlink", pattern: "*toTranscriptome.out.bam"

    input:
    tuple val(sample), path(r1), path(r2)
    path(index)

    output:
    tuple val(sample), path("*_aligned.bam"), emit: bam
    tuple val(sample), path("*_coord_sorted.bam"), emit: sorted_bam 
    tuple val(sample), path("*.bai"), emit: indexed_bam
    tuple val(sample), path('*.ReadsPerGene.out.tab')  , optional:true, emit: read_per_gene_tab
    tuple val(sample), path("*Log.out"), emit: log_out
    tuple val(sample), path("*Log.final.out"), emit: log_final_out
    tuple val(sample), path('*toTranscriptome.out.bam'), optional: true, emit: bam_transcript
    val(true), emit: done

    script:
    """
    STAR --runThreadN ${task.cpus} \
    --genomeDir ${index} \
    --readFilesIn ${r1} ${r2} \
    --outFileNamePrefix ${sample}_ \
    --quantMode ${params.star_mode} \
    --outReadsUnmapped Fastx \
    --readFilesCommand zcat

    samtools view ${sample}_Aligned.out.sam -o ${sample}_aligned.bam -@ ${task.cpus}

    rm ${sample}_Aligned.out.sam

    samtools sort ${sample}_aligned.bam -o ${sample}_coord_sorted.bam -@ ${task.cpus}

    samtools index ${sample}_coord_sorted.bam -@ ${task.cpus}

    """

}

process star_removal {
    
    container "tdnipper/bioinformatics:star"

    input:
    val(done)
    path(index)

    output:
    path("*Log.out"), emit: log_out

    script:
    """
    STAR --genomeLoad Remove --genomeDir ${index} --outFileNamePrefix exit
    """

}