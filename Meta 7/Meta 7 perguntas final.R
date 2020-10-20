
# 'dataset' tem os dados de entrada para este script
dados<-dataset
library(dplyr)
library(prodlim)
library(data.table)
library(lubridate)


dados<-dados%>%select(sort(names(.)))
names(dados)[c(1,2,3,4,6)]<-c("Instância","mes","pergunta","quant","unidade")
dados<-dados%>%select(unidade,mes,Instância,pergunta,quant)
dados$unidade<-as.character(dados$unidade)

dados$unidade[dados$unidade=="VT DE ARACATI"]="01ª VT DE ARACATI"
dados$unidade[dados$unidade=="VT DE EUSÉBIO"]="01ª VT DE EUSEBIO"
dados$unidade[dados$unidade=="VT DE PACAJUS"]="01ª VT DE PACAJUS"
dados$unidade[dados$unidade=="VT DE TIANGUÁ"]="01ª VT DE TIANGUÁ"
dados$unidade[dados$unidade=="VT DE BATURITE"]="01ª VT DE BATURITE"
dados$unidade[dados$unidade=="VT DE IGUATU"]="01ª VT DE IGUATU"
dados$unidade[dados$unidade=="VT DE QUIXADA"]="01ª VT DE QUIXADA"
dados$unidade[dados$unidade=="VT DE CRATEUS"]="01ª VT DE CRATEUS"
dados$unidade[dados$unidade=="VT DE LIMOEIRO DO NORTE"]="01ª VT DE LIMOEIRO DO NORTE"
dados$unidade[dados$unidade=="01ª VT DA REGIÃO DO CARIRI"]="01ª VT DE JUAZEIRO DO NORTE"
dados$unidade[dados$unidade=="02ª VT DA REGIÃO DO CARIRI"]="02ª VT DE JUAZEIRO DO NORTE"
dados$unidade[dados$unidade=="03ª VT DA REGIÃO DO CARIRI"]="03ª VT DE JUAZEIRO DO NORTE"
dados$unidade[dados$unidade=="VT DE SÃO GONÇALO DO AMARANTE"]="01ª VT DE SAO GONCALO DO AMARANTE"
dados$unidade[dados$unidade=="01ª VT DE MARACANAÚ"]="01ª VT DE MARACANAU"
dados$unidade[dados$unidade=="02ª VT DE MARACANAÚ"]="02ª VT DE MARACANAU"

unidade<-dados[c(1:38),1]



#SUBSTITUI AS VT's DOS PROCESSOS QUE FORAM REDISTRIBUÍDOS
redis<-filter(dados,(pergunta=="REDISTRIBUIDO"))%>%select(unidade,mes,quant)
redis$mes<-dmy(redis$mes) #aqui mudar para dmy_hms
dados<-filter(dados,!(pergunta=="REDISTRIBUIDO"))
dados$mes<-as.numeric(dados$mes)

# #DEIXAR APENAS A ÚLTIMA VT PARA A QUAL O PROCESSO FOI DISTRIBUÍDO

redis<-redis%>%group_by(quant)%>%mutate(mes=if_else(mes!=max(mes),as.Date(NA),mes))
redis<-na.omit(redis)
redis<-select(redis,unidade,quant)


a<-left_join(dados,redis,by="quant")
a$unidade.x<-ifelse(is.na(a$unidade.y),a$unidade.x,a$unidade.y)
a<-select(a,-unidade.y)
names(a)[1]="unidade"

dados<-a


dados$mes<-as.numeric(dados$mes)


P73<-dados%>%group_by(unidade)%>%filter(pergunta=='P7.3')%>%summarise(quantidade=length(unidade))%>%data.frame()
names(P73)[2]<-"P73"
P73$P73<-as.numeric(P73$P73)
P73[nrow(P73)+1,]=c(".TRT 7 1ª INSTÂNCIA",sum(P73$P73))
P73$P73<-as.numeric(P73$P73)

P74<-dados%>%group_by(unidade,mes)%>%filter(pergunta=='P7.4')%>%summarise(quantidade=length(unidade))
names(P74)[3]<-"P74"
P74$P74<-as.numeric(P74$P74)

P75<-dados%>%group_by(unidade,mes)%>%filter(pergunta=='P7.5')%>%summarise(quantidade=length(unidade))
names(P75)[3]<-"P75"
P75$P75<-as.numeric(P75$P75)

P76<-dados%>%group_by(unidade,mes)%>%filter(pergunta=='P7.6')%>%summarise(quantidade=length(unidade))
names(P76)[3]<-"P76"
P76$P76<-as.numeric(P76$P76)

P77<-dados%>%group_by(unidade,mes)%>%filter(pergunta=='P7.7')%>%summarise(quantidade=length(unidade))
names(P77)[3]<-"P77"
P77$P77<-as.numeric(P77$P77)

dados2<-full_join(P74,P75,by=c("unidade","mes"))%>%full_join(.,P76,by=c("unidade","mes"))%>%full_join(.,P77,by=c("unidade","mes"))
dados2[is.na(dados2)]=0
dados2<-as.data.frame(dados2)
dados2<-arrange(dados2,unidade,mes)


TRT_1<-dados2%>%group_by(mes)%>%summarise(P74=sum(P74),P75=sum(P75),P76=sum(P76),P77=sum(P77))
TRT_1<-as.data.frame(mutate(TRT_1,unidade=".TRT 7 1ª INSTÂNCIA")%>%select(unidade,everything()))


dados2<-rbind(dados2,TRT_1)
dados2<-arrange(dados2,unidade,mes)
dados2[is.na(dados2)]=0

#linhas faltantes

meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
combin=CJ(unidade=unidade$unidade,mes=meses) #combinação das unidades com cada mês para a comparação
combin$P74=rep(0,dim(combin)[1])
combin$P75=rep(0,dim(combin)[1])
combin$P76=rep(0,dim(combin)[1])
combin$P77=rep(0,dim(combin)[1])
combin$unidade<-as.character(combin$unidade)
combin=as.data.frame(combin)
combin$mes<-as.numeric(combin$mes)
combin$unidade<-as.character(combin$unidade)


pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(unidade,mes)

dados2<-as.data.frame(ee)

#adicionando a pergunta única
dados2<-left_join(dados2,P73,by="unidade")


#Grau de cumprimento acumulado

#p73<-P73

dados2<-dados2%>%group_by(unidade)%>%mutate(GC_acumulado=P73*0.98/(P73+cumsum(P74)+cumsum(P75)-cumsum(P76)-cumsum(P77)))%>%ungroup()

#Grau de cumprimento mensal
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_mensal=P73*0.98/(P73+P74+P75-P76-P77))%>%ungroup()

dados2$GC_acumulado[is.infinite(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.infinite(dados2$GC_mensal)]<-1
dados2$GC_acumulado[is.na(dados2$GC_acumulado)]<-1
dados2$GC_mensal[is.na(dados2$GC_mensal)]<-1

#Grau de cumprimento atual
dados2<-dados2%>%group_by(unidade)%>%mutate(GC_atual=last(GC_acumulado))%>%ungroup()




meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mes)){
  a=which(dados2$mes==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$Instância<-"TRT total"



dados2<-arrange(dados2,unidade,mes)
