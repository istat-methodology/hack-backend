#!/usr/bin/env python
# coding: utf-8

import os
import pandas as pd
import numpy as np
import random
import math
from networkx.readwrite import json_graph
import json
from flask import Response
DATA_AVAILABLE="data"+os.sep+"dataAvailable"
SEP=","
DATA_EXTENTION=".dat"
TIME_FTM=(2,2+6)
NTSR_PROD_FILE="data"+os.sep+"NSTR.txt"

def data_extraction(date):   
    return date[TIME_FTM[0]:TIME_FTM[1]]

def load_files_available(): 
    # reads DATA_AVAILABLE dir
    # DATA_EXTENTION separator
    N_dfs=0
    for f in os.listdir(DATA_AVAILABLE):
        if f.endswith(DATA_EXTENTION):
            print(f,data_extraction(f),"...loading")
            N_dfs+=1  
            if N_dfs==1:
                df=pd.read_csv(DATA_AVAILABLE+os.sep+f,sep=SEP)
                
                print ("\t","shape",df.shape)
                continue
            appo=pd.read_csv(DATA_AVAILABLE+os.sep+f,sep=SEP)        
            print ("\t","shape",appo.shape)
            df=df.append(appo)
            
            df=df[df["PRODUCT_NSTR"]!="TOT"]
            df=df[df["DECLARANT_ISO"]!="EU"]
            df=df[df["PARTNER_ISO"]!="EU"]
            
            
    return df

        

df_transport = load_files_available()

#build dict mapping NTSR prod and viceversa
NTSR_prod=pd.read_csv(NTSR_PROD_FILE,"\t",index_col=0)#.to_dict()
NTSR_prod_dict=NTSR_prod.to_dict()
NTSR_prod_dict=NTSR_prod_dict['AGRICULTURAL PRODUCTS AND LIVE ANIMALS']
prod_NTSR_dict=NTSR_prod.reset_index()

prod_NTSR_dict=prod_NTSR_dict[prod_NTSR_dict['0'].str.len()==3]
prod_NTSR_dict=prod_NTSR_dict.set_index("AGRICULTURAL PRODUCTS AND LIVE ANIMALS").to_dict()["0"]



def estrai_tabella_per_grafo(tg_period,tg_perc,listaMezzi,flow,product,criterio):
    df_transport_estrazione = df_transport[df_transport["PERIOD"]==tg_period]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["TRANSPORT_MODE"].isin(listaMezzi)]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["FLOW"]==flow]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["PRODUCT_NSTR"]==product]

    df_transport_estrazione=df_transport_estrazione.groupby(["DECLARANT_ISO","PARTNER_ISO"]).sum().reset_index()[["DECLARANT_ISO","PARTNER_ISO","VALUE_IN_EUROS","QUANTITY_IN_KG"]]
    
    df_transport_estrazione=df_transport_estrazione.sort_values(criterio,ascending=False)
    SUM = df_transport_estrazione[criterio].sum()    
    df_transport_estrazione = df_transport_estrazione[df_transport_estrazione[criterio].cumsum(skipna=False)/SUM*100<tg_perc] 
    
    return df_transport_estrazione

def makeGraph(tab4graph,pos_ini,weight_flag,flow):
    import networkx as nx
    G = nx.DiGraph()
    if flow==1:
        print("import")
        country_from="PARTNER_ISO"
        country_to="DECLARANT_ISO"
        
    if flow==2:
        print("export")    
        country_from="DECLARANT_ISO"
        country_to="PARTNER_ISO"
    weight="VALUE_IN_EUROS"
    
    if weight_flag==True:
        Wsum=tab4graph[weight].sum()
        edges=[ (i,j,w/Wsum) for i,j,w in tab4graph.loc[:,[country_from,country_to,weight]].values]
    if weight_flag==False:
        edges=[ (i,j,1) for i,j,w in tab4graph.loc[:,[country_from,country_to,weight]].values]
        #G.add_edge(i,j)
    G.add_weighted_edges_from(edges)
        
    GG=json_graph.node_link_data(G)
    Nodes=GG["nodes"]
    Links=GG["links"] 

    if pos_ini is None:
        pos_ini={}
        random.seed(8)
        for node in Nodes:
            x= random.uniform(0, 1)
            y= random.uniform(0, 1)
            pos_ini[node['id']]=np.array([x,y])

    coord = nx.spring_layout(G,k=5/math.sqrt(G.order()),pos=pos_ini)
    coord = nx.spring_layout(G,k=5/math.sqrt(G.order()),pos=coord) # stable solution
    #coord = nx.spring_layout(G,k=5/math.sqrt(G.order()),pos=coord) # stable solution

    nx.draw(G, pos=coord, with_labels = True)




    #########################################################
    df_coord = pd.DataFrame.from_dict(coord,orient='index')
    df_coord.columns = ['x', 'y']
    df = pd.DataFrame(GG["nodes"])
    df.columns=['label']
    df['id'] = np.arange(df.shape[0])
    df = df[['id', 'label']]    
    out = pd.merge(df, df_coord, left_on='label', right_index=True)

    dict_nodes = out.T.to_dict().values()
    dfe = pd.DataFrame(GG["links"])[["source" , "target"]]

    res = dfe.set_index('source').join(out[['label','id']].set_index('label'), on='source', how='left')
    res.columns=['target', 'source_id']
    res2 = res.set_index('target').join(out[['label','id']].set_index('label'), on='target', how='left')
    res2.columns=['"from"','"to"']
    res2.reset_index(drop=True, inplace=True)
    dict_edges= res2.T.to_dict().values()
    new_dict = { "nodes": list(dict_nodes), "edges": list(dict_edges)}
    JSON=json.dumps(new_dict) 

    
    return coord,JSON

