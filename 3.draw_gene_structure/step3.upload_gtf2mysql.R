### R code upload a file to mysql table ! :
setwd('D:\\test_analysis\\gtf')
a=read.table("hg19_gtf2mysql",header=F,stringsAsFactors = F)
## connect to mysql database
suppressMessages(library(RMySQL))
con <- dbConnect(MySQL(), host="127.0.0.1", port=3306, user="root", password="11111111")
dbSendQuery(con, "USE test")
## upload file to table hg19_gtf
field='gene_name,transcript_name,record,chr,start,end,source,strand,gene_id,transcript_id,gene_status,gene_type,transcript_type,transcript_status'
names(a)=strsplit(field,",")[[1]]
dbWriteTable(con,"hg19_gtf",a,overwrite =F,append = T, row.names=FALSE,skip = 0)
## do some statistics 
query="select count(distinct(transcript_name)) c ,gene_name from hg19_gtf where record='transcript' group by gene_name  order by c desc;"
stat_t_num=dbGetQuery(con,query)
#hist(stat_t_num[,1])