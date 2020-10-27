library(readxl)
library(dplyr)
library(prodlim)
library(data.table)
library(lubridate)
dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)=c("Instância","mês","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,mês,Pergunta,quant,Instância)
Unidade<-as.data.frame(dados%>%select(Unidade))
Unidade<-as.data.frame(Unidade[c(1:37,39),])
names(Unidade)="unidades"
dados$mês<-as.character(dados$mês)


#SUBSTITUI AS VT's DOS PROCESSOS QUE FORAM REDISTRIBUÍDOS
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(Unidade,mês,quant)
redis$mês[redis$mês=="null"]=NA
redis<-na.omit(redis)
redis$mês<-dmy_hms(redis$mês) 
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))
dados$mês<-as.numeric(dados$mês)

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO
redis<-redis%>%group_by(quant)%>%mutate(mês=if_else(mês!=max(mês),dmy_hms(NA),mês))
redis<-na.omit(redis)
redis<-select(redis,Unidade,quant)


a<-left_join(dados,redis,by="quant")
a$Unidade.x<-ifelse(is.na(a$Unidade.y),a$Unidade.x,a$Unidade.y)
a<-select(a,-Unidade.y)
names(a)[1]="Unidade"

dados<-a

dados<-dados%>%group_by(Unidade,mês,Pergunta,Instância)%>%summarise(quant=n())%>%data.frame()%>%select(Unidade,mês,Pergunta,quant,Instância)


dados$mês<-as.numeric(dados$mês)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0

p21<-dados%>%filter(Pergunta=="P21")%>%select(Unidade,quant)%>%data.frame()
names(p21)[2]="P21"
p21[nrow(p21)+1,]=c(".TRT 7 1ª INSTÂNCIA",sum(p21$P21))
p21$P21<-as.numeric(p21$P21)

p24<-dados%>%filter(Pergunta=="P24")%>%select(Unidade, mês, quant)
names(p24)[3]="P24"

p27<-dados%>%filter(Pergunta=="P27")%>%select(Unidade, mês, quant)
names(p27)[3]="P27"

p210<-dados%>%filter(Pergunta=="P210")%>%select(Unidade, mês, quant)
names(p210)[3]="P210"

p213<-dados%>%filter(Pergunta=="P213")%>%select(Unidade,quant)%>%data.frame()
names(p213)[2]="P213"
p213[nrow(p213)+1,]=c(".TRT 7 1ª INSTÂNCIA",sum(p213$P213))
p213$P213<-as.numeric(p213$P213)



dados2<-full_join(p24,p27,by=c("Unidade","mês"))%>%full_join(.,p210,by=c("Unidade","mês"))
dados2[is.na(dados2)]=0


TRT_Total<-dados2%>%group_by(mês)%>%summarize( P24=sum(P24), P27=sum(P27), P210=sum(P210))
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1ª INSTÂNCIA")

dados2<-rbind(dados2, TRT_Total)
dados2[is.na(dados2)]=0


meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
#meses=1:12
combin=CJ(Unidade=Unidade$unidades,mês=meses) #combinação das unidades com cada mês para a comparação
combin$P24=rep(0,dim(combin)[1])
combin$P27=rep(0,dim(combin)[1])
combin$P210=rep(0,dim(combin)[1])

combin=as.data.frame(combin)



dados2<-as.data.frame(dados2)
pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(Unidade,mês)

dados2=as.data.frame(ee)

#adicionando as perguntas únicas
dados2<-left_join(dados2,p21,by="Unidade")
dados2<-left_join(dados2,p213,by="Unidade")
dados2[is.na(dados2)]=0

#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCacumulado=((cumsum(P210)+P213)/(P21+P213+cumsum(P24)-cumsum(P27)))*(10/9.2))

#Grau de cumprimento mensal
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCmensal=((P210+P213)/(P21+P213+P24-P27))*(10/9.2))


dados2$GCacumulado[is.infinite(dados2$GCacumulado)]<-1
dados2$GCacumulado[is.na(dados2$GCacumulado)]<-1
dados2$GCmensal[is.infinite(dados2$GCmensal)]<-1
dados2$GCmensal[is.na(dados2$GCmensal)]<-1

#Grau de cumprimento atual
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))%>%ungroup()





meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$Instância<-"TRT total"
