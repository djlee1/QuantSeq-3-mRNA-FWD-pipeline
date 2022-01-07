SAMPLES, = glob_wildcards('RawFASTQ/{sample}.fastq')
GenomeIndex = "/home/ksk_djlee2104/Reference/Mus_musculus/mm10/Ensembl/STARindex_75bp"
GTFdir = '/home/ksk_djlee2104/Reference/Mus_musculus/mm10/Ensembl/Mus_musculus.GRCm38.98.gtf'
bbdukDir='/home/ksk_djlee2104/dongjoo_lee/tools/bbmap/'


rule all:
    input:
        "featureCounts/featureCounts.txt"


rule raw_fastqc:
    input:
        "RawFASTQ/{sample}.fastq"
    output:
        html="RawFASTQ/fastqc/{sample}_fastqc.html",
        zip="RawFASTQ/fastqc/{sample}_fastqc.zip"
    threads: 12
    shell:
        "/home/storage/packages/init_install_dir/FastQC/fastqc --outdir RawFASTQ/fastqc --threads {threads} {input}"


rule bbduk:
    input:
        fq="RawFASTQ/{sample}.fastq",
	html='RawFASTQ/fastqc/{sample}_fastqc.html'
    output:
        "trimmed/{sample}.fastq"
    shell:
        """cat {input.fq} | {bbdukDir}/bbduk.sh in=stdin.fq out={output} \
           ref={bbdukDir}/resources/polyA.fa.gz,{bbdukDir}/resources/truseq.fa.gz k=13 ktrim=r useshortkmers=t mink=5 qtrim=t trimq=10 minlength=20 int=f"""


rule trimmed_fastqc:
    input:
        "trimmed/{sample}.fastq"
    output:
        html="trimmed/fastqc/{sample}_fastqc.html",
        zip="trimmed/fastqc/{sample}_fastqc.zip"
    threads: 12
    shell:
        "/home/storage/packages/init_install_dir/FastQC/fastqc --outdir trimmed/fastqc --threads {threads} {input}"

rule STAR_align:
    input:
        fq="trimmed/{sample}.fastq",
	html='trimmed/fastqc/{sample}_fastqc.html'
    output:
        "STAR/{sample}.Aligned.sortedByCoord.out.bam"
    threads: 12
    params: 'STAR/{sample}.'
    shell:
        """STAR --runThreadN {threads} --genomeDir {GenomeIndex} --readFilesIn {input.fq} \
                --outFilterType BySJout \
                --outFilterMultimapNmax 20 \
                --alignSJoverhangMin 8 \
                --alignSJDBoverhangMin 1 \
                --outFilterMismatchNmax 999 \
                --outFilterMismatchNoverLmax 0.1 \
                --alignIntronMin 20 \
                --alignIntronMax 1000000 \
                --alignMatesGapMax 1000000 \
                --outSAMattributes NH HI NM MD \
                --outSAMtype BAM SortedByCoordinate \
				--sjdbOverhang 74 \
				--outFileNamePrefix {params}"""


rule featurecounts:
    input:
        expand("STAR/{sample}.Aligned.sortedByCoord.out.bam", sample=SAMPLES)
    output:
        "featureCounts/out.txt"
    threads: 12
    shell:
        "featureCounts -s 1 -T {threads} -a {GTFdir} -o {output} {input} "

rule featurecounts_slim:
	input:
		"featureCounts/out.txt"
	output:
		"featureCounts/featureCounts.txt"
	shell:
		"cat {input} | awk '{{$2=$3=$4=$5=$6=\"\"; print $0}}' | sed '1d' | sed 's/STAR\///g' | sed 's/.Aligned.sortedByCoord.out.bam//g' > {output}"
