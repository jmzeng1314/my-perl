--mysql code
use test;
drop table  if exists hg19_gtf;
create table hg19_gtf (
    gene_name VARCHAR(30),
    transcript_name VARCHAR(30) ,
    record  VARCHAR(15) NOT NULL ,
    chr VARCHAR(2) NOT NULL ,
    start INT NOT NULL ,
    end INT NOT NULL ,
    source VARCHAR(10) NOT NULL ,
    strand VARCHAR(1) NOT NULL ,
	gene_id VARCHAR(30) NOT NULL ,
    transcript_id VARCHAR(30) NOT NULL ,
	gene_status VARCHAR(30) ,
    gene_type VARCHAR(30)  ,
	transcript_type VARCHAR(30) ,
    transcript_status VARCHAR(30) 
);

--select * from hg19_gtf limit 100;
--select * from hg19_gtf where gene_name='DMD';
--select count(*) from hg19_gtf where gene_name='DMD' and record='start_codon';  --18 start condon
--select count(distinct(transcript_name)) from hg19_gtf where gene_name='DMD' ;  --34 transcript
--select count(distinct(transcript_name)) c ,gene_name from hg19_gtf where record='transcript' group by gene_name  order by c desc;

