#############################################
#Author: Jianming Zeng
#email:  jmzeng1314@163.com
#Creat Time: 2017-10-12 11:32:45
#URL1:    http://www.bio-info-trainee.com/
#URL2:    https://github.com/jmzeng1314
### CAFS-->SUSTC-->LCRDC-->university of MACAU
#############################################
#use strict;
#use warnings; 

my $usage=<<USAGE;
#Info:   # generate paired-end fasta reads from chrY fasta files.
#Usage:  perl $0 chrY.fa 
This is a small perl script for SNP-calling pipeline, as below:
##################################################################
mkdir -p  ~/tmp/chrX_Y/hg19/
cd  ~/tmp/chrX_Y/hg19/
#conda install -c bioconda bwa
#conda install -c bioconda samtools
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrX.fa.gz; 
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrY.fa.gz; 
gunzip chrX.fa.gz
gunzip chrY.fa.gz
perl $0 chrY.fa 
bwa index chrX.fa
bwa mem -t 5 -M chrX.fa read*.fa >read.sam
samtools view -bS read.sam >read.bam
samtools flagstat read.bam
samtools sort -@ 5 -o read.sorted.bam  read.bam
samtools view -h -F4  -q 5 read.sorted.bam |samtools view -bS |samtools rmdup -  read.filter.rmdup.bam
samtools index read.filter.rmdup.bam
samtools mpileup -ugf ~/tmp/chrX_Y/hg19/chrX.fa  read.filter.rmdup.bam  |bcftools call -vmO z -o read.bcftools.vcf.gz
##################################################################
USAGE

die $usage if @ARGV ne 1; 
while(<>){
chomp;
$chrY.=uc $_;
}
$j=0;
open FH_L,">read1.fa";
open FH_R,">read2.fa";
foreach (1..4){
	for ($i=600;$i<(length($chrY)-600);$i = $i+50+int(rand(10))){
		$up = substr($chrY,$i,100);
		$down=substr($chrY,$i+400,100);
		next unless $up=~/[ATCG]/;
		next unless $down=~/[ATCG]/;
		$down=reverse $down;
		$down=~tr/ATCG/TAGC/;
		$j++;
		print FH_L ">read_$j/1\n";
		print FH_L "$up\n";
		print FH_R ">read_$j/2\n";
		print FH_R "$down\n";
	}
}
close FH_L;
close FH_R;