def jsonpos2coord(jsonpos):
    coord={}
    for id,x,y in pd.DataFrame.from_dict(jsonpos["nodes"]) [["label","x","y"]].values:

        coord[id]=np.array([x,y])
    return coord    

from flask import Flask,request
from flask_cors import CORS
app = Flask(__name__)
CORS(app, resources=r'/*')

###########GRAPH METHOD#######################################################
#@app.route('/wordtradegraph/<tg_period>/<tg_perc>/<listaMezzi>/<criterio>/<product>/<flow>')
#def wordtradegraph(tg_period,tg_perc,listaMezzi,criterio,product,flow):

        
@app.route('/wordtradegraph', methods=['POST','GET'])
def wordtradegraph():
    if request.method == 'POST':
        
        print ("Word Trade Graph method get ....")
        criterio="VALUE_IN_EUROS" #VALUE_IN_EUROS 	QUANTITY_IN_KG

        jReq=dict(request.json)

        tg_perc=int(jReq['tg_perc'])
        tg_period=int(jReq['tg_period'])

        pos=jReq['pos']
        if pos=="None":
            pos=None
        else:
            #print ("pos-----",pos)
            #print ("pos-----",type(pos))
            
            pos=jsonpos2coord(pos)

        #0:Unknown 1:Sea 2:Rail 3:Road 4Air 5:Post 7:Fixed Mechanism 8:Inland Waterway 9:Self Propulsion
        listaMezzi=(jReq['listaMezzi']).split(",")#[0,1,2,3,4,5,7,8,9] 
        
        flow=int(jReq['flow'])
        
        product=str(jReq['product'])
        
        weight_flag=bool(jReq['weight_flag'])

        tab4graph=estrai_tabella_per_grafo(tg_period,tg_perc,listaMezzi,flow,product,criterio)

        pos,JSON=makeGraph(tab4graph,pos,weight_flag,flow)

        
        resp = Response(response=JSON,
                    status=200,
                    mimetype="application/json")

        return resp

    else:
        return str("only post")

@app.route('/hello')
def hello():
     return str(' world')
    
   
     
if __name__ == '__main__':
    IP='0.0.0.0'
    port=5500
    app.run(host=IP, port=port)


##############################################


'''
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
import os
from flask import request
from flask import Response




Export_Graph0START = pd.read_excel("data/EXPORT_TOTAL.xlsx",index_col=0)
#Export_Graph0START = pd.read_excel("data/Cartel1.xlsx",index_col=0)
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
    #print(Export_Graph0TOTAL)
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
   
    #print(G.order())
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
    res2.columns=['from','to']
    res2.reset_index(drop=True, inplace=True)
    dict_edges= res2.T.to_dict().values()
    new_dict = { "nodes": list(dict_nodes), "edges": list(dict_edges)}
    #with open('graph_final_' + tg_period +'.json', 'w') as outfile:
    JSON=  json.dumps(new_dict) 
    #with open('graph_final_' + tg_period +'.json', 'r') as outfile:
    #   JSON=json.load(outfile) 
	
    return coord,str(JSON).replace("'",'"').replace('""','"')


#lista_periods=Export_Graph0.PERIOD.drop_duplicates().values
#
#tg_perc=30
#pos=None
#for tg_period in lista_periods[:2]:
#    if pos is None:
#        pos,JSON=GeneraGrafo(tg_period,tg_perc,pos)
#    pos,JSON=GeneraGrafo(tg_period,tg_perc,pos)
#    print(JSON)

app = Flask(__name__)
CORS(app, resources=r'/*')

###########GRAPH METHOD#######################################################
@app.route('/wordtradegraph/<tg_period>/<tg_perc>/<Format>')
def wordtradegraph(tg_period,tg_perc,Format):
  #  print ("Word Trade Graph method get ....")
  #  print(tg_period)
  #  print(tg_perc)
    pos=None
  #  print(pos)  
    pos,JSON=GeneraGrafo(tg_period,int(tg_perc),pos)
  #  print(pos)
    resp = Response(response=JSON,
                    status=200,
                    mimetype="application/json")

    return resp
    

@app.route('/hello')
def hello():
     return str(' world')
     
     
if __name__ == '__main__':
    IP='0.0.0.0'
    port=5500
    app.run(host=IP, port=port)
'''

