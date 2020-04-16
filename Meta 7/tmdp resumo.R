# 'dataset' tem os dados de entrada para este script


#Resumo meta 7
#dados<-read.table(file.choose(),  sep ="\t", header = TRUE)
require(dplyr)
dados<-dataset

dados<-dados%>%select(sort(names(.)))
names(dados)[c(1,2,5)]=c("Instância","mes","Pergunta")
dados<-dados%>%select(mes,Instância,Pergunta)
dados$mes<-as.numeric(dados$mes)
dados$Instância<-as.character(dados$Instância)
dados$Pergunta<-as.character(dados$Pergunta)

################################################################
#primeira instância

P73_prim<-dados%>%filter(Instância=="Primeira" & Pergunta=="P7.3")%>%summarise(P73=length(mes))%>%select(P73)
P73_prim$P73<-as.numeric(P73_prim$P73)

P74_prim<-dados%>%filter(Instância=="Primeira" & Pergunta=="P7.4")%>%group_by(mes)%>%summarise(P74=length(mes))%>%select(mes,P74)
P74_prim$P74<-as.numeric(P74_prim$P74)

P75_prim<-dados%>%filter(Instância=='Primeira' & Pergunta=='P7.5')%>%group_by(mes)%>%summarise(P75=length(mes))%>%select(mes,P75)
P75_prim$P75<-as.numeric(P75_prim$P75)

P76_prim<-dados%>%filter(Instância=='Primeira' & Pergunta=='P7.6')%>%group_by(mes)%>%summarise(P76=length(mes))%>%select(mes,P76)
P76_prim$P76<-as.numeric(P76_prim$P76)

P77_prim<-dados%>%filter(Instância=='Primeira' & Pergunta=='P7.7')%>%group_by(mes)%>%summarise(P77=length(mes))%>%select(mes,P77)
P77_prim$P77<-as.numeric(P77_prim$P77)


primeira_inst<-full_join(P74_prim,P75_prim,by="mes")%>%full_join(.,P76_prim,by="mes")%>%full_join(.,P77_prim,by="mes")
primeira_inst[is.na(primeira_inst)]=0

#primeira_inst<-as.data.frame(primeira_inst%>%group_by(mes)%>%summarise(P62=sum(P62),P63=sum(P63),P64=sum(P64)))%>%ungroup()
#primeira_inst<-arrange(primeira_inst,mês)


require(lubridate)
require(data.table)
##############################
############################
meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
#meses<-1:12
combin<-data.frame(mes=meses,P74=rep(0,length(meses)),P75=rep(0,length(meses)),P76=rep(0,length(meses)),P77=rep(0,length(meses)))


require(prodlim)
pos=which(is.na(row.match(as.data.frame(combin$mes),as.data.frame(primeira_inst$mes))))
primeira_inst<-rbind(primeira_inst,combin[pos,])%>%arrange(mes)
primeira_inst$P73<-P73_prim$P73
primeira_inst$Instância<-"Primeira"



#Grau de cumprimento acumulado
primeira_inst=primeira_inst%>%mutate(GC_acumulado=P73*0.98/(P73+cumsum(P74)+cumsum(P75)-cumsum(P76)-cumsum(P77)))%>%arrange(mes)

#Graud e cumprimento mensal
primeira_inst<-primeira_inst%>%mutate(GC_mensal=P73*0.98/(P73+P74+P75-P76-P77))

#Grau de cumprimento atual
primeira_inst<-primeira_inst%>%mutate(GC_atual=last(GC_acumulado))


#################################################################
#Segunda instância

P73_seg<-dados%>%filter(Instância=="Segunda" & Pergunta=="P7.3")%>%summarise(P73=length(mes))%>%select(P73)
P73_seg$P73<-as.numeric(P73_seg$P73)

