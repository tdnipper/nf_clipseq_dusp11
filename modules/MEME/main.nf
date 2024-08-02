process get_streme_motifs {
    container "memesuite/memesuite:5.5.5"

    publishDir "${projectDir}/output/results/streme", mode: 'symlink', pattern: "*"

    input:
    tuple val(sample), path(fasta)

    output:
    path("*")

    script:
    control_file = "${projectDir}/modules/MEME/hybrid_transcripts.fa"
    """
    streme --rna --oc ${sample} --p ${fasta}
    """
}

process interleave_for_streme {
    container "quay.io/biocontainers/bbmap:38.22--h470a237_0"

    input:
    tuple val(sample), path(fasta)
    val(signal)

    output:
    tuple val(sample), path("*.interleaved.fasta")

    script:
    """
    reformat.sh in=${fasta[0]} in2=${fasta[1]} out=${sample}.interleaved.fasta
    """
}

process subsample_for_streme {
    container "memesuite/memesuite:5.5.5"

    input:
    tuple val(sample), path(interleaved)

    output:
    tuple val(sample), path("*.subsampled.fasta")

    script:
    """
    fasta-subsample ${interleaved} 100000 > ${sample}.subsampled.fasta
    """
}