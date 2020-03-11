#META 1 
# 'dataset' tem os dados de entrada para este script
require(dplyr)
library(prodlim)
library(data.table)
dados<-dataset

unidade<-as.data.frame(dados[c(1:37,39),1])
dados<-dados%>%select(sort(names(.)))
names(dados)=c("Inst�ncia","m�s","Pergunta","quant","Unidade")
dados<-dados%>%select(Unidade,m�s,Pergunta,quant,Inst�ncia)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$m�s<-as.numeric(dados$m�s)



p11<-dados%>%filter(Pergunta=="P11")%>%select(Unidade, m�s, quant)
p13<-dados%>%filter(Pergunta=="P13")%>%select(Unidade, m�s, quant)
p17<-dados%>%filter(Pergunta=="P17")%>%select(Unidade, m�s, quant)
p19<-dados%>%filter(Pergunta=="P19")%>%select(Unidade, m�s, quant)


names(p11)[3]="P11"
names(p13)[3]="P13"
names(p17)[3]="P17"
names(p19)[3]="P19"


dados2<-full_join(p11, p13, by = c("m�s", "Unidade"))%>%full_join(.,p17,by=c("m�s", "Unidade"))%>%full_join(.,p19,by=c("m�s","Unidade"))
dados2[is.na(dados2)]=0

TRT_Total<-dados2%>%group_by(m�s)%>%summarize(P11=sum(P11), P13=sum(P13), P17=sum(P17), P19=sum(P19))%>%arrange(m�s)
TRT_Total<-TRT_Total%>%mutate(Unidade=".TRT 7 1� INST�NCIA")

dados2<-rbind(dados2, TRT_Total)

#mes=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
m�s=1:12
combin=CJ(unidade[,1],m�s) #combina��o das unidades com cada m�s para a compara��o
combin$p11=rep(0,dim(combin)[1])
combin$p13=rep(0,dim(combin)[1])
combin$p17=rep(0,dim(combin)[1])
combin$p19=rep(0,dim(combin)[1])
names(combin)=names(dados2)
combin=as.data.frame(combin)


dados2<-as.data.frame(dados2)
pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e m�s
ee=ee%>%arrange(Unidade,m�s)

dados2=as.data.frame(ee)


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCacumulado=(cumsum(P13)/(cumsum(P11)+1+cumsum(P17)-cumsum(P19))))%>%ungroup()

#Grau de cumprimento mensal
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCmensal=(P13/(P11+1+P17-P19)))%>%ungroup()

#Grau de cumprimento atual
dados2<-dados2%>%group_by(Unidade)%>%mutate(GCatual=last(GCacumulado))%>%ungroup()

dados2[is.na(dados2)]=0


meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$m�s)){
  a=which(dados2$m�s==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux