# 'dataset' tem os dados de entrada para este script
require(dplyr)

require(prodlim)
require(data.table)
require(lubridate)

dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Inst�ncia","m�s","quant","soma","Unidade")
dados<-dados%>%select(m�s,quant,soma,Inst�ncia)
dados$m�s<-as.numeric(dados$m�s)
dados$quant<-as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$soma<-as.numeric(dados$soma)
dados$soma[is.na(dados$soma)]=0
dados<-as.data.frame(dados)

#####meses=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual

meses<-1:12
combin<-data.frame(m�s=meses,quant=0,soma=0)

#trt primeira inst�ncia
inst1_tmdp<-dados%>%filter(Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$m�s),as.data.frame(inst1_tmdp$m�s))))
inst1_tmdp<-rbind(inst1_tmdp,combin[pos,])%>%arrange(m�s)

inst1_tmdp$Inst�ncia<-"Primeira"



#Grau de cumprimento acumulado
inst1_tmdp<-inst1_tmdp%>%mutate(GC_acumulado=cumsum(soma)/cumsum(quant))

#Grau de cumprimento mensal
inst1_tmdp<-inst1_tmdp%>%mutate(GC_mensal=soma/quant)

#Grau de cumprimento atual
inst1_tmdp<-inst1_tmdp%>%mutate(GC_atual=last(GC_acumulado))


##trt segunda inst�ncia
inst2_tmdp<-dados%>%filter(Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$m�s),as.data.frame(inst2_tmdp$m�s))))
inst2_tmdp<-rbind(inst2_tmdp,combin[pos,])%>%arrange(m�s)

inst2_tmdp$Inst�ncia<-"Segunda"


#Grau de cumprimento acumulado
inst2_tmdp<-inst2_tmdp%>%mutate(GC_acumulado=(cumsum(soma)/cumsum(quant)))

#Grau de cumprimento mensal
inst2_tmdp<-inst2_tmdp%>%mutate(GC_mensal=(soma/quant))

#Grau de cumprimento atual
inst2_tmdp<-inst2_tmdp%>%mutate(GC_atual=last(GC_acumulado))


#trt total
trt_total<-dados%>%group_by(m�s)%>%summarise(quant=sum(quant), soma=sum(soma))

pos=which(is.na(row.match(as.data.frame(combin$m�s),as.data.frame(trt_total$m�s))))
trt_total<-rbind(trt_total,combin[pos,])%>%arrange(m�s)

trt_total$Inst�ncia<-"TRT total"

#Grau de cumprimento acumulado
trt_total<-trt_total%>%mutate(GC_acumulado=cumsum(soma)/cumsum(quant))

#Grau de cumprimento mensal
trt_total<-trt_total%>%mutate(GC_mensal=soma/quant)

#Grau de cumprimento atual
trt_total<-trt_total%>%mutate(GC_atual=last(GC_acumulado))



final<-rbind(inst1_tmdp,inst2_tmdp,trt_total)


meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(final)[1]


for(i in 1:max(final$m�s)){
  a=which(final$m�s==i)
  aux[a]=meses[i]
}


final$mes_nomes=aux


final<-final%>%mutate(meta=case_when(Inst�ncia=="Primeira"~148, Inst�ncia=="Segunda"~137, Inst�ncia=="TRT total"~140))



final$GC_tmdp2<-final$meta/final$GC_acumulado

final<-as.data.frame(final)