#META 1 
# 'dataset' tem os dados de entrada para este script
library(dplyr)
library(prodlim)
library(data.table)
library(lubridate)

dados<-as.data.frame(dataset,stringsAsFactors = FALSE)
dados<-as.data.frame(dados)
dados<-dados%>%select(sort(names(.)))
unidade<-as.data.frame(dados[c(1:37,39),5])
names(dados)=c("Instância","mês","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,mês,Pergunta,quant,Instância)

#DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(Unidade,mês,quant)
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))
dados<-as.data.frame(dados[-c(1:40),])
redis$Unidade[redis$Unidade=="NA"]=NA
redis$quant[redis$quant=="NA"]=NA
redis$mês[redis$mês=="NA"]=NA
redis<-na.omit(redis)
redis$mês<-dmy_hms(redis$mês)
redis<-redis%>%group_by(quant)%>%mutate(mês=if_else(mês!=max(mês),dmy_hms(NA),mês))
redis<-na.omit(redis)
redis<-select(redis,Unidade,quant)

a<-left_join(dados,redis,by="quant")
a<-a%>%mutate(Unidade.x=if_else(is.na(Unidade.y),as.character(Unidade.x),as.character(Unidade.y)))
a<-select(a,-Unidade.y, -Instância)
names(a)[1]="Unidade"

dados<-a

dados<-dados%>%group_by(Unidade,mês,Pergunta)%>%summarise(quant=n())%>%data.frame()%>%select(Unidade,mês,Pergunta,quant)


dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$mês<-as.character(dados$mês)

p11<-dados%>%filter(Pergunta=="P11")%>%select(Unidade, mês, quant)
p13<-dados%>%filter(Pergunta=="P13")%>%select(Unidade, mês, quant)
p17<-dados%>%filter(Pergunta=="P17")%>%select(Unidade, mês, quant)
p19<-dados%>%filter(Pergunta=="P19")%>%select(Unidade, mês, quant)

names(p11)[3]="P11"
names(p13)[3]="P13"
names(p17)[3]="P17"
names(p19)[3]="P19"

dados2<-full_join(p11, p13, by = c("mês", "Unidade"))%>%full_join(.,p17,by=c("mês", "Unidade"))%>%full_join(.,p19,by=c("mês","Unidade"))
dados2[is.na(dados2)]=0

TRT_Total<-dados2%>%group_by(mês)%>%summarize(P11=sum(P11), P13=sum(P13), P17=sum(P17), P19=sum(P19))%>%arrange(mês)
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1ª INSTÂNCIA")

dados2<-rbind(dados2, TRT_Total)

mês=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
combin=CJ(unidade[,1],mês) #combinação das unidades com cada mês para a comparação
combin$p11=rep(0,dim(combin)[1])
combin$p13=rep(0,dim(combin)[1])
combin$p17=rep(0,dim(combin)[1])
combin$p19=rep(0,dim(combin)[1])
names(combin)=names(dados2)
combin=as.data.frame(combin)

dados2<-as.data.frame(dados2)
pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(Unidade,mês)

dados2=as.data.frame(ee)


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCacumulado=(cumsum(P13)/(cumsum(P11)+1+cumsum(P17)-cumsum(P19))))%>%ungroup()

#Grau de cumprimento mensal
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCmensal=(P13/(P11+1+P17-P19)))%>%ungroup()

#Grau de cumprimento atual
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))%>%ungroup()

dados2[is.na(dados2)]=0


meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux
