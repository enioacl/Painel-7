require(readxl)
require(dplyr)
dados<-dataset
dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Inst�ncia","m�s","Pergunta","quant","Unidade")
dados<-dados%>%select(m�s,Inst�ncia,Pergunta,quant)



dados$quant <- as.numeric(dados$quant)
dados$quant[is.na(dados$quant)]=0
dados$m�s <- as.numeric(dados$m�s)


# Primeira Inst�ncia
inst1_p21<-as.numeric(dados%>%filter(Pergunta=="P21" & Inst�ncia=="Primeira")%>%select(quant)%>%summarise(sum(quant)))
inst1_p24<-dados%>%filter(Pergunta=="P24" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p24)=c("m�s","P24")
inst1_p27<-dados%>%filter(Pergunta=="P27" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p27)=c("m�s","P27")
inst1_p210<-dados%>%filter(Pergunta=="P210" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p210)=c("m�s","P210")
inst1_p213<-as.numeric(dados%>%filter(Pergunta=="P213" & Inst�ncia=="Primeira")%>%select(quant)%>%summarise(sum(quant)))

primeira_inst<-full_join(inst1_p24, inst1_p27, by="m�s")%>%full_join(.,inst1_p210,by="m�s")
primeira_inst[is.na(primeira_inst)]=0
primeira_inst<-primeira_inst%>%mutate(P21=inst1_p21)
primeira_inst<-primeira_inst%>%mutate(P213=inst1_p213)


require(lubridate)
require(data.table)

##############################
############################
#####meses=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
meses<-1:12
combin<-data.frame(m�s=meses,P21=inst1_p21,P24=rep(0,length(meses)),P27=rep(0,length(meses)),P210=rep(0,length(meses)), P213=inst1_p213)


require(prodlim)
pos=which(is.na(row.match(as.data.frame(combin$m�s),as.data.frame(primeira_inst$m�s))))
primeira_inst<-rbind(primeira_inst,combin[pos,])%>%arrange(m�s)

primeira_inst$Inst�ncia<-rep("Primeira",dim(primeira_inst)[1])
primeira_inst<-as.data.frame(arrange(primeira_inst,m�s))

#Grau de cumprimento acumulado
primeira_inst<-primeira_inst%>%mutate(GCacumulado=((cumsum(P210)+P213)/(P21+P213+cumsum(P24)-cumsum(P27)))*(10/9.2))

#Grau de cumprimento mensal
primeira_inst<-primeira_inst%>%mutate(GCmensal=((P210+P213)/(P21+P213+P24-P27))*(10/9.2))

#Grau de cumprimento atual
primeira_inst$Gcatual<-rep(last(primeira_inst$GCacumulado),dim(primeira_inst)[1])

primeira_inst[is.na(primeira_inst)]=0

# Segunda Inst�ncia
inst2_p21<-as.numeric(dados%>%filter(Pergunta=="P21" & Inst�ncia=="Segunda")%>%select(quant))
inst2_p24<-dados%>%filter(Pergunta=="P24" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p24)=c("m�s","P24")
inst2_p27<-dados%>%filter(Pergunta=="P27" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p27)=c("m�s","P27")
inst2_p210<-dados%>%filter(Pergunta=="P210" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p210)=c("m�s","P210")
inst2_p213<-as.numeric(dados%>%filter(Pergunta=="P213" & Inst�ncia=="Segunda")%>%select(quant))

segunda_inst <- full_join(inst2_p24, inst2_p27, by="m�s")%>%full_join(.,inst2_p210, by="m�s")
segunda_inst[is.na(segunda_inst)]=0
segunda_inst<-segunda_inst%>%mutate(P21=inst2_p21)
segunda_inst<-segunda_inst%>%mutate(P213=inst2_p213)




combin2<-data.frame(m�s=meses,P21=inst2_p21,P24=rep(0,length(meses)),P27=rep(0,length(meses)),P210=rep(0,length(meses)),P213=inst2_p213)
pos2=which(is.na(row.match(as.data.frame(combin2$m�s),as.data.frame(segunda_inst$m�s))))
segunda_inst<-rbind(segunda_inst,combin2[pos2,])%>%arrange(m�s)
segunda_inst$Inst�ncia<-rep("Segunda",dim(segunda_inst)[1])
segunda_inst<-as.data.frame(arrange(segunda_inst,m�s))

#Grau de cumprimento acumulado
segunda_inst<-segunda_inst%>%mutate(GCacumulado=((cumsum(P210)+P213)/(P21+P213+cumsum(P24)-cumsum(P27)))*(10/9.2))

#Grau de cumprimento mensal
segunda_inst<-segunda_inst%>%mutate(GCmensal=((P210+P213)/(P21+P213+P24-P27))*(10/9.2))

#Grau de cumprimento atual
segunda_inst$Gcatual<-rep(last(segunda_inst$GCacumulado),dim(segunda_inst)[1])

segunda_inst[is.na(segunda_inst)]=0

#TRT total
TRT_total<-rbind(primeira_inst, segunda_inst)%>%group_by(m�s)%>%summarise(P24=sum(P24),P27=sum(P27),P210=sum(P210))
TRT_total$P21<-inst1_p21+inst2_p21
TRT_total$P213<-inst1_p213+inst2_p213

TRT_total<-as.data.frame(arrange(TRT_total,m�s))

#Grau de cumprimento acumulado
TRT_total<-TRT_total%>%mutate(GCacumulado=((cumsum(P210)+P213)/(P21+P213+cumsum(P24)-cumsum(P27)))*(10/9.2))

#Grau de cumprimento mensal
TRT_total<-TRT_total%>%mutate(GCmensal=((P210+P213)/(P21+P213+P24-P27))*(10/9.2))

#Grau de cumprimento atual
TRT_total$Gcatual<-rep(last(TRT_total$GCacumulado),dim(TRT_total)[1])

TRT_total[is.na(TRT_total)]=0
TRT_total$Inst�ncia="TRT total"

final<-as.data.frame(rbind(primeira_inst,segunda_inst,TRT_total))


meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(final)[1]


for(i in 1:max(final$m�s)){
  a=which(final$m�s==i)
  aux[a]=meses[i]
}


final$mes_nomes=aux