# 'dataset' tem os dados de entrada para este script

require(readxl)
require(dplyr)
dados<-dataset
dados<-read_excel("X:/SGE/GABINETE/CONSELHO NACIONAL DE JUSTICA/METAS NACIONAIS CNJ/Metas Nacionais 2019 - CNJ/SQL metas/metas por pergunta/Meta 6/tab dados.xlsx")
dados<-dados%>%select(sort(names(.)))


names(dados)<-c("Inst�ncia","m�s","Pergunta","quantidade","unidade")
dados$m�s<-as.numeric(dados$m�s)
dados$quantidade<-as.numeric(dados$quantidade)
unidade<-dados%>%select(unidade)
unidade<-as.data.frame(unidade[c(1:37,39),])

#adicionado o "trt 1� inst�ncia" nas perguntas �nicas


pp61<-dados%>%filter(Pergunta=='P61')%>%select(unidade,quantidade)
names(pp61)[2]="P61"
pp61[nrow(pp61)+1,]=c(".TRT 7 1� INST�NCIA",sum(pp61$P61))
pp61$P61<-as.numeric(pp61$P61)
pp62<-dados%>%filter(Pergunta=='P62')%>%select(unidade,m�s,quantidade)
names(pp62)[3]="P62"
pp63<-dados%>%filter(Pergunta=='P63')%>%select(unidade,m�s,quantidade)
names(pp63)[3]="P63"
pp64<-dados%>%filter(Pergunta=='P64')%>%select(unidade,m�s,quantidade)
names(pp64)[3]="P64"
pp65<-dados%>%filter(Pergunta=='P65')%>%select(unidade,quantidade)
names(pp65)[2]="P65"
pp65[nrow(pp65)+1,]=c(".TRT 7 1� INST�NCIA",sum(pp65$P65))
pp65$P65<-as.numeric(pp65$P65)

dados2<-full_join(pp62,pp63,by=c("unidade","m�s"))%>%full_join(.,pp64,by=c("unidade","m�s"))
dados2<-as.data.frame(dados2)
dados2[is.na(dados2)]=0


dados2<-dados2%>%arrange(unidade,m�s)


TRT_1<-dados2%>%group_by(m�s)%>%summarize(P62=sum(P62), P63=sum(P63), P64=sum(P64))
TRT_1<-as.data.frame(TRT_1%>%mutate(unidade=".TRT 7 1� INST�NCIA"))
TRT_1<-arrange(TRT_1,m�s)
dados2<-rbind(dados2,TRT_1)

require(lubridate)
require(data.table)

#mes=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
meses=1:12
combin=CJ(unidade=unidade[,1],m�s=meses) #combina��o das unidades com cada m�s para a compara��o
combin$p62=rep(0,dim(combin)[1])
combin$p63=rep(0,dim(combin)[1])
combin$p64=rep(0,dim(combin)[1])
names(combin)=names(dados2)
combin=as.data.frame(combin)


require(prodlim)

pos=which(is.na(row.match(combin[1:2],dados2[1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e m�s
ee=ee%>%arrange(unidade,m�s)

dados2=as.data.frame(ee)

#Perguntas �nicas
dados2=left_join(dados2,pp61,by="unidade")
dados2=left_join(dados2,pp65,by="unidade")
dados2[is.na(dados2)]=0


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_acumulado=(cumsum(P64)+P65)/(P61+P65+cumsum(P62)-cumsum(P63))*(10/9.8))


#Grau de cumprimento mensal
dados2<-dados2%>%mutate(GC_mensal=(P64+P65)/(P61+P65+P62-P63)*(10/9.8))

dados2$GC_acumulado[is.infinite(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.infinite(dados2$GC_mensal)]<-1
dados2$GC_acumulado[is.na(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.na(dados2$GC_mensal)]<-1

#Grau de cumprimento atual
dados2=dados2%>%group_by(unidade)%>%mutate(GC_atual=last(GC_acumulado))



meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")
aux2=1:dim(dados2)[1]

for(i in 1:max(dados2$m�s)){
  a=which(dados2$m�s==i)
  aux2[a]=meses[i]
}

dados2$mes_nomes=aux2

dados2<-as.data.frame(dados2)