P74_seg<-dados%>%filter(Instância=="Segunda" & Pergunta=="P7.4")%>%group_by(mes)%>%summarise(P74=length(mes))%>%select(mes,P74)
P74_seg$P74<-as.numeric(P74_seg$P74)

P75_seg<-dados%>%filter(Instância=="Segunda" & Pergunta=='P7.5')%>%group_by(mes)%>%summarise(P75=length(mes))%>%select(mes,P75)
P75_seg$P75<-as.numeric(P75_seg$P75)

P76_seg<-dados%>%filter(Instância=="Segunda" & Pergunta=='P7.6')%>%group_by(mes)%>%summarise(P76=length(mes))%>%select(mes,P76)
P76_seg$P76<-as.numeric(P76_seg$P76)

P77_seg<-dados%>%filter(Instância=="Segunda" & Pergunta=='P7.7')%>%group_by(mes)%>%summarise(P77=length(mes))%>%select(mes,P77)
P77_seg$P77<-as.numeric(P77_seg$P77)


segunda_inst<-full_join(P74_seg,P75_seg,by="mes")%>%full_join(.,P76_seg,by="mes")%>%full_join(.,P77_seg,by="mes")
segunda_inst[is.na(segunda_inst)]=0



pos2=which(is.na(row.match(as.data.frame(combin$mes),as.data.frame(segunda_inst$mes))))
segunda_inst<-rbind(segunda_inst,combin[pos2,])%>%arrange(mes)
segunda_inst$P73<-P73_seg$P73
segunda_inst$Instância<-"Segunda"



#Grau de cumprimento acumulado
segunda_inst<-segunda_inst%>%mutate(GC_acumulado=P73*0.98/(P73+cumsum(P74)+cumsum(P75)-cumsum(P76)-cumsum(P77)))

#Grau de cumprimento mensal
segunda_inst<-segunda_inst%>%mutate(GC_mensal=P73*0.98/(P73+P74+P75-P76-P77))

#Grau de cumprimento atual
segunda_inst<-segunda_inst%>%mutate(GC_atual=last(GC_acumulado))

##########################################################
#TRT total
trt_total<-rbind(primeira_inst%>%select(mes,P73,P74,P75,P76,P77),segunda_inst%>%select(mes,P73,P74,P75,P76,P77))
trt_total<-as.data.frame(trt_total%>%group_by(mes)%>%summarise(P73=sum(P73),P74=sum(P74),P75=sum(P75),P76=sum(P76),P77=sum(P77))%>%ungroup()%>%arrange(mes))
trt_total$Instância<-"TRT total"


#Grau de cumprimento acumulado
trt_total<-trt_total%>%mutate(GC_acumulado=P73*0.98/(P73+cumsum(P74)+cumsum(P75)-cumsum(P76)-cumsum(P77)))

#Grau de cumprimento mensal
trt_total<-trt_total%>%mutate(GC_mensal=P73*0.98/(P73+P74+P75-P76-P77))

#Grau de cumprimento atual
trt_total<-trt_total%>%mutate(GC_atual=last(GC_acumulado))


#BD final
resumo_meta7<-rbind(primeira_inst,segunda_inst,trt_total)


meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")

aux=1:dim(resumo_meta7)[1]

for(i in 1:max(resumo_meta7$mes)){
  a=which(resumo_meta7$mes==i)
  aux[a]=meses[i]
}


resumo_meta7$mes_nomes=aux


resumo_meta7$GC_acumulado[is.infinite(resumo_meta7$GC_acumulado)]<-1
resumo_meta7$GC_acumulado[is.na(resumo_meta7$GC_acumulado)]<-1
resumo_meta7$GC_mensal[is.infinite(resumo_meta7$GC_mensal)]<-1
resumo_meta7$GC_mensal[is.na(resumo_meta7$GC_mensal)]<-1
resumo_meta7$GC_atual[is.infinite(resumo_meta7$GC_atual)]<-1
resumo_meta7$GC_atual[is.na(resumo_meta7$GC_atual)]<-1

