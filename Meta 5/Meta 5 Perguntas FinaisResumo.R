library(lubridate)
library(dplyr)
library(lubridate)
library(data.table)
library(prodlim)
dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Instância","mês","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,mês,Pergunta,quant,Instância)
Unidade<-as.data.frame(dados%>%select(Unidade))
Unidade<-as.data.frame(Unidade[c(1:37,39),])
names(Unidade)="Unidade"


redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(Unidade,mês,quant)
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))
dados<-as.data.frame(dados[-c(1:40),])

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO
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
a<-select(a,-Unidade.y)
names(a)[1]="Unidade"
dados<-as.data.frame(a)
dados<-dados%>%select(-Instância)
dados<-dados%>%group_by(Unidade,mês,Pergunta)%>%summarise(quant=n())%>%data.frame()%>%select(Unidade,mês,Pergunta,quant)


dados$quant <- as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$mês <- as.numeric(dados$mês)

# Primeira Instância
inst1_p51<-dados%>%filter(Pergunta=="P51")%>%select(Unidade,mês,quant)
names(inst1_p51)[3]<-"P51"
inst1_p52<-dados%>%filter(Pergunta=="P52")%>%select(Unidade,mês,quant)
names(inst1_p52)[3]<-"P52"
inst1_p53<-dados%>%filter(Pergunta=="P53")%>%select(Unidade,mês,quant)
names(inst1_p53)[3]<-"P53"
inst1_p54<-dados%>%filter(Pergunta=="P54")%>%select(Unidade,mês,quant)
names(inst1_p54)[3]<-"P54"
inst1_p55<-dados%>%filter(Pergunta=="P55")%>%select(Unidade,mês,quant)
names(inst1_p55)[3]<-"P55"
inst1_p56<-dados%>%filter(Pergunta=="P56")%>%select(Unidade,mês,quant)
names(inst1_p56)[3]<-"P56"
inst1_p57<-dados%>%filter(Pergunta=="P57")%>%select(Unidade,mês,quant)
names(inst1_p57)[3]<-"P57"
inst1_p58<-dados%>%filter(Pergunta=="P58")%>%select(Unidade,mês,quant)
names(inst1_p58)[3]<-"P58"


primeira_inst<-full_join(inst1_p51, inst1_p52, by=c("Unidade","mês"))%>%full_join(.,inst1_p53,by=c("Unidade","mês"))%>%full_join(.,inst1_p54,by=c("Unidade","mês"))%>%full_join(.,inst1_p55,by=c("Unidade","mês"))%>%full_join(.,inst1_p56,by=c("Unidade","mês"))%>%full_join(.,inst1_p57,by=c("Unidade","mês"))%>%full_join(.,inst1_p58,by=c("Unidade","mês"))
primeira_inst[is.na(primeira_inst)]=0
primeira_inst<-primeira_inst%>%arrange(Unidade,mês)

TRT_Total<-primeira_inst%>%group_by(mês)%>%summarize(P51=sum(P51), P52=sum(P52), P53=sum(P53), P54=sum(P54), P55=sum(P55), P56=sum(P56), P57=sum(P57), P58=sum(P58))%>%ungroup()%>%arrange(mês)
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1ª INSTÂNCIA")

dados2<-rbind(primeira_inst,TRT_Total)
dados2<-as.data.frame(dados2%>%select(Unidade,mês,everything())%>%arrange(Unidade,mês))




mês<-1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
combin<-CJ(Unidade=Unidade$Unidade, mês)
combin$P51=rep(0,dim(combin)[1])
combin$P52=rep(0,dim(combin)[1])
combin$P53=rep(0,dim(combin)[1])
combin$P54=rep(0,dim(combin)[1])
combin$P55=rep(0,dim(combin)[1])
combin$P56=rep(0,dim(combin)[1])
combin$P57=rep(0,dim(combin)[1])
combin$P58=rep(0,dim(combin)[1])
combin<-select(combin,Unidade,mês,everything())
combin=as.data.frame(combin)




pos=which(is.na(row.match(combin[,1:2],dados2[,1:2])))
dados2<-rbind(dados2,combin[pos,])
dados2=arrange(dados2,Unidade,mês)


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCacumulado=(cumsum(P53)+cumsum(P54))/(cumsum(P51)+cumsum(P52)+1+cumsum(P55)+cumsum(P56)-cumsum(P57)-cumsum(P58)))

#Grau de cumprimento mensal
dados2<-dados2%>%mutate(GCmensal=(P53+P54)/(P51+P52+1+P55+P56-P57-P58))

dados2[is.na(dados2)]=1
dados2$GCmensal[is.infinite(dados2$GCmensal)]=1
dados2$GCacumulado[is.infinite(dados2$GCacumulado)]=1
#dados2$GCacumulado[dados2$GCacumulado<0]=1
#dados2$GCmensal[dados2$GCmensal<0]=1

#Grau de cumprimento atual
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))





meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

aux=1:dim(dados2)[1]

for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux

dados2$Instância<-"TRT total"

dados2<-as.data.frame(dados2)
