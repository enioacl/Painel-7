require(dplyr)
dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Inst�ncia","m�s","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,m�s,Pergunta,quant,Inst�ncia)
Unidade<-as.data.frame(dados%>%select(Unidade))
Unidade<-Unidade[c(1:37,39),]

dados$quant <- as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$m�s <- as.numeric(dados$m�s)

# Primeira Inst�ncia
inst1_p51<-dados%>%filter(Pergunta=="P51")%>%select(Unidade,m�s,quant)
names(inst1_p51)[3]<-"P51"
inst1_p52<-dados%>%filter(Pergunta=="P52")%>%select(Unidade,m�s,quant)
names(inst1_p52)[3]<-"P52"
inst1_p53<-dados%>%filter(Pergunta=="P53")%>%select(Unidade,m�s,quant)
names(inst1_p53)[3]<-"P53"
inst1_p54<-dados%>%filter(Pergunta=="P54")%>%select(Unidade,m�s,quant)
names(inst1_p54)[3]<-"P54"
inst1_p55<-dados%>%filter(Pergunta=="P55")%>%select(Unidade,m�s,quant)
names(inst1_p55)[3]<-"P55"
inst1_p56<-dados%>%filter(Pergunta=="P56")%>%select(Unidade,m�s,quant)
names(inst1_p56)[3]<-"P56"
inst1_p57<-dados%>%filter(Pergunta=="P57")%>%select(Unidade,m�s,quant)
names(inst1_p57)[3]<-"P57"
inst1_p58<-dados%>%filter(Pergunta=="P58")%>%select(Unidade,m�s,quant)
names(inst1_p58)[3]<-"P58"


primeira_inst<-full_join(inst1_p51, inst1_p52, by=c("Unidade","m�s"))%>%full_join(.,inst1_p53,by=c("Unidade","m�s"))%>%full_join(.,inst1_p54,by=c("Unidade","m�s"))%>%full_join(.,inst1_p55,by=c("Unidade","m�s"))%>%full_join(.,inst1_p56,by=c("Unidade","m�s"))%>%full_join(.,inst1_p57,by=c("Unidade","m�s"))%>%full_join(.,inst1_p58,by=c("Unidade","m�s"))
primeira_inst[is.na(primeira_inst)]=0
primeira_inst<-primeira_inst%>%arrange(Unidade,m�s)

TRT_Total<-primeira_inst%>%group_by(m�s)%>%summarize(P51=sum(P51), P52=sum(P52), P53=sum(P53), P54=sum(P54), P55=sum(P55), P56=sum(P56), P57=sum(P57), P58=sum(P58))%>%ungroup()%>%arrange(m�s)
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1� INST�NCIA")

dados2<-rbind(primeira_inst,TRT_Total)
dados2<-as.data.frame(dados2%>%select(Unidade,m�s,everything())%>%arrange(Unidade,m�s))




require(lubridate)
require(data.table)

##############################
############################
#####meses=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
############
###########AJEITAR AQUIIIIIIIIIIII ##################################
#################
m�s<-1:12
combin<-CJ(Unidade, m�s)
combin$P51=rep(0,dim(combin)[1])
combin$P52=rep(0,dim(combin)[1])
combin$P53=rep(0,dim(combin)[1])
combin$P54=rep(0,dim(combin)[1])
combin$P55=rep(0,dim(combin)[1])
combin$P56=rep(0,dim(combin)[1])
combin$P57=rep(0,dim(combin)[1])
combin$P58=rep(0,dim(combin)[1])
combin<-select(combin,Unidade,m�s,everything())
combin=as.data.frame(combin)


require(prodlim)

pos=which(is.na(row.match(combin[,1:2],dados2[,1:2])))
dados2<-rbind(dados2,combin[pos,])
dados2=arrange(dados2,Unidade,m�s)


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCacumulado=(cumsum(P53)+cumsum(P54))/(cumsum(P51)+cumsum(P52)+1+cumsum(P55)+cumsum(P56)-cumsum(P57)-cumsum(P58)))
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))
#Grau de cumprimento mensal
dados2<-dados2%>%mutate(GCmensal=(P53+P54)/(P51+P52+1+P55+P56-P57-P58))

#Grau de cumprimento atual
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))

dados2[is.na(dados2)]=0
dados2$GCmensal[is.infinite(dados2$GCmensal)]=0
dados2$GCacumulado[is.infinite(dados2$GCacumulado)]=0


meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

aux=1:dim(dados2)[1]

for(i in 1:max(dados2$m�s)){
  a=which(dados2$m�s==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux

dados2$Inst�ncia<-"TRT total"

dados2<-as.data.frame(dados2)