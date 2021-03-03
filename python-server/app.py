import os
import pandas as pd
import numpy as np
import random
import math
from networkx.readwrite import json_graph
import json

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
                break
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



def estrai_tabella_per_grafo(tg_period,tg_perc,listaMezzi,flow,product,criterio,selezioneMezziEdges):
    df_transport_estrazione = df_transport[df_transport["PERIOD"]==tg_period]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["TRANSPORT_MODE"].isin(listaMezzi)]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["FLOW"]==flow]
    df_transport_estrazione=df_transport_estrazione[df_transport_estrazione["PRODUCT_NSTR"]==product]

    def build_query_mezzi(selezioneMezziEdges):
        listQuery=[]
        for edge in selezioneMezziEdges:#['edgesSelected']:
            print("@@@@@@@@@@@",edge)
            From=edge["from"]
            To=edge["to"]
            exclude=str(edge["exclude"])
            print (type(edge),type(From),type(To),type(exclude))    
            listQuery.append("(DECLARANT_ISO == '"+From+"' & PARTNER_ISO == '"+To+"' & TRANSPORT_MODE in "+exclude+")")
        return "not ("+("|".join(listQuery))+")"    
    if (selezioneMezziEdges is not None):
        Query=build_query_mezzi(selezioneMezziEdges)
        print(Query)
        df_transport_estrazione=df_transport_estrazione.query(Query)


    
    #aggrega
    df_transport_estrazione=df_transport_estrazione.groupby(["DECLARANT_ISO","PARTNER_ISO"]).sum().reset_index()[["DECLARANT_ISO","PARTNER_ISO","VALUE_IN_EUROS","QUANTITY_IN_KG"]]
    df_transport_estrazione=df_transport_estrazione.sort_values(criterio,ascending=False)

    #taglio sui nodi
    SUM = df_transport_estrazione[criterio].sum()     
    df_transport_estrazione = df_transport_estrazione[df_transport_estrazione[criterio].cumsum(skipna=False)/SUM*100<tg_perc] 
    
    return df_transport_estrazione

def makeGraph(tab4graph,pos_ini,weight_flag,flow):
    import networkx as nx
	
	
    def calc_metrics(Grafo,FlagWeight): 
        Metrics={
            "degree_centrality":nx.degree_centrality(Grafo),
            "density":nx.density(Grafo)
            }


        return Metrics 
	
	
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
        
    MetricG=calc_metrics(G,weight_flag)    
	
		
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
    res2.columns=['from','to']
    res2.reset_index(drop=True, inplace=True)
    dict_edges= res2.T.to_dict().values()
    new_dict = { "nodes": list(dict_nodes), "edges": list(dict_edges),"metriche":MetricG}
	
    JSON=json.dumps(new_dict) 

    
    return coord,JSON

def jsonpos2coord(jsonpos):
    coord={}
    for id,x,y in pd.DataFrame.from_dict(jsonpos["nodes"]) [["label","x","y"]].values:

        coord[id]=np.array([x,y])
    return coord    

from flask import Flask,request,Response
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
            print ("pos-----",pos)
            print ("pos-----",type(pos))
            
            pos=jsonpos2coord(pos)

        #0:Unknown 1:Sea 2:Rail 3:Road 4Air 5:Post 7:Fixed Mechanism 8:Inland Waterway 9:Self Propulsion
        #listaMezzi=map(int,(jReq['listaMezzi']).split(","))#[0,1,2,3,4,5,7,8,9] 
        listaMezzi=jReq['listaMezzi']#[0,1,2,3,4,5,7,8,9] 
        
        flow=int(jReq['flow'])
        
        product=str(jReq['product'])
        
        weight_flag=bool(jReq['weight_flag'])
        
        selezioneMezziEdges=jReq['selezioneMezziEdges']  
        if selezioneMezziEdges=="None":
            selezioneMezziEdges=None
        else:
            pass
            print(selezioneMezziEdges)
            print(type(selezioneMezziEdges))
        #--------------------
        
        

        tab4graph=estrai_tabella_per_grafo(tg_period,tg_perc,listaMezzi,flow,product,criterio,selezioneMezziEdges)

        
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
