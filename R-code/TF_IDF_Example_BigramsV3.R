library(ngram)
library(tm)
library(data.table)
library(gofastr)
library(tidyverse)
library(birankr)

path2="~/Projects/ProjectDrDuttaPersonal/Anchal/name_token_data.csv"
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
setwd("~/Projects/ProjectDrDuttaPersonal/R_Scripts")
write.table(inspect(tdmSparseTermsRemoved[1:27,1:36501]), file="mymatrix.txt")

#Perform Birank
df=inspect(tdmSparseTermsRemoved[1:27,1:36501])
df = as.data.frame(df, row.names=TRUE)
br_birank(df)
df2 <- data.table(
  patient_id = sample(x = 1:10000, size = 10000, replace = TRUE),
  provider_id = sample(x = 1:5000, size = 10000, replace = TRUE)
)
br_birank(df2)
#tdmMatrix <- as.matrix(tdmSparseTermsRemoved)

#output_dtm()
#write.csv(tdmMatrix, 'myfile.csv')
#write.table(tdmMatrix, file="mymatrix.txt")
#dfTDM=as.data.frame(inspect(tdmSparseTermsRemoved[1:27,1:36501]))
#tdmMatrix

