#################################
# Loading necessary libraries
#################################

# Loading Pandas and Numpy
import pandas as pd
import numpy as np

# Loading NLTK Natural language processing toolkit library
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
from nltk.stem import WordNetLemmatizer

# Loading Feature Extraction tools and Libraries
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from sklearn.metrics.pairwise import cosine_similarity
from gensim.models import Word2Vec

# Loading Libraries for Visualization 
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt

# Loading other required Libraries 
import string
import re
import os
import time
import itertools
from collections import Counter


###################################
# Loading and cleaning text files
###################################


tic= time.time()
op_list=[]
lemmatizer = WordNetLemmatizer()
word_count=0
final_word_count = 0
garbel_words = 0
directory = r'final'
all_words=[]
two_syllable = []
three_syllable = []
for entry in os.scandir(directory):
    if (entry.path.endswith(".txt")):
        file = open(entry.path, "rt")
        raw_text = file.read()
        word_count = word_count+len(raw_text.split())
        file.close()

        text =  re.sub(r"\b[a-zA-Z]\b", "", raw_text)

        dict_words = set(nltk.corpus.words.words())

        # split into words
        tokens = word_tokenize(text)

        # convert to lower case
        tokens = [w.lower() for w in tokens]

        # remove punctuation from each word
        table = str.maketrans('', '', string.punctuation)
        stripped = [w.translate(table) for w in tokens]

        # remove remaining tokens that are not alphabetic
        words = [word for word in stripped if word.isalpha()]
        garbel_words = garbel_words +(len(stripped)-len(words))
        
        # lemmatization
        words = [lemmatizer.lemmatize(word) for word in words]
        
        # removing word without meaning
        words = [w for w in words if w.lower() in dict_words or not w.isalpha()]

        # filter out stop words
        stop_words = set(stopwords.words('english'))
        final_words = [w for w in words if not w in stop_words]
        
        # removing interjections
        tagged = nltk.pos_tag(final_words)
        final_list=""
        
        for x in tagged:
            if x[1]!='IN':
                final_list= final_list +" "+x[0]
                all_words.append(x[0])
                if len(x[0])==2:
                    two_syllable.append(x[0])
                elif len(x[0])==3:
                    three_syllable.append(x[0])
        final_word_count= final_word_count+len(final_list.split())
        op_list.append([str(entry.path).split('\\')[1],final_list])

clean_data = pd.DataFrame(op_list, columns = ['File Name', 'Token words'])
toc = time.time()
clean_data.to_csv(r"clean_data.csv")
# print("Time : " +str(toc-tic))
# print("Total Word Count before Cleaning: " +str(word_count))
# print("Average Word Count before Cleaning: " +str(word_count/14020))
# print("Total Word Count after Cleaning: "+str(final_word_count))
# print("Average Word Count after Cleaning: "+str(final_word_count/14020))
# print("Garbel Words Count: "+str(garbel_words))
# print("Two syllable Words Count: "+str(len(two_syllable)))
# print("Three syllable Words Count: "+str(len(three_syllable)))
# clean_data.head()

pd.DataFrame(two_syllable, columns = ['Words']).to_csv(r"two_syllable.csv")
pd.DataFrame(three_syllable, columns = ['Words']).to_csv(r"three_syllable.csv")

pd.DataFrame(set(two_syllable), columns = ['Words']).to_csv(r"unique_two_syllable.csv")
pd.DataFrame(set(three_syllable), columns = ['Words']).to_csv(r"unique_three_syllable.csv")

countall = Counter(all_words)
all_word = pd.DataFrame(set(all_words), columns = ['Words'])
all_word['Count']= all_word['Words'].map(countall)
all_word.to_csv(r"Word Count.csv")
all_word.head()

counttwo = Counter(two_syllable)
two_word = pd.DataFrame(set(two_syllable), columns = ['Words'])
two_word['Count']= two_word['Words'].map(counttwo)
two_word.to_csv(r"Word Count Two.csv")
two_word.head()

countthree = Counter(three_syllable)
three_word = pd.DataFrame(set(three_syllable), columns = ['Words'])
three_word['Count']= three_word['Words'].map(countthree)
three_word.to_csv(r"Word Count Three.csv")
three_word.head()


###############################
# Creating person-name corpus
###############################


person_doc=pd.read_csv('All_peopleAndTheirDocumets.csv')
person_doc.head()


# creating dictionay with names as key to map token words from each file
name_dict = {}
for index, row in person_doc.iterrows():
    name_dict[row['Person Name']]=''

# mapping person name to each associated file
data_dict={}
name_freq=[]
for index, row in person_doc.iterrows():
    file_list = row['Document Name'].split('.txt')
    file_list = [fl.strip(' ') for fl in file_list]
    file_list=list(set(file_list))
    name_freq.append([row['Person Name'],len(file_list)])
    if (len(file_list)>1):
        for i in file_list:
            if (str(i)+".txt") in data_dict:
                data_dict[(str(i)+".txt")].append(row['Person Name'])
            else:
                data_dict[(str(i)+".txt")] = [row['Person Name']]
    else:
        data_dict[row['Document Name']] = [row['Person Name']]
clean_data['Name List']= clean_data['File Name'].map(data_dict)
clean_data.head()


# frequecy of occurance of names
freq_df = pd.DataFrame(name_freq, columns = ['Name', 'Freq'])
sort_by_freq = freq_df.sort_values('Freq',ascending=False)
sort_by_freq.head(5)

clean_data.isna().sum()

# removing files with no name associated
clean_data = clean_data.dropna()
clean_data.shape

