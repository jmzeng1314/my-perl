## R code to get the gene structure information 
## R code to get the gene structure information 
## R code to get the gene structure information 
suppressMessages(library(ggplot2))
suppressMessages(library(RMySQL))
con <- dbConnect(MySQL(), host="127.0.0.1", port=3306, user="root", password="11111111")
dbSendQuery(con, "USE test")
gene='SOX10'
#gene='DDX11L11'
if (T){
  query=paste("select * from hg19_gtf where gene_type='protein_coding' and gene_name=",shQuote(gene),sep="")
  structure=dbGetQuery(con,query)
  tmp_min=min(c(structure$start,structure$end))
  structure$new_start=structure$start-tmp_min
  structure$new_end=structure$end-tmp_min
  tmp_max=max(c(structure$new_start,structure$new_end))
  num_transcripts=nrow(structure[structure$record=='transcript',])
  tmp_color=rainbow(num_transcripts)
  x=1:tmp_max;y=rep(num_transcripts,length(x))
  #x=10000:17000;y=rep(num_transcripts,length(x))
  plot(x,y,type = 'n',xlab='',ylab = '',ylim = c(0,num_transcripts+1))
  title(main = gene,sub = paste("chr",tmp$chr,":",tmp$start,"-",tmp$end,sep=""))
  j=0;
  tmp_legend=c()
  for (i in 1:nrow(structure)){
    tmp=structure[i,]
    if(tmp$record == 'transcript'){
      j=j+1
      tmp_legend=c(tmp_legend,paste("chr",tmp$chr,":",tmp$start,"-",tmp$end,sep=""))
    }
    if(tmp$record == 'exon') lines(c(tmp$new_start,tmp$new_end),c(j,j),col=tmp_color[j],lwd=4)
  }
 # legend('topleft',legend=tmp_legend,lty=1,lwd = 4,col = tmp_color);

}