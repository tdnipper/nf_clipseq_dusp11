process icount_get_xlinks {
    container "docker.io/tomazc/icount"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("*.bed*"), emit: xlinks

    publishDir "output/results/iCount/xlinks", method: "symlink", pattern: "*.bed"

    script:
    """
    iCount xlinks ${reads} ${sample}_unique.bed ${sample}_multiple.bed ${sample}_skipped.bed
    """
}

process icount_call_peaks {
    container "docker.io/tomazc/icount"

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
    iCount peaks ${segment} ${xlinks_bed} ${sample}_peaks.bed --scores ${sample}_scores.tsv
    """
}

process get_segments {
    container "docker.io/tomazc/icount"

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