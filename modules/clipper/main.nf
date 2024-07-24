process clipper_call_peaks {
    container "brianyee/clipper:6594e71"

    publishDir "${projectDir}/output/results/clipper", mode: "symlink", pattern: "*.bed.gz"

    input:
    tuple val(sample), path(bam), path(bai)
    path(bed12)

    output:
    tuple val(sample), path("*.bed.gz")

    script:
    """
    pigz -d -c ${bam} > unzipped.bam
    clipper -b unzipped.bam -o ${sample}.bed --species GRCh38
    
    pigz ${sample}.bed

    rm unzipped.bam
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