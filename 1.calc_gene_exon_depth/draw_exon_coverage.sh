for i in *txt
do
echo $i
Rscript draw_exon_coverage.R  $i
done 
