###usage::perl gtf2mysql_format.pl gencode.v7.annotation_goodContig.gtf >hg19_gtf2mysql
###http://www.broadinstitute.org/cancer/cga/rnaseqc_download
while(<>){
	s/\"//g;
	undef %h;
	next if /^#/;
	my($chr,$source,$record,$start,$end,undef,$strand,undef,$info)=split/\t/;
	foreach (split/;/,$info){
		my($tag,$value)=split;
		$h{$tag}=$value;
	}
	print join("\t",$h{'gene_name'},$h{'transcript_name'},$record,$chr,$start,$end,$source,$strand,
					$h{'gene_id'},$h{'transcript_id'},$h{'gene_status'},$h{'gene_type'},$h{'transcript_type'},$h{'transcript_status'}
	)."\n";
}