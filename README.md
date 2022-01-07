# QuantSeq-3-mRNA-FWD-pipeline


### RNA analysis pipeline for Lexogen QuantSeq 3'mRNA FWD kit.
### I mainly refer to https://www.lexogen.com/quantseq-data-analysis/.

***
### You should make STARindex with sjdbHangover=74 option before analysis.
```bash
STAR --runMode genomeGenerate --genomeDir /dir/to/save/index --genomeFastaFiles /genome/fasta --sjdbGTFfile /annotation/gtf --sjdbHangover 74
```
