process paraclu_call_peaks {
    container "tdnipper/bioinformatics:paraclu"

    debug = true

    publishDir "${projectDir}/output/results/paraclu/bed", mode: "symlink", pattern: "*.bed.gz"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("*.bed.gz"), emit: peaks

    script:
    min_value = params.min_value
    min_density_increase = params.min_density_increase
    max_cluster_length = params.max_cluster_length
    """
    pigz -d -c ${reads} > ${sample}.bed
    awk '{OFS = "\t"}{print \$1, \$6, \$3, \$5}' | \\
    sort -k1,1 -k2,2 -k3,3n > paraclu_input.tsv

    paraclu ${min_value} paraclu_input.tsv | \\
    paraclu-cut -d ${min_density_increase} -l ${max_cluster_length} | \\
    awk '{OFS = "\t"}{print \$1, \$3-1, \$4, ".", \$6, \$2}' | \\
    bedtools sort | \\
    pigz > ${sample}.${min_value}_${max_cluster_length}nt_${min_density_increase}.peaks.bed.gz
    """
}