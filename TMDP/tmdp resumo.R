# 'dataset' tem os dados de entrada para este script
require(dplyr)

require(prodlim)
require(data.table)
require(lubridate)

dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Instância","mês","quant","soma","Unidade")
dados<-dados%>%select(mês,quant,soma,Instância)
dados$mês<-as.numeric(dados$mês)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$soma<-as.numeric(dados$soma)
dados$soma[is.na(dados$soma)]=0
dados<-as.data.frame(dados)

meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual

#meses<-1:12
combin<-data.frame(mês=meses,quant=0,soma=0)

#trt primeira instância
inst1_tmdp<-dados%>%filter(Instância=="Primeira")%>%group_by(mês)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$mês),as.data.frame(inst1_tmdp$mês))))
inst1_tmdp<-rbind(inst1_tmdp,combin[pos,])%>%arrange(mês)

inst1_tmdp$Instância<-"Primeira"



#Grau de cumprimento acumulado
inst1_tmdp<-inst1_tmdp%>%mutate(GC_acumulado=cumsum(soma)/cumsum(quant))

#Grau de cumprimento mensal
inst1_tmdp<-inst1_tmdp%>%mutate(GC_mensal=soma/quant)

#Grau de cumprimento atual
inst1_tmdp<-inst1_tmdp%>%mutate(GC_atual=last(GC_acumulado))


##trt segunda instância
inst2_tmdp<-dados%>%filter(Instância=="Segunda")%>%group_by(mês)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$mês),as.data.frame(inst2_tmdp$mês))))
inst2_tmdp<-rbind(inst2_tmdp,combin[pos,])%>%arrange(mês)

inst2_tmdp$Instância<-"Segunda"


#Grau de cumprimento acumulado
inst2_tmdp<-inst2_tmdp%>%mutate(GC_acumulado=(cumsum(soma)/cumsum(quant)))

#Grau de cumprimento mensal
inst2_tmdp<-inst2_tmdp%>%mutate(GC_mensal=(soma/quant))

#Grau de cumprimento atual
inst2_tmdp<-inst2_tmdp%>%mutate(GC_atual=last(GC_acumulado))


#trt total
trt_total<-dados%>%group_by(mês)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$mês),as.data.frame(trt_total$mês))))
trt_total<-rbind(trt_total,combin[pos,])%>%arrange(mês)

trt_total$Instância<-"TRT total"

#Grau de cumprimento acumulado
trt_total<-trt_total%>%mutate(GC_acumulado=cumsum(soma)/cumsum(quant))

#Grau de cumprimento mensal
trt_total<-trt_total%>%mutate(GC_mensal=soma/quant)

#Grau de cumprimento atual
trt_total<-trt_total%>%mutate(GC_atual=last(GC_acumulado))



final<-rbind(inst1_tmdp,inst2_tmdp,trt_total)


meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(final)[1]


for(i in 1:max(final$mês)){
  a=which(final$mês==i)
  aux[a]=meses[i]
}


final$mes_nomes=aux


final<-final%>%mutate(meta=case_when(Instância=="Primeira"~203, Instância=="Segunda"~131, Instância=="TRT total"~140))



final$GC_tmdp2<-final$meta/final$GC_acumulado

final<-as.data.frame(final)
