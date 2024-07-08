// Define input files using paths in config params
hybrid_genome_file = file(params.hybrid_genome_file)
myco_genome_file = file(params.myco_genome_file)
process bbsplit_index{
    tag "index"
    tag "decon"

    container "quay.io/biocontainers/bbmap:38.22--h470a237_0"

    input:

    output:
    path "ref/", emit: index, type: "dir"
    script:
    """
    bbsplit.sh ref_nonmyco=${hybrid_genome_file} ref_myco=${myco_genome_file} -Xmx57g
    """
}