process trim {
    container "tdnipper/bioinformatics:fastp"

    publishDir "${projectDir}/output/logs/fastp", pattern: "*.json", mode: "symlink"
    publishDir "${projectDir}/output/logs/fastp", pattern: "*.html", mode: "symlink"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path(reads), emit: reads
    path ("*.json"), emit: logs_json
    path ("*.html"), emit: logs_html

    script:
    """
    fastp -i ${reads} -o ${sample}_trimmed.fastq.gz -j ${sample}.json -h ${sample}.html -l 25 -q 20
    """
}