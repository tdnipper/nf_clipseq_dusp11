include {trim} from "./modules/fastp/main.nf"
include {fastqc} from "./modules/fastqc/main.nf"
include {bbduk} from "./modules/bbduk/main.nf"
include {star_index} from "./modules/star/index/main.nf"
include {star_align} from "./modules/star/align/main.nf"
include {call_peaks} from "./modules/pureclip/main.nf"
include {dedup} from "./modules/umi-tools/main.nf"
include {index} from "./modules/umi-tools/main.nf"
include {combine_control_bam} from "./modules/pureclip/main.nf"
// include {bed_to_bigwig} from "./modules/bedtools/main.nf"
// include {chrom_size} from "./modules/bedtools/main.nf"
include {get_xlinks} from "./modules/bedtools/main.nf"
include {paraclu_call_peaks} from "./modules/paraclu/main.nf"
raw_reads = Channel.fromPath(params.raw_reads)

callers = params.peakcaller.split(",").collect()

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
    // deduplicated.branch { 
    // control: it[0].contains("Igg")
    // experimental: !it[0].contains("Igg") 
    // }
    // .set { result }
    // dedupIndexed = index(result.experimental)
    dedupIndexed = index(deduplicated)
    ch_xlinks = get_xlinks(star.sorted_bam).bed
    // inputList = result.control.map { it[1] }.collect()
    // inputClip = combine_control_bam(inputList).combined_bam
    if ("paraclu" in callers) {
        paraclu_peaks = paraclu_call_peaks(ch_xlinks)
    }
    if ("pureclip" in callers) {
        peaks = call_peaks(dedupIndexed)
    }
    // sizeFile = chrom_size(peaks.status.collect()).chromFile
    // bedgraph = bed_to_bigwig(peaks.peaks, sizeFile)
}