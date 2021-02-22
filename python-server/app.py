#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import math
import matplotlib.pyplot as plt
import random
import pickle
import json
import networkx as nx
import numpy as np
import sys
import re
from networkx.readwrite import json_graph
from flask import Flask
from flask_cors import CORS # The typical way to import flask-cors

from flask import request




Export_Graph0START = pd.read_excel("EXPORT_TOTAL.xlsx",)
Export_Graph0 = Export_Graph0START.iloc[:,:6]
Export_Graph0.columns
Export_Graph0.columns=["EXP","PERIOD","23","IMP","value","PROD_COD"]


def GeneraGrafo(tg_period,tg_perc,pos_ini):
    Export_Graph0TOTAL = Export_Graph0
    dummy = Export_Graph0TOTAL[Export_Graph0TOTAL["PERIOD"].str.contains(tg_period)].sort_values("value",ascending=False)
    SUM = dummy.value.sum()
    dummy = dummy[dummy.value.cumsum(skipna=False)/SUM*100<tg_perc]  
    def shortNode(name):    
        return name[:2]  
    G = nx.DiGraph()
    print(Export_Graph0TOTAL)
    for node in set(np.hstack((dummy["IMP"].apply(shortNode).values,dummy["EXP"].apply(shortNode).values))):
        G.add_node(shortNode(node))
    for i,j in dummy.loc[:,["EXP","IMP"]].values:
        #print (shortNode(i),shortNode(j))
        G.add_edge(shortNode(i),shortNode(j))
    #plt.figure(figsize=(15,10))
    #ax = plt.gca()
    string_titolo = tg_period + "  " + str(tg_perc) + "%"
    #ax.set_title(string_titolo)
    GG=json_graph.node_link_data(G)
    Nodes=GG["nodes"]
    Links=GG["links"]    
    if pos_ini is None:
        pos_ini={}
        random.seed(7)
        for node in Nodes:
            x= random.uniform(0, 1)
            y= random.uniform(0, 1)
            pos_ini[node['id']]=np.array([x,y])
    print("fra")
    print(G.order())
    coord = nx.spring_layout(G,k=6/math.sqrt(G.order()), pos=pos_ini)
    #nx.draw(G, pos=coord, with_labels = True)
    #plt.savefig('Graph_'+tg_period+'.png')

    #plt.show()
    

    with open('pos_fin'+ tg_period +'.pickle', 'wb') as fp:
        pickle.dump(coord, fp)
    with open('pos_fin'+ tg_period +'.pickle', 'rb') as fp:
        coordPred=pickle.load(fp)
    
    
    #########################################################
    df_coord = pd.DataFrame.from_dict(coord,orient='index')
    df_coord.columns = ['x', 'y']
    df = pd.DataFrame(GG["nodes"])
    df.columns=['label']
    df['id'] = np.arange(df.shape[0])
    df = df[['id', 'label']]    
    out = pd.merge(df, df_coord, left_on='label', right_index=True)
    
    dict_nodes = out.T.to_dict().values()
    dfe = pd.DataFrame(GG["links"])
    res = dfe.set_index('source').join(out[['label','id']].set_index('label'), on='source', how='left')
    res.columns=['target', 'source_id']
    res2 = res.set_index('target').join(out[['label','id']].set_index('label'), on='target', how='left')
    res2.columns=['"from"','"to"']
    res2.reset_index(drop=True, inplace=True)
    dict_edges= res2.T.to_dict().values()
    new_dict = { "nodes": list(dict_nodes), "edges": list(dict_edges)}
    with open('graph_final_' + tg_period +'.json', 'w') as outfile:
        json.dump(new_dict, outfile) 
    with open('graph_final_' + tg_period +'.json', 'r') as outfile:
        JSON=json.load(outfile) 
    return coord,JSON

'''
lista_periods=Export_Graph0.PERIOD.drop_duplicates().values

tg_perc=30
pos=None
for tg_period in lista_periods[:2]:
    if pos is None:
        pos,JSON=GeneraGrafo(tg_period,tg_perc,pos)
    pos,JSON=GeneraGrafo(tg_period,tg_perc,pos)
    print(JSON)
'''





app = Flask(__name__)
CORS(app, resources=r'/*')

###########GRAPH METHOD#######################################################
@app.route('/wordtradegraph/<tg_period>/<tg_perc>/<Format>')
def wordtradegraph(tg_period,tg_perc,Format):
    print ("Word Trade Graph method get ....")
    print(tg_period)
    print(tg_perc)
    pos=None
    print(pos)  
    pos,JSON=GeneraGrafo(tg_period,int(tg_perc),pos)
    print(pos)

    return str(JSON)

@app.route('/hello')
def hello():
     return str(' world')
     
     
if __name__ == '__main__':
    IP='0.0.0.0'
    port=5500
    app.run(host=IP, port=port)



