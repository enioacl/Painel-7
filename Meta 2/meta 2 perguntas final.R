require(readxl)
require(dplyr)
library(prodlim)
library(data.table)
#dados<-dataset
dados<-read_excel("X:/SGE/GABINETE/CONSELHO NACIONAL DE JUSTICA/METAS NACIONAIS CNJ/Metas Nacionais 2019 - CNJ/SQL metas/metas por pergunta/Meta 2/v2 meta 2 perguntas.xlsx")

dados<-dados%>%select(sort(names(.)))
names(dados)=c("Inst�ncia","m�s","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,m�s,Pergunta,quant,Inst�ncia)
Unidade<-as.data.frame(dados%>%select(Unidade))
Unidade<-Unidade[c(1:37,39),]


dados$m�s<-as.numeric(dados$m�s)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0

p21<-dados%>%filter(Pergunta=="P21")%>%select(Unidade,quant)
names(p21)[2]="P21"
p21[nrow(p21)+1,]=c(".TRT 7 1� INST�NCIA",sum(p21$P21))
p21$P21<-as.numeric(p21$P21)

p24<-dados%>%filter(Pergunta=="P24")%>%select(Unidade, m�s, quant)
names(p24)[3]="P24"

p27<-dados%>%filter(Pergunta=="P27")%>%select(Unidade, m�s, quant)
names(p27)[3]="P27"

p210<-dados%>%filter(Pergunta=="P210")%>%select(Unidade, m�s, quant)
names(p210)[3]="P210"

p213<-dados%>%filter(Pergunta=="P213")%>%select(Unidade,quant)
names(p213)[2]="P213"
p213[nrow(p213)+1,]=c(".TRT 7 1� INST�NCIA",sum(p213$P213))
p213$P213<-as.numeric(p213$P213)



dados2<-full_join(p24,p27,by=c("Unidade","m�s"))%>%full_join(.,p210,by=c("Unidade","m�s"))
dados2[is.na(dados2)]=0


TRT_Total<-dados2%>%group_by(m�s)%>%summarize( P24=sum(P24), P27=sum(P27), P210=sum(P210))
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1� INST�NCIA")

dados2<-rbind(dados2, TRT_Total)
dados2[is.na(dados2)]=0


#mes=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
meses=1:12
combin=CJ(Unidade,m�s=meses) #combina��o das unidades com cada m�s para a compara��o
combin$P24=rep(0,dim(combin)[1])
combin$P27=rep(0,dim(combin)[1])
combin$P210=rep(0,dim(combin)[1])

combin=as.data.frame(combin)



dados2<-as.data.frame(dados2)
pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e m�s
ee=ee%>%arrange(Unidade,m�s)

dados2=as.data.frame(ee)

#adicionando as perguntas �nicas
dados2<-left_join(dados2,p21,by="Unidade")
dados2<-left_join(dados2,p213,by="Unidade")

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





meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$m�s)){
  a=which(dados2$m�s==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$Inst�ncia<-"TRT total"