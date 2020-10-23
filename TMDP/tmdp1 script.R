# 'dataset' tem os dados de entrada para este script

#TMDP 1

library(dplyr)
library(lubridate)


dados<-dataset

dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Instância","mês","Pergunta","quant","soma","unidade")
dados<-as.data.frame(dados)
Unidades<-as.data.frame(dados%>%select(unidade))
Unidades<-as.data.frame(Unidades[c(1:37,39),])
names(Unidades)<-"unidade"




#SUBSTITUI AS VT's DOS PROCESSOS QUE FORAM REDISTRIBUÍDOS
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(unidade,mês,quant)
redis$mês<-dmy_hms(redis$mês)
dados<-as.data.frame(dados[-c(1:40),])
dados$Pergunta[is.na(dados$Pergunta)]="deixar"
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))


#DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO

redis<-redis%>%group_by(quant)%>%mutate(mês=if_else(mês!=max(mês),as.Date(NA),mês))

redis<-na.omit(redis)
redis<-select(redis,unidade,quant)

a<-left_join(dados,redis,by="quant")
a$unidade.x<-ifelse(is.na(a$unidade.y),a$unidade.x,a$unidade.y)
a<-select(a,-unidade.y)
a<-a%>%select(unidade.x,mês,quant,soma,Instância)

names(a)[1]="unidade"

dados<-a

dados<-dados%>%group_by(unidade,mês)%>%summarise(quant=n(),soma=sum(soma))%>%data.frame()%>%
  select(unidade,mês,quant,soma)



dados$mês<-as.numeric(dados$mês)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$soma<-as.numeric(dados$soma)



#trt primeira instância por mês

TRT_1<-cbind(unidade=rep(".TRT 7 1ª INSTÂNCIA",length(unique(dados$mês))),
             dados%>%group_by(mês)%>%summarise(quant=sum(quant),soma=sum(soma)))
dados2<-rbind(dados,TRT_1)
dados2<-arrange(dados2,unidade,mês)



library(lubridate)
library(data.table)


mês=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
combin=CJ(unidade=Unidades$unidade,mês) #combinação das unidades com cada mês para a comparação
combin$quant<-0
combin$soma<-0
combin<-as.data.frame(combin)


library(prodlim)


#ajeitar o combin[1:2] para combin[,1:2]
pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(unidade,mês)

dados2=as.data.frame(ee)


#divididos por 100 para ficar em porcentagem corretamente no power bi
#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_acumulado=cumsum(soma)/cumsum(quant))

#Grau de cumprimento mensal
dados2<-dados2%>%mutate(GC_mensal=soma/quant)

#Grau de cumprimento atual
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_atual=last(GC_acumulado))

dados2[is.na(dados2)]=1


meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$meta<-203
dados2$gc_tmdp1<-203/dados2$GC_acumulado
dados2<-dados2%>%group_by(unidade)%>%mutate(GCtmdp1_atual=last(gc_tmdp1))%>%ungroup()


dados2<-as.data.frame(dados2)
