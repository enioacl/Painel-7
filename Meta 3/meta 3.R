# 'dataset' tem os dados de entrada para este script
# 'dataset' tem os dados de entrada para este script
##neste código o 'mes' na parte da combinação das unidades e meses está apenas para teste
##em comentário está a função correta para ser utilizada. Ou, se for melhor, colocar
## de 1 até 12.
# 'dataset' tem os dados de entrada para este script

require(readxl)
require(dplyr)
dados<-dataset 

dados<-dados%>%select(sort(names(.)))
names(dados)<-c("mês","Pergunta","quant","unidade")
dados<-dados%>%select(unidade,mês,Pergunta,quant)
unidade<-as.data.frame(dados[c(1:37,39),1])
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$mês<-as.numeric(dados$mês)

d35<-dados%>%filter(Pergunta=='P35')%>%select(unidade,mês,quant)
names(d35)[3]<-"P35"
d36<-dados%>%filter(Pergunta=='P36')%>%select(unidade,mês,quant)
names(d36)[3]<-"P36"


dados2<-full_join(d35,d36,by=c("unidade","mês"))
dados2[is.na(dados2)]=0

dados2<-as.data.frame(dados2)


TRT_1=cbind(unidade=rep(".TRT 7 1ª INSTÂNCIA",length(unique(dados2$mês))),
            (dados2%>%group_by(mês)%>%summarise(P35=sum(P35),P36=sum(P36))))
dados2<-dados2%>%arrange(unidade,mês)
dados2=as.data.frame(rbind(dados2,TRT_1))


require(lubridate)
require(data.table)


#mes=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
mes=1:12 
combin=CJ(unidade[,1],mes) #combinação das unidades com cada mês para a comparação
combin$p35=rep(0,dim(combin)[1])
combin$p36=rep(0,dim(combin)[1])
names(combin)=names(dados2)
combin=as.data.frame(combin)


require(prodlim)

pos=which(is.na(row.match(combin[,1:2],dados2[,1:2]))) #linhas para adicionar 
ee=rbind(dados2,combin[pos,]) #juntando o data frame com as linhas faltantes

#reorganizar as linhas por unidade e mês
ee=ee%>%arrange(unidade,mês)

dados2=as.data.frame(ee)


#grau de cumprimento acumulado
dados2=as.data.frame(dados2%>%group_by(unidade)%>%mutate(Gcacumulado=cumsum(P35)/cumsum(P36)*(10/4.5)))

#grau de cumprimento mensal
dados2=dados2%>%mutate(GCmensal=(P35/P36)*(10/4.5))

#grau de cumprimento atual
dados2=dados2%>%group_by(unidade)%>%mutate(GCatual=last(Gcacumulado))

#Iconc mensal
dados2=dados2%>%mutate(Iconc_Mensal=P35/P36)

#Iconc acumulado
dados2=as.data.frame(dados2%>%group_by(unidade)%>%mutate(Iconc_Acumulado=cumsum(P35)/cumsum(P36)))
dados2[is.na(dados2)]=0

meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(dados2)[1]


for(i in 1:max(dados2$mês)){
  a=which(dados2$mês==i)
  aux[a]=meses[i]
}


dados2$mes_nomes=aux


dados2$Instância<-"TRT total"

dados2<-as.data.frame(dados2)