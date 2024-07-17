process bed_to_bigwig {
    container "tdnipper/bioinformatics:bedtools"

    debug = true

    publishDir "${projectDir}/output/results/pureclip/bedgraph", mode: "symlink", pattern: "*_sort_merged.bedgraph"
    publishDir "${projectDir}/output/results/pureclip/bigwig", mode: "symlink", pattern: "*.bw"

    input:
    tuple val(sample), path(xlinks), path(regions) //input bed files from pureclip
    path(chromSizes)

    output:
    path("*_sort*.bedgraph"), emit: bedgraph
    path("*.bw"), emit: bigwig

    script:
    """
    awk '{printf "%s\\t%d\\t%d\\t%2.3f\\n" , \$1,\$2,\$3,\$5}' ${xlinks} > ${sample}_xlinks.bedgraph

    bedSort ${sample}_xlinks.bedgraph ${sample}_xlinks_tmp1.bedgraph

    awk '\$2 != -1' ${sample}_xlinks_tmp1.bedgraph > ${sample}_xlinks_sort_tmp2.bedgraph
    
    bedtools merge -i ${sample}_xlinks_sort_tmp2.bedgraph -c 4 -o max > ${sample}_xlinks_sort_merged.bedgraph

    bedGraphToBigWig ${sample}_xlinks_sort_merged.bedgraph ${chromSizes} ${sample}_xlinks.bw

    awk '{printf "%s\\t%d\\t%d\\t%2.3f\\n" , \$1,\$2,\$3,\$5}' ${regions} > ${sample}_regions.bedgraph

    bedSort ${sample}_regions.bedgraph ${sample}_regions_tmp1.bedgraph

    awk '\$2 != -1' ${sample}_regions_tmp1.bedgraph > ${sample}_regions_tmp2.bedgraph
    
    bedtools merge -i ${sample}_regions_tmp2.bedgraph -c 4 -o max > ${sample}_regions_sort_merged.bedgraph

    bedGraphToBigWig ${sample}_regions_sort_merged.bedgraph ${chromSizes} ${sample}_regions.bw
    """
}

process chrom_size {
    container "tdnipper/bioinformatics:star"

    debug = true

    publishDir "${projectDir}/output/test", mode: "symlink", pattern: "hg38.chrom.sizes"

    input: 
    val(status)

    output:
    path("hg38.chrom.sizes"), emit: chromFile

    script:
    """
    samtools faidx ${params.hybrid_genome_file}
    cut -f 1,2 ${params.hybrid_genome_file}.fai > hg38.chrom.sizes
    """
}

// process get_xlinks {
//     container "tdnipper/bioinformatics:bedtools"

//     publishDir "${projectDir}/output/xlinks", mode: "symlink", pattern: "*.bedgraph"

//     input:
//     tuple val(sample), path(reads)
// }

process bed_to_bedgraph {
    container "tdnipper/bioinformatics:bedtools"

    publishDir "${projectDir}/output/results/pureclip/bedgraph"

    input:
    tuple val(sample), path(reads)

    output:

    script:
    
}