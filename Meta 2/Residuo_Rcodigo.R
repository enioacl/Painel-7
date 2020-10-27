library(dplyr)
library(lubridate)
dados<-dataset
dados<-as.data.frame(dados)
dados$MES<-dmy_hms(dados$MES) 
dados<-dados%>%select(sort(names(.)))

names(dados)<-c("mês","Pergunta","quant","Unidade")
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(Unidade,mês,quant)
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO
redis<-na.omit(redis)
redis<-redis%>%group_by(quant)%>%mutate(mês=if_else(mês!=max(mês),dmy_hms(NA),mês))
redis<-na.omit(redis)
redis<-select(redis,Unidade,quant)


a<-left_join(dados,redis,by="quant")
a$Unidade.x<-ifelse(is.na(a$Unidade.y),a$Unidade.x,a$Unidade.y)
a<-select(a,-Unidade.y)
names(a)=c("DATA","perg","PROCESSO_NUMERO_UNICO","TXT_UNIDADE")
dados<-as.data.frame(a)


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
    
    if(l[i,2]=="p24"){ #colocar a coluna da pergunta
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
p21_p24<-rbind(p21,p24)
p21_p24<-p21_p24%>%select(TXT_UNIDADE,PROCESSO_NUMERO_UNICO)
p27_p210<-rbind(p27,p210)
p27_p210<-p27_p210%>%select(TXT_UNIDADE,PROCESSO_NUMERO_UNICO)
residuo<-anti_join(p21_p24,p27_p210,by="PROCESSO_NUMERO_UNICO")
names(residuo)<-c("unidade","processo")
residuo<-unique(residuo)
residuo<-as.data.frame(residuo)
