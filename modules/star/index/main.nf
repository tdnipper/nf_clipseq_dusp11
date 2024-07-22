genomeFile = file(params.hybrid_genome_file)
annotationFile = file(params.annotation_file)

process star_index {
    
    container "tdnipper/bioinformatics:star"

    input:
    val(signal)

    output:
    path "star_index/", type: "dir", emit: index

    script:
    """
    STAR --runMode genomeGenerate --runThreadN ${task.cpus} --genomeDir star_index --genomeFastaFiles ${genomeFile} --sjdbGTFfile ${annotationFile} 
    """
    
}