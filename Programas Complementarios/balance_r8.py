f = open('r8-test-all-terms-clean.txt', 'r')

clases = []
documentos = []
dic = {}
dic['earn'] = []
dic['money-fx'] = []
dic['trade'] = []
dic['acq'] = []
dic['grain'] = []
dic['interest'] = []
dic['crude'] = []
dic['ship'] = []

suma_long = 0

i=0
for line in f:
    clase = line[0 : line.index('\t')]
    documento = line[line.index('\t')+1 :]
    
    #print str(len(documento))
    
    clases.append(clase)
    documentos.append(documento)
    
    dic[clase].append(i)
    
    suma_long = suma_long + len(documento)
    
    i = i+1

f.close()

cant = []
for i in dic:
    cant.append(len(dic[i]))

avg_cant_doc = sum(cant)/len(cant)

avg_long_doc = suma_long / len(documentos)

porc = []
for x in cant:
    porc.append(100.00*x/sum(cant))

f1 = open('r8-test-all-terms-clean-balanced.txt', 'w')

for clase in dic:
    for i in range(1, len(dic[clase])):
        if i < avg_cant_doc:
            indice = dic[clase][i]
            f1.write(str(clases[indice]) + '\t' + str(documentos[indice]))
        else:
            break

f1.close()