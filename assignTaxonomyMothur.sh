#!/bin/bash

### Set how to define arguments :

while getopts ":s:r:t:" opt
   do
     case $opt in
        s ) fasta=$OPTARG;;
        r ) reference=$OPTARG;;
	t ) taxonomy=$OPTARG;;

     esac
done

### ERROR 

if [ $# -eq 0 ]
then

echo -e "	[ERROR] You need to define arguments such as shown below!!! [ERROR] \n
	./assignTaxonomyMothur.sh -seq (your sequences to  assign in fasta format) -ref (reference fasta file compatible with mothur command) -tax (taxonomy .tax file compatible with mothur)\n"

exit 0
fi

### Output files preparation :
# to store outputs same path as the input reference file (-r) :
OutPath=$(echo "$fasta" | rev | cut -d"/" -f2- | rev)

# to store outputs same path as the input reference file (-r) :
OutRefPath=$(echo "$reference" | rev | cut -d"/" -f2- | rev)

# to name outputs files with radical from reference file (-r) :
OutName=$(echo "$fasta" | rev | cut -d"/" -f1 | rev | cut -d"." -f1)

### assign taxonomy to reads :
echo -e "\nAssigning taxonomy with cutoff=80 ; 10000 iterations ...\n"

mothur "#classify.seqs(fasta=$fasta,reference=$reference,taxonomy=$taxonomy,cutoff=80,iters=10000)" 1> fmr.output_classif.txt

# delete useless files :
rm fmr.output_classif.txt
rm $OutPath/*.wang.tax.summary
rm mothur.*.logfile

### reformat output to be then uploaded on R
# keep raw output to store infos in parenthesis if you want to check it :
cp $OutPath/*.wang.taxonomy $OutPath/$OutName.raw_mothur_assignation_output

# remove parenthesis and their content :
sed -i "s/([^)]*)//g" $OutPath/*.wang.taxonomy

# replace tabulation by semi-column :
sed -i "s/\t/;/g" $OutPath/*wang.taxonomy

# replace underscore by spaces :
sed -i "s/_/ /g" $OutPath/*wang.taxonomy

# remove last ; in each line :
sed -i "s/.$//g" $OutPath/*wang.taxonomy

# rename by something universal/easier to then load on R :
mv $OutPath/*wang.taxonomy $OutPath/assignation_table.txt

# remove useless files :
rm $OutRefPath/*.8mer
rm $OutRefPath/*.8mer.prob
rm $OutRefPath/*.8mer.numNonZero
rm $OutRefPath/*.tree.sum
rm $OutRefPath/*.tree.train
