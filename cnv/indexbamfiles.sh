for i in *.bam
do
  samtools index $i
  samtools view $i > $i.out
done
