mkdir -p  ~/tmp/chrX_Y/hg19/
cd  ~/tmp/chrX_Y/hg19/
#conda install -c bioconda bwa
#conda install -c bioconda samtools
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrX.fa.gz; 
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrY.fa.gz; 
gunzip chrX.fa.gz
gunzip chrY.fa.gz
wget https://github.com/jmzeng1314/my-perl/blob/master/2.chrX-chrY/simulate.pl
bwa index chrX.faperl simulate.pl chrY.fa
bwa mem -t 5 -M chrX.fa read*.fa >read.sam
samtools view -bS read.sam >read.bam
samtools flagstat read.bam
samtools sort -@ 5 -o read.sorted.bam  read.bam
samtools view -h -F4  -q 5 read.sorted.bam |samtools view -bS |samtools rmdup -  read.filter.rmdup.bam
samtools index read.filter.rmdup.bam
samtools mpileup -ugf ~/tmp/chrX_Y/hg19/chrX.fa  read.filter.rmdup.bam  |bcftools call -vmO z -o read.bcftools.vcf.gz
