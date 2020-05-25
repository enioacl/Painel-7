# 'dataset' tem os dados de entrada para este script

#TMDP 1

require(dplyr)


dados<-dataset

dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Instância","mês","quant","soma","unidade")
dados$mês<-as.numeric(dados$mês)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$soma<-as.numeric(dados$soma)
dados<-dados%>%select(unidade,mês,quant,soma)
dados<-dados[-c(1:40),]
dados<-as.data.frame(dados)
Unidades<-as.data.frame(dados%>%select(unidade)); Unidades<-Unidades[c(1:37,39),]


#trt primeira instância por mês

TRT_1<-cbind(unidade=rep(".TRT 7 1ª INSTÂNCIA",length(unique(dados$mês))),
             dados%>%group_by(mês)%>%summarise(quant=sum(quant),soma=sum(soma)))
dados2<-rbind(dados,TRT_1)
dados2<-arrange(dados2,unidade,mês)



require(lubridate)
require(data.table)


mês=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
#mês=1:12 
combin=CJ(unidade=Unidades,mês) #combinação das unidades com cada mês para a comparação
combin$quant<-0
combin$soma<-0
combin<-as.data.frame(combin)


require(prodlim)


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

dados2[is.na(dados2)]=0


meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$meta<-
dados2$gc_tmdp1<-203/dados2$GC_acumulado
