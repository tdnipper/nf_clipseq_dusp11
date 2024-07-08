process trim {
    container "tdnipper/bioinformatics:fastp"

    publishDir "${projectDir}/output/logs/fastp", pattern: "*.json", mode: "symlink"
    publishDir "${projectDir}/output/logs/fastp", pattern: "*.html", mode: "symlink"

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path(reads), emit: reads

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${sample}_R1_trimmed.fastq.gz -O ${sample}_R2_trimmed.fastq.gz -j ${sample}.json -h ${sample}.html -l 25 -q 20
    """
}