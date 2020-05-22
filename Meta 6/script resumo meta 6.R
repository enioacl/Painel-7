#Resumo meta 6

require(dplyr)
require(readxl)
dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)=c("Instância","mês","Pergunta","quant","unidade")
dados<-dados%>%select(-unidade)
dados$mês<-as.numeric(dados$mês)
dados$quant<-as.numeric(dados$quant); dados$quant[is.na(dados$quant)]=0



################################################################
#primeira instância

inst1_p61<-as.numeric(dados%>%filter(Instância=="Primeira" & Pergunta=="P61")%>%select(quant)%>%summarise(sum(quant)))

inst1_p62<-as.data.frame(dados%>%filter(Instância=="Primeira" & Pergunta=="P62")%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant))
names(inst1_p62)=c("mês","P62")

inst1_p63<-dados%>%filter(Instância=='Primeira' & Pergunta=='P63')%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant)
names(inst1_p63)=c("mês","P63")


inst1_p64<-dados%>%filter(Instância=="Primeira" & Pergunta=="P64")%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant)
names(inst1_p64)=c("mês","P64")

inst1_p65<-as.numeric(dados%>%filter(Instância=='Primeira' & Pergunta=='P65')%>%select(quant)%>%summarise(sum(quant)))


primeira_inst<-full_join(inst1_p62,inst1_p63,by="mês")%>%full_join(.,inst1_p64,by="mês")
primeira_inst[is.na(primeira_inst)]=0

primeira_inst<-as.data.frame(primeira_inst%>%group_by(mês)%>%summarise(P62=sum(P62),P63=sum(P63),P64=sum(P64)))%>%ungroup()
primeira_inst<-arrange(primeira_inst,mês)


require(lubridate)
require(data.table)
##############################
############################

meses=1:month(floor_date(Sys.Date() - months(1), "month")) # até o mês anterior ao atual
#meses<-1:12
combin<-data.frame(mês=meses,P62=rep(0,length(meses)),P63=rep(0,length(meses)),P64=rep(0,length(meses)))

require(prodlim)
pos=which(is.na(row.match(as.data.frame(combin$mês),as.data.frame(primeira_inst$mês))))
primeira_inst<-rbind(primeira_inst,combin[pos,])%>%arrange(mês)
primeira_inst$P61<-inst1_p61
primeira_inst$P65<-inst1_p65
primeira_inst$Instância<-"Primeira"



#Grau de cumprimento acumulado
primeira_inst=primeira_inst%>%mutate(GC_acumulado=(cumsum(P64)+P65)/(P61+P65+cumsum(P62)-cumsum(P63))*(10/9.5))%>%arrange(mês)

#Graud e cumprimento mensal
primeira_inst$GC_mensal=((primeira_inst$P64+primeira_inst$P65)/(primeira_inst$P61+primeira_inst$P65+primeira_inst$P62-primeira_inst$P63)*(10/9.5))

#Grau de cumprimento atual
primeira_inst<-primeira_inst%>%mutate(GC_atual=last(GC_acumulado))



#################################################################
#Segunda instância
inst2_p61<-as.numeric(dados%>%filter(Instância=='Segunda' & Pergunta=='P61')%>%select(quant))
inst2_p62<-dados%>%filter(Instância=='Segunda' & Pergunta=='P62')%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant)
names(inst2_p62)<-c("mês","P62")


inst2_p63<-dados%>%filter(Instância=='Segunda' & Pergunta=='P63')%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant)
names(inst2_p63)<-c("mês","P63") 


inst2_p64<-dados%>%filter(Instância=='Segunda' & Pergunta=='P64')%>%group_by(mês)%>%summarise(quant=sum(quant))%>%select(mês,quant)
names(inst2_p64)<-c("mês","P64")

inst2_p65<-as.numeric(dados%>%filter(Instância=='Segunda' & Pergunta=='P65')%>%select(quant))


segunda_inst<-full_join(inst2_p62,inst2_p63,by="mês")%>%full_join(.,inst2_p64,by="mês")
segunda_inst[is.na(segunda_inst)]<-0


pos2=which(is.na(row.match(as.data.frame(combin$mês),as.data.frame(segunda_inst$mês))))
segunda_inst<-rbind(segunda_inst,combin[pos2,])%>%arrange(mês)
segunda_inst$P61<-inst2_p61
segunda_inst$P65<-inst2_p65
segunda_inst$Instância<-"Segunda"



#Grau de cumprimento acumulado
segunda_inst<-segunda_inst%>%mutate(GC_acumulado=(cumsum(P64)+P65)/(P61+P65+cumsum(P62)-cumsum(P63))*(10/9.5))

#Grau de cumprimento mensal
segunda_inst$GC_mensal<-((segunda_inst$P64+segunda_inst$P65)/(segunda_inst$P61+segunda_inst$P65+segunda_inst$P62-segunda_inst$P63)*(10/9.5))

#Grau de cumprimento atual
segunda_inst<-segunda_inst%>%mutate(GC_atual=last(GC_acumulado))



##########################################################
#TRT total
trt_total<-rbind(primeira_inst%>%select(mês,P61,P62,P63,P64,P65),segunda_inst%>%select(mês,P61,P62,P63,P64,P65))
trt_total<-as.data.frame(trt_total%>%group_by(mês)%>%summarise(P62=sum(P62),P63=sum(P63),P64=sum(P64),P61=sum(P61),P65=sum(P65))%>%ungroup()%>%arrange(mês))
trt_total$Instância<-"TRT total"


#Grau de cumprimento acumulado
trt_total<-trt_total%>%mutate(GC_acumulado=(cumsum(P64)+P65)/(P61+P65+cumsum(P62)-cumsum(P63))*(10/9.5))

#Grau de cumprimento mensal
trt_total$GC_mensal<-((trt_total$P64+trt_total$P65)/(trt_total$P61+trt_total$P65+trt_total$P62-trt_total$P63)*(10/9.5))

#Grau de cumprimento atual
trt_total<-trt_total%>%mutate(GC_atual=last(GC_acumulado))


#BD final
resumo_meta6<-rbind(primeira_inst,segunda_inst,trt_total)

resumo_meta6$GC_acumulado[is.infinite(resumo_meta6$GC_acumulado)]<-1
resumo_meta6$GC_mensal[is.infinite(resumo_meta6$GC_mensal)]<-1
resumo_meta6$GC_acumulado[is.na(resumo_meta6$GC_acumulado)]<-1
resumo_meta6$GC_mensal[is.na(resumo_meta6$GC_mensal)]<-1
resumo_meta6$GC_atual[is.infinite(resumo_meta6$GC_atual)]<-1
resumo_meta6$GC_atual[is.na(resumo_meta6$GC_atual)]<-1

meses=c("janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(resumo_meta6)[1]


for(i in 1:max(resumo_meta6$mês)){
  a=which(resumo_meta6$mês==i)
  aux[a]=meses[i]
}


resumo_meta6$mes_nomes=aux
