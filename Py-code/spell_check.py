import os
import time
import pkg_resources
from symspellpy.symspellpy import SymSpell
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
import string
import re
import os
import time
import pandas as pd
# Set max_dictionary_edit_distance to increase lenght of spelling correction
sym_spell = SymSpell(max_dictionary_edit_distance=3, prefix_length=4)
dictionary_path = pkg_resources.resource_filename(
    "symspellpy", "frequency_dictionary_en_82_765.txt")
sym_spell.load_dictionary(dictionary_path, term_index=0, count_index=1)
tic= time.time()
directory = r'TestData'
for entry in os.scandir(directory):
    if (entry.path.endswith(".txt")):
        a_file = open(entry.path, "r")
        new_path = os.path.join(r"TestData\Temp", ((entry.path).split('\\')[1]))
        copy = open(new_path, "w+",encoding='utf-8')
        for line in a_file:
            result = sym_spell.word_segmentation(line)
            copy.write(format(result.corrected_string)+'\n')
        copy.close()
        a_file.close()
    toc = time.time()   
print("Time "+new_path+": " +str(toc-tic))