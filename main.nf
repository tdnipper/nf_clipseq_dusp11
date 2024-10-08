include {trim} from "./modules/fastp/main.nf"
include {fastqc} from "./modules/fastqc/main.nf"
include {bbduk} from "./modules/bbduk/main.nf"
include {star_index} from "./modules/star/index/main.nf"
include {star_align} from "./modules/star/align/main.nf"
include {call_peaks} from "./modules/pureclip/main.nf"
include {dedup} from "./modules/umi-tools/main.nf"
include {index} from "./modules/umi-tools/main.nf"
include {combine_control_bam} from "./modules/pureclip/main.nf"
include {get_xlinks} from "./modules/bedtools/main.nf"
include {paraclu_call_peaks} from "./modules/paraclu/main.nf"
include {get_segments} from "./modules/icount/main.nf"
include {icount_call_peaks} from "./modules/icount/main.nf"
include {clipper_bedfile} from "./modules/clipper/main.nf"
include {clipper_call_peaks} from "./modules/clipper/main.nf"
include {interleave_for_streme} from "./modules/MEME/main.nf"
include {subsample_for_streme} from "./modules/MEME/main.nf"
include {get_streme_motifs} from "./modules/MEME/main.nf"
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
    
    deduplicated = dedup(star.sorted_bam, star.sorted_bam.collect()).reads
    dedupIndexed = index(deduplicated).reads
    
    ch_xlinks = get_xlinks(dedupIndexed).bed
    if ("paraclu" in callers) {
        paraclu_peaks = paraclu_call_peaks(ch_xlinks)
    }
    if ("pureclip" in callers) {
        peaks = call_peaks(dedupIndexed)
    }
    if ("iCount" in callers) {
        icount_segments_ch = get_segments(ch_xlinks.collect())
        icount_peaks = icount_call_peaks(ch_xlinks, icount_segments_ch)
    }
    if ("clipper" in callers) {
        clipper_peaks = clipper_call_peaks(dedupIndexed)
    }
    
    ch_interleaved = interleave_for_streme(ribodepleted, dedupIndexed.collect())
    control_group = params.control_group
    ch_interleaved.branch {
        control: it[0].contains(control_group)
        experimental: !it[0].contains(control_group)
    }.set { ch_interleaved_split }
    ch_subsampled = subsample_for_streme(ch_interleaved_split.experimental)   
    ch_streme_motifs = get_streme_motifs(ch_subsampled)
}