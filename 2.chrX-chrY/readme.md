# 从fasta序列里面模拟测序的reads走SNP-calling流程

很简单的一个shell脚本，从UCSC里面单独下载X,Y染色体的fasta序列，写脚本从Y染色体序列里面模拟双端测序的fastqa文件，然后用bwa软件比对到X染色体，作为参考基因组。全部代码如下：

```shell
mkdir -p  ~/tmp/chrX_Y/hg19/
cd  ~/tmp/chrX_Y/hg19/
#conda install -c bioconda bwa
#conda install -c bioconda samtools
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrX.fa.gz; 
wget  http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chrY.fa.gz; 
gunzip chrX.fa.gz
gunzip chrY.fa.gz
wget https://raw.githubusercontent.com/jmzeng1314/my-perl/master/2.chrX-chrY/simulate.pl
bwa index chrX.fa
perl simulate.pl chrY.fa
bwa mem -t 5 -M chrX.fa read*.fa >read.sam
samtools view -bS read.sam >read.bam
samtools flagstat read.bam
samtools sort -@ 5 -o read.sorted.bam  read.bam
samtools view -h -F4  -q 5 read.sorted.bam |samtools view -bS |samtools rmdup -  read.filter.rmdup.bam
samtools index read.filter.rmdup.bam
samtools mpileup -ugf ~/tmp/chrX_Y/hg19/chrX.fa  read.filter.rmdup.bam  |bcftools call -vmO z -o read.bcftools.vcf.gz
```

如果samtools安装的是最新版，上面的代码还可以更简化。

首先下载X,Y染色体的fasta序列，在UCSC上面下载即可。
然后把X染色体构建bwa的索引
接着模拟一个Y染色体的测序数据，模拟的程序很简单,模拟Y染色体的测序片段（PE100，insert400）
最后把模拟测序数据比对到X染色体的参考，统计一下比对结果即可！
**我自己看sam文件也发现真的同源性好高呀，总共就模拟了380万reads，就有120万是百分百比对上了。**
所以对女性个体来说，测序判断比对到Y染色体是再正常不过的了。如果要判断性别，必须要找那些X,Y差异性区段！对男性来说，更是如此！

其中里面有一个perl代码，从Y染色体序列里面模拟双端测序的fastqa文件，需要仔细理解。

```perl
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
```

并不复杂，就十几行代码而已，而且我已经写好了，即使不会写，保证看懂也行，即使看不懂，知道这个代码的用法也行，反正下载地址也给出了。 https://github.com/jmzeng1314/my-perl/blob/master/2.chrX-chrY/simulate.pl 

整个流程得到的文件如下：

```
 985 Jan 26  2017 calling.sh
152M Mar 21  2009 chrX.fa
 399 Jan 25  2017 chrX.fa.amb
  44 Jan 25  2017 chrX.fa.ann
149M Jan 25  2017 chrX.fa.bwt
  23 Jan 26  2017 chrX.fa.fai
 38M Jan 25  2017 chrX.fa.pac
 75M Jan 25  2017 chrX.fa.sa
 58M Mar 21  2009 chrY.fa
209M Jan 25  2017 read1.fa
209M Jan 25  2017 read2.fa
172M Jan 25  2017 read.bam
3.3M Jan 26  2017 read.bcftools.vcf.gz
 50M Jan 26  2017 read.filter.rmdup.bam
225K Jan 26  2017 read.filter.rmdup.bam.bai
668M Jan 25  2017 read.sam
137M Jan 26  2017 read.sorted.bam
209K Jan 26  2017 read.sorted.bam.bai
 429 Jan 25  2017 samtools.stat.out
 479 Jan 25  2017 tmp.pl
 409 Jan 25  2017 tmp.sh
```