# populating dictionay with names as key and token words as values
for index, row in clean_data.iterrows():
    for i in row['Name List']:
        name_dict[i] = name_dict[i]+" "+str(row['Token words'])
name_token_data = pd.DataFrame(list(name_dict.items())) 
name_token_data.columns = ['Person Name', 'Token Words']
name_token_data.to_csv(r"name_token_data.csv")

##################################################
## Filter words with less frequency of occurance
##################################################

three_word_filtered = three_word[three_word['Count'] <= three_word['Count'].mean()] 
two_word_filtered = two_word[two_word['Count'] <= two_word['Count'].mean()] 
all_word_filtered = all_word[all_word['Count'] <= 10]

# print("Number of words with frequency less than 10 "+str(len(all_word_filtered)))
# print("Number of 3 syllable words with frequency less than avg "+str(len(three_word_filtered['Words'].tolist())))
# print("Number of 2 syllable words with frequency less than avg "+str(len(two_word_filtered['Words'].tolist())))

words_filter_list = all_word_filtered['Words'].tolist()
words_filter_list.extend(three_word_filtered['Words'].tolist())
words_filter_list.extend(two_word_filtered['Words'].tolist())
words_filter_list = list(set(words_filter_list))

# print("Number of Unique words in Corpus:" +str(all_word.shape[0])) 
# 20945
# print("Number of Unique words in Corpus after cleaning:" +str(all_word.shape[0]-len(words_filter_list)))
# 11675

output_list=[]
total_count=0
filter_count=0
for index, row in name_token_data.iterrows():
    t=row['Token Words'].split()
    total_count+=len(t)
    filter_word = [w for w in t if not w in words_filter_list]
    filter_count+=len(filter_word)
    filter_string=''
    for x in filter_word:
        filter_string = filter_string +" "+ str(x)
    output_list.append([row['Person Name'],filter_string])
output_data = pd.DataFrame(output_list, columns = ['Person Name', 'Token words'])
print("Total Word Count Before: "+str(total_count))
print("Total Word Count After: "+str(filter_count))
output_data.head()
output_data.to_csv(r"final_data.csv")

name_list = name_token_data['Person Name'].tolist()
name_list
name_len =[]
name_word_count = []
for i in name_list:
    name_len.append(len(i))
    name_word_count.append((len(i.split(" "))))

print("Length of Names")
print("Min: "+str(np.min(name_len)))
print("Max: "+str(np.max(name_len)))
print("Mean: "+str(np.mean(name_len)))
print("Median: "+str(np.median(name_len)))
print("Standard deviation: "+str(np.std(name_len)))


# removing duplicate names

person_list = name_token_data['Person Name'].tolist()
range_dict = {}
for i in range(0,11):
    range_dict[i]=[]

similarity_matrix=[]
similarity_list=[]
for i in range(0,len(person_list)):
    temp=[]
    try:
        person_list[i+1]
        for j in range(0, len(person_list)):
            similarity = round(SequenceMatcher(None, person_list[i], person_list[j]).ratio(),3)
            temp.append(similarity)
            range_val=int(similarity*10)
            range_dict[range_val].append(similarity)
        similarity_matrix.append(temp)
    except:
        pass

# filtering names with cosine similarity more than 0.8
similar_names = [[ix,iy,i] for ix, row in enumerate(similarity_matrix) for iy, i in enumerate(row) if i > 0.8 and ix!=iy]
similar_name_list=[]
for i in similar_names:
    similar_name_list.append([person_doc["Person Name"][i[0]],person_doc["Person Name"][i[1]],i[2],person_doc["Document Name"][i[0]],person_doc["Document Name"][i[1]]])
    
name_df = pd.DataFrame(similar_name_list, columns = ['Name 1','Name 2','Similarity','Doc1','Doc2'])
name_df.to_csv(r"SimilarNameList.csv")

similarity_list = pd.read_csv('SimilarNameDocList8.csv')
similarity_list.shape

count=0
name_list=[]
for index, row in similarity_list.iterrows():
    doc1 = row['Doc1'].split('.txt')
    doc1 = [d1.strip(' ') for d1 in doc1]
    doc1=list(set(doc1))
    doc1.remove("") 
    doc2 = row['Doc2'].split('.txt')
    doc2 = [d2.strip(' ') for d2 in doc2]
    doc2=list(set(doc2))
    doc2.remove("") 
    common = list(set(doc1) & set(doc2)) 
    if (common!=[] or common==['']):
        count=count+1
        name_list.append([row['Name 1'],row['Name 2']])
        similarity_list = similarity_list.drop([index])
print(count)
#899

duplicate_name = pd.DataFrame(name_list)
duplicate_name=duplicate_name.rename(columns={0: "Name 1", 1: "Name 2"})
duplicate_name.to_csv(r"duplicate_name.csv")

for index, row in duplicate_name.iterrows():
    doc1 = person_doc.loc[(person_doc['Person Name'] == row['Name 1'])]['Document Name'][person_doc.index[(person_doc['Person Name'] == row['Name 1'])][0]]
    doc2 = person_doc.loc[(person_doc['Person Name'] == row['Name 2'])]['Document Name'][person_doc.index[(person_doc['Person Name'] == row['Name 2'])][0]]
    person_doc.loc[(person_doc['Person Name'] == row['Name 1']),'Document Name']= doc1+" "+doc2
for index, row in duplicate_name.iterrows():    
    person_doc.drop(person_doc[person_doc['Person Name'] == row['Name 2']].index, inplace = True) 
person_doc.to_csv(r"AllPeopleDocumentUpdated.csv")