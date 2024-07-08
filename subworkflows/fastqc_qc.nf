include {fastqc} from "../modules/fastqc/main.nf"

workflow initial_qc {
    take:
    raw_files

    main:
    qc_ch = fastqc(raw_files)

    emit:
    qc_ch
}