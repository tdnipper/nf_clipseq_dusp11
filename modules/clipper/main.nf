process clipper_call_peaks {
    container "tdnipper/bioinformatics:clipper"
    publishDir "${projectDir}/output/results/clipper", mode: "symlink", pattern: "*.bed.gz"

    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path("*.bed.gz")

    script:
    """
    clipper -b ${bam} -o ${sample}.bed -s GRCh38_v29
    
    pigz ${sample}.bed
    """
}

process clipper_bedfile {
    container "tdnipper/bioinformatics:bedtools"

    input:
    val(xlinks_done)

    output:
    path("hg38.bed")

    script:
    gtf = params.hybrid_genome_gtf
    """
    awk '{if(\$3 != "gene") print \$0}' ${gtf} | grep -v "^#" | gtfToGenePred /dev/stdin /dev/stdout | genePredToBed stdin hg38.bed
    """
}