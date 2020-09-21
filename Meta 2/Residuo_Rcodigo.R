library(dplyr)
library(lubridate)
dados<-dataset
dados<-as.data.frame(dados)
dados$DATA<-dmy_hms(dados$DATA) 


p47<-dados%>%filter(perg=="p24"|perg=="p27") #perguntas 2.4 e 2.7
l<-p47%>%group_by(PROCESSO_NUMERO_UNICO)%>%filter(n()>1)%>%ungroup() #somente os duplicados
l<-l%>%arrange(PROCESSO_NUMERO_UNICO,desc(DATA))
l<-as.data.frame(l)
a<-anti_join(p47,l,by=NULL)  #juntar com o novo l
a<-as.data.frame(a)

i=1
while(i<=nrow(l)){
  OI = l %>% filter(PROCESSO_NUMERO_UNICO==l$PROCESSO_NUMERO_UNICO[i])
  # Se sim, fazer 
  if(nrow(OI)>=2){
    
    if(l[i,4]=="p24"){ #colocar a coluna da pergunta
      l[(i+1):(i+dim(OI)[1]-1),]<-NA
      i=i+dim(OI)[1]
    }else{
      l
      i=i+dim(OI)[1]
    }
  }
  
}

l<-na.omit(l)
l<-as.data.frame(l)
nn<-rbind(a,l)
nn<-as.data.frame(nn)

p24<-nn%>%filter(perg=="p24")
p27<-nn%>%filter(perg=="p27")
p21<-dados%>%filter(perg=="p21")
p210<-dados%>%filter(perg=="p210")


#FINAL
p21_p24<-union(p21,p24)
p21_p24<-p21_p24%>%select(TXT_UNIDADE,PROCESSO_NUMERO_UNICO)
p27_p210<-union(p27,p210)
p27_p210<-p27_p210%>%select(TXT_UNIDADE,PROCESSO_NUMERO_UNICO)
residuo<-anti_join(p21_p24,p27_p210,by="PROCESSO_NUMERO_UNICO")
names(residuo)<-c("unidade","processo")
residuo<-unique(residuo)
residuo<-as.data.frame(residuo)






