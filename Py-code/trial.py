import requests
import pandas as pd
import requests

listX = []
listY = []
finalListX = []
count = 0
output = ''

def get_image_urls(url, items=[]):
    params = {"fo": "json", "c": 100, "at": "results,pagination"}
    call = requests.get(url, params=params)
    data = call.json()
    results = data['results']
    for result in results:
        if "collection" not in result.get("original_format") and "web page" not in result.get("original_format"):
            if result.get("image_url"):
                item = result.get("image_url")[-1]
                items.append(item)
    if data["pagination"]["next"] is not None:
        next_url = data["pagination"]["next"]
        get_image_urls(next_url, items)
        
    return items

image_urls = get_image_urls("https://www.loc.gov/collections/frederick-douglass-newspapers/", items=[])
image_urls = image_urls[0:137]

for j in image_urls:

    x = j.split('full')
    x1 = x[0]
    url = x1.split('iiif')
    m = url[1]
    listX.append(m)

for j in listX:
    listY.append(j)
    for i in range(3):
        y = str(int(j[-2]) + 1)
        j = j[:-2] + y + j[int(-2 + 1)]
        listY.append(j)

for i in listY:
    i = i.replace(':','/')
    i = i[0:-1]
    finalLink = 'https://tile.loc.gov/text-services/word-coordinates-service?segment=' + str(i) + '.xml&format=alto_xml&full_text=1'
    finalListX.append(finalLink)

for i in finalListX:
    count = count + 1
    r = requests.get(str(i))
    textFile = r.text
    textFile = textFile.replace('\\n', '\n').replace('\\t', '\t')
    textFile = textFile.split(',"height":')
    textFile = textFile[0].split('{"full_text":')
    textFile = textFile[-1]
    splitFile = textFile.split('\n')

    for eachline in splitFile:
        x = eachline.encode('utf-8')
        try:
            output = output + str(x.decode('unicode-escape')) + '\n'
        except Exception:
            pass
    output = output[1:]
    output = output[:-1]
    output = output[:-1]
    text_file = open(str(count) + '.txt', "w")
    n = text_file.write(output)
    text_file.close()
    output = ''

print("Done")