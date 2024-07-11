process multiqc {
    container "multiqc/multiqc"

    publishDir "${projectDir}/output/logs/multiqc", mode: "symlink"

    input:
    val(status)

    output:
    path(".html"), emit: report

    script:
    """
    multiqc ${projectDir}/output
    """
}