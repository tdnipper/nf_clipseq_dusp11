process icount_call_peaks {
    container "tdnipper/bioinformatics:iCount"

    publishDir "output/results/iCount", method: "symlink", pattern: "*.tsv"
    publishDir "output/results/iCount", method: "symlink", pattern: "*.bed.gz"

    input:
    tuple val(sample), path(xlinks_bed) //xlinks already found in get_xlinks bedtools process
    path(segment)

    output:
    tuple val(sample), path("*.bed.gz")

    script:
    // xlinks already found in get_xlinks bedtools process, will just call peaks and get clusters
    """
    pigz -d -c ${xlinks_bed} > unzipped_xlinks.bed
    
    iCount peaks ${segment} unzipped_xlinks.bed ${sample}_peaks.bed --scores ${sample}_scores.tsv
    
    pigz ${sample}_peaks.bed

    rm unzipped_xlinks.bed
    """
}

process get_segments {
    container "tdnipper/bioinformatics:iCount"

    debug = true

    input:
    val(xlinks_complete)

    output:
    path("*segments.gtf.gz")

    script:
    in_gtf = params.hybrid_genome_gtf
    in_fai = params.hybrid_genome_fai

    """
    iCount segment ${in_gtf} hg38_segments.gtf.gz ${in_fai} -prog
    """
}