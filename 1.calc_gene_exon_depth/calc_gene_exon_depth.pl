#############################################
#Author: Jianming Zeng
#email:  jmzeng1314@163.com
#Creat Time: Mon Feb  1 10:13:18 EST 2016 
#URL1:    http://www.bio-info-trainee.com/
#URL2:    https://github.com/jmzeng1314
#Eli Lilly and Company (CHINA LCRDC)
#############################################
#use strict;
#use warnings;
use Getopt::Long;
#View each exon covarage by giving a gene symbol 

#my $refgene='/home/jmzeng/ref-database/hg19_refGene.txt';
#my $bam='/home/jmzeng/aws_data/lichun/trash/L.bam';
#my $symbol='DMD';
my $help=undef;
my $usage=<<USAGE;
#Info:   #View each exon covarage by giving a gene symbol 
#Usage:  perl calc_gene_exon_depth.pl  -s TP53 -r hg19_refGene.txt -b L.bam
   
     -s/--symbol  which gene do you want to search ((e.g, DMD/TP53/EGFR))
     -r/--refgene where is the refgene file(default:hg19_refGene.txt )
     -b/--bam     where is the bam file (default )
     -h/--help    print out this help
##################################################################
USAGE

GetOptions("s|symbol=s"=>\$symbol,
		   "r|refgene=s"=>\$refgene,
		   "b|bam=s"=>\$bam,
		   "h|help"=>\$help);	
		   
#Start parameter checking

# we can't put $ sign in the << charactor
my $R_code=<<R_code;
if("ggplot2" %in% rownames(installed.packages()) == FALSE) {install.packages("ggplot2")}
library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
file=args[1]
outpng=sub(".txt",".png",file)
dat=read.table(file)
names(dat)=c('pos','depth','exon')
png(outpng,width = 1080, height = 1080)
p=ggplot(data=dat,aes(x=pos,y=depth,color=exon))+geom_line()
p=p+facet_wrap(~exon,scales="free_x")
p=p+theme(legend.position='none')
print(p)
dev.off()
R_code

#check whether 	All necessary files exists or not !
if(! -e $refgene){
	print "we can't find the refGene.txt \n\n";
	#http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/knownGene.txt.gz
	print $usage;
	exit(1);
}
if(! -e $bam){
	print "we can't find the bam files \n\n";
	print $usage;
	exit(1);
}
if(! -e "draw_exon_coverage.R"){
	open FH,">draw_exon_coverage.R";
	print FH $R_code;
	close FH;
}
=pod
# check whether samtools in your $PATH
unless(which('samtools')){
	print <<samtools;
	
samtools in not in your \$PATH, make sure you have samtools installed in your PC.
Visit http://samtools.sourceforge.net/ to see how to intall it.
samtools
	exit (1);
}
# check whether samtools in your $PATH
unless(which('R')){
	print <<R;
	
R in not in your \$PATH, make sure you have R installed in your PC.
Visit https://www.r-project.org/ to see how to intall it.
R
	exit (1);
}
=cut
#End parameter checking
###########################

#Main program
print "[",scalar(localtime),"] started \n";

open FH,$refgene;
while(<FH>){
	my @F=split;
	push @NM_list,$_ if $F[12] eq $symbol;
}
close FH;
my $tmp_N=scalar(@NM_list);
if ($tmp_N>0){
	print "we have find $tmp_N mRNA(refseq database) for the gene you give !\n"
}
else{
	print "we can't find any information for $symbol in $refgene \n";
	exit(1);
}
undef $tmp_N;
foreach (@NM_list){
	my (undef,$NM_id,$chr,$strand,$start,$end,undef,undef,
		$exon_n,$up,$down,undef,$symbol,undef,undef,undef)=split;
	open FH,">$symbol.$NM_id.txt";
	my @pos=split/,/,"$up,$down";
	#exit;
	undef %h_depth;
	foreach ($start..$end){
		$h_depth{$_}=0;
	}
	$command="samtools depth -r $chr:$start-$end $bam ";
	#print "$command\n";
	my @depths=`$command`;
	foreach (@depths){
		my @F=split;
		$h_depth{$F[1]}=$F[2];
	}
	#print "$_\t$h_depth{$_}\t$group{$_}\n" foreach $start..$end;

	my @pos=sort @pos;
	#print join",",@pos;
	undef %group;
	foreach my $i (2..$#pos){
		next if $i%2==1;		
		foreach my $j ($pos[$i-1]..$pos[$i]){
			my $n=$j-$pos[$i-1]+1;
			if ($strand eq '+'){
				$exon=$i/2;
			}else{
				$exon=$exon_n-$i/2+1;
			}
			#my $label="exon:$exon:$chr:$pos[$i-1]-$pos[$i]";
			my $label="exon:$exon";
			print FH "$n\t$h_depth{$j}\t$label\n";
		}
	}
	close FH;
	my $cmd="Rscript draw_exon_coverage.R $symbol.$NM_id.txt";
	#print $cmd."\n";
	system($cmd)
}
#system("mkdir $symbol");
#system("mv $symbol.* $symbol");
print "[",scalar(localtime),"] Finished\n";

