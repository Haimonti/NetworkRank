library(ngram)
library(tm)
library(data.table)
library(gofastr)
library(tidyverse)
library(birankr)

path2="/media/sean/easystore/ProjectDrDuttaPersonal/Anchal/name_token_data.csv"
x = read.csv(path2, header = TRUE)
names(x) = c("num","doc_id","text")
data_corpus2 = VCorpus(DataframeSource(x))

myStopwords = c(stopwords())

data_corpus = tm_map(data_corpus2, content_transformer(tolower))
data_corpus = tm_map(data_corpus2, stripWhitespace)
data_corpus = tm_map(data_corpus2, stemDocument)

BigramTokenizer =
  function(x)
    unlist(lapply(ngrams(words(x), 2), paste, collapse=" "), use.names=FALSE)
tdm = TermDocumentMatrix(data_corpus2, control=list( weighting = function(x) weightTfIdf(x, normalize = FALSE), tokenize=BigramTokenizer))
tdmSparseTermsRemoved = removeSparseTerms(tdm, 0.95)
#remove(tdm, data_corpus, data_corpus2,x)
tdmSparseTermsRemoved

#ap_td %>%cast_dfm(term, document, count)

inspect(tdmSparseTermsRemoved[1:27,1:36501])
setwd("/media/sean/easystore/ProjectDrDuttaPersonal/R_Scripts")
write.table(inspect(tdmSparseTermsRemoved[1:27,1:36501]), file="mymatrix.txt")

#READ IN TABLE
setwd("/media/sean/easystore/ProjectDrDuttaPersonal/R_Scripts")
file="mymatrix.txt"
tbl_names=read.table(file, nrows=1, header = FALSE, sep = " ", dec = ".")
tbl=read.table(file, skip=1, header = FALSE, sep = " ", dec = ".")

lst_names=as.list(tbl_names)
lst_names=prepend(lst_names,"N-Gram")
colnames(tbl)=c(lst_names)

write.table(tbl, file="mymatrixfinal.txt")

#Now we need to create ID's
df_tbl=as.data.frame(tbl)

df_tbl[,-1] = (df_tbl[,-1] != 0)*1
df_tbl
lst_colnames=rownames(df_tbl)
counter = 0
lst_rownames=list()
for (i in colnames(df_tbl)){
  if(i != "N-Gram"){
    counter = counter + 1
    print(df_tbl[[i]])
    rowname="V"+as.String(lst_colnames[counter])
    assign(rowname,df_tbl[[i]])
    lst_rownames[counter]<-rowname
  }
}
rm(tbl, tbl_names, i, lst_colnames, counter)
lst_names[1]<- NULL
for (rowname in lst_rownames){
  #print("ROW: "+as.String(rowname))
  counter=0
  for (val in get(eval(rowname))){
    counter=counter+1
    if(val == 1){
      print(as.String(lst_names[counter])+":"+as.String(rowname))
    }
  }
}


#Perform Birank
#df=inspect(tdmSparseTermsRemoved[1:27,1:36501])

#rownames(df[1:10,1:10])
#colnames(df[1:10,1:10])

#TEST
#Extract the ngram names
br_birank(df)
df2 <- data.table(
  patient_id = sample(x = 1:10000, size = 10000, replace = TRUE),
  provider_id = sample(x = 1:5000, size = 10000, replace = TRUE)
)
br_birank(df2)

