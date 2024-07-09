include {trim} from "./modules/fastp/main.nf"
include {fastqc} from "./modules/fastqc/main.nf"
include {bbduk} from "./modules/bbduk/main.nf"
include {star_index} from "./modules/star/index/main.nf"
include {star_align} from "./modules/star/align/main.nf"
include {call_peaks} from "./modules/pureclip/main.nf"
include {dedup} from "./modules/umi-tools/main.nf"
include {sort} from "./modules/umi-tools/main.nf"
include {call_peaks} from "./modules/pureclip/main.nf"
raw_reads = Channel.fromPath(params.raw_reads)

process reads_with_samplename{
    // This process takes a channel of filepaths and returns a channel of tuple (samplename), (filepath) for downstream ease of naming
    input: 
    path (raw_reads)

    output:
    tuple val(sample), path(raw_reads), emit: reads

    script:
        sample = raw_reads.baseName.replaceAll(/\.fastq$/, "")
        """
        echo ${sample}
        """
}


workflow {
    reads = reads_with_samplename(raw_reads)
    fastqc(reads)
    trimmed = trim(reads).reads
    ribodepleted = bbduk(trimmed).ribodepleted_reads
    starIndex = star_index(ribodepleted.collect())
    star = star_align(ribodepleted, starIndex.index)
    deduplicated = dedup(star.sorted_bam).reads
    dedupSorted = sort(deduplicated).reads
    deduplicated.branch { 
        control: it[0].contains("Igg")
        experimental: !it[0].contains("Igg") 
        }
        .set { result }
    peaksCalled = 
}