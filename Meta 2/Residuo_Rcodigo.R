
library(dplyr)
library(lubridate)
dados<-dataset
dados<-as.data.frame(dados)
#dados$MES<-dmy_hms(dados$MES) 
dados<-dados%>%select(sort(names(.)))

names(dados)<-c("mês","Pergunta","quant","Unidade")
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(Unidade,mês,quant)
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))

redis<-na.omit(redis) # precisou colocar antes da definição de data por conta de erro

dados$mês<-ymd_hms(dados$mês) 
redis$mês<-dmy_hms(redis$mês)

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO
# redis$Unidade[redis$Unidade=="NA"]=NA # os NA estão como vazio nao como string
# redis$quant[redis$quant=="NA"]=NA
# redis$mês[redis$mês=="NA"]=NA
# redis<-na.omit(redis) # estava dando erro por conta da posição
# redis$mês<-dmy_hms(redis$mês)
redis<-redis%>%group_by(quant)%>%mutate(mês=if_else(mês!=max(mês),dmy_hms(NA),mês))
redis<-na.omit(redis)
redis<-select(redis,Unidade,quant)


a<-left_join(dados,redis,by="quant")
a<-a%>%mutate(Unidade.x=if_else(is.na(Unidade.y),as.character(Unidade.x),as.character(Unidade.y)))
a<-select(a,-Unidade.y)
names(a)=c("DATA","perg","PROCESSO_NUMERO_UNICO","TXT_UNIDADE")
dados<-as.data.frame(a)


p47<-dados%>%filter(perg=="p24"|perg=="p27") #perguntas 2.4 e 2.7
l<-p47%>%group_by(PROCESSO_NUMERO_UNICO)%>%filter(n()>1)%>%ungroup() #somente os duplicados
# ordena por data os preocessos iguais
l<-l%>%arrange(PROCESSO_NUMERO_UNICO,desc(DATA))
l<-as.data.frame(l)
# separando os processos
a<-anti_join(p47,l,by=NULL)  # juntar com o novo l
a<-as.data.frame(a)

i=1
# dos processos redistribuidos fica-se com o mais recente 
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
# retira os processos p27_p210 q estão em p21_p24
residuo<-anti_join(p21_p24,p27_p210,by="PROCESSO_NUMERO_UNICO")
names(residuo)<-c("unidade","processo")
residuo<-unique(residuo)
residuo<-as.data.frame(residuo)
