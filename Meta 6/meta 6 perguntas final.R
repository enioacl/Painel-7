library(dplyr)
library(lubridate)
library(data.table)
library(prodlim)
dados<-dataset

dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Instância","mês","Pergunta","quantidade","unidade")
unidade<-dados%>%select(unidade)
unidade<-as.data.frame(unidade[c(1:37,39),])
names(unidade)="unidade"

#SUBSTITUI AS VT's DOS PROCESSOS QUE FORAM REDISTRIBUÍDOS
redis<-filter(dados,(Pergunta=="REDISTRIBUIDO"))%>%select(unidade,mês,quantidade)
redis$mês<-dmy_hms(redis$mês) #aqui mudar para dmy_hms
dados<-filter(dados,!(Pergunta=="REDISTRIBUIDO"))
#dados$mês<-as.numeric(dados$mês)

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO

redis<-redis%>%group_by(quantidade)%>%mutate(mês=if_else(mês!=max(mês),as.Date(NA),mês))
redis<-na.omit(redis)
redis<-select(redis,unidade,quantidade)


a<-left_join(dados,redis,by="quantidade")
a$unidade.x<-ifelse(is.na(a$unidade.y),a$unidade.x,a$unidade.y)
a<-select(a,-unidade.y)
names(a)[5]="unidade"

dados<-a

dados<-dados%>%group_by(unidade,mês,Pergunta,Instância)%>%summarise(quantidade=n())%>%data.frame()%>%select(unidade,mês,Pergunta,quantidade,Instância)



dados$mês<-as.numeric(dados$mês)
dados$quantidade<-as.numeric(dados$quantidade)


#adicionado o "trt 1ª instância" nas perguntas únicas


pp61<-dados%>%filter(Pergunta=='P61')%>%select(unidade,quantidade)%>%data.frame()
names(pp61)[2]="P61"
pp61$P61<-as.numeric(pp61$P61)
pp61[nrow(pp61)+1,]=c(".TRT 7 1ª INSTÂNCIA",sum(pp61$P61))
pp61$P61<-as.numeric(pp61$P61)
pp62<-dados%>%filter(Pergunta=='P62')%>%select(unidade,mês,quantidade)
names(pp62)[3]="P62"
pp63<-dados%>%filter(Pergunta=='P63')%>%select(unidade,mês,quantidade)
names(pp63)[3]="P63"
pp64<-dados%>%filter(Pergunta=='P64')%>%select(unidade,mês,quantidade)
names(pp64)[3]="P64"
pp65<-dados%>%filter(Pergunta=='P65')%>%select(unidade,quantidade)
pp65<-as.data.frame(pp65)
names(pp65)[2]="P65"
pp65$P65<-as.numeric(pp65$P65)
pp65[nrow(pp65)+1,]=c(".TRT 7 1ª INSTÂNCIA",sum(pp65$P65))
pp65$P65<-as.numeric(pp65$P65)

dados2<-full_join(pp62,pp63,by=c("unidade","mês"))%>%full_join(.,pp64,by=c("unidade","mês"))
dados2<-as.data.frame(dados2)
dados2[is.na(dados2)]=0


dados2<-dados2%>%arrange(unidade,mês)


TRT_1<-dados2%>%group_by(mês)%>%summarize(P62=sum(P62), P63=sum(P63), P64=sum(P64))
TRT_1<-as.data.frame(TRT_1%>%mutate(unidade=".TRT 7 1ª INSTÂNCIA"))
TRT_1<-arrange(TRT_1,mês)
dados2<-rbind(dados2,TRT_1)



meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
#meses=1:12
combin=CJ(unidade=unidade[,1],mês=meses) #combinação das unidades com cada mês para a comparação
combin$p62=rep(0,dim(combin)[1])
combin$p63=rep(0,dim(combin)[1])
combin$p64=rep(0,dim(combin)[1])
names(combin)=names(dados2)
combin=as.data.frame(combin)




pos=which(is.na(row.match(combin[1:2],dados2[1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(unidade,mês)

dados2=as.data.frame(ee)

#Perguntas únicas
dados2=left_join(dados2,pp61,by="unidade")
dados2=left_join(dados2,pp65,by="unidade")
dados2[is.na(dados2)]=0


#Grau de cumprimento acumulado
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_acumulado=(cumsum(P64)+P65)/(P61+P65+cumsum(P62)-cumsum(P63))*(10/9.5))


#Grau de cumprimento mensal
dados2<-dados2%>%mutate(GC_mensal=(P64+P65)/(P61+P65+P62-P63)*(10/9.5))

dados2$GC_acumulado[is.infinite(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.infinite(dados2$GC_mensal)]<-1
dados2$GC_acumulado[is.na(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.na(dados2$GC_mensal)]<-1

#Grau de cumprimento atual
dados2=dados2%>%group_by(unidade)%>%mutate(GC_atual=last(GC_acumulado))



meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")
aux2=1:dim(dados2)[1]

for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux2[a]=meses[i]
}

dados2$mes_nomes=aux2

dados2<-as.data.frame(dados2)
