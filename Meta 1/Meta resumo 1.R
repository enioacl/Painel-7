#RESUMO META 1


# 'dataset' tem os dados de entrada para este script
require(readxl)
require(dplyr)
dados<-dataset

dados<-dados%>%select(sort(names(.)))
names(dados)<-c("Inst�ncia","m�s","Pergunta","quant","Unidade")
dados<-dados%>%select(m�s,Pergunta,Inst�ncia,quant)


#Primeira Inst�ncia
inst1_p11<-dados%>%filter(Pergunta=="P11" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p11)<-c("m�s","P11")
inst1_p13<-dados%>%filter(Pergunta=="P13" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p13)<-c("m�s","P13")
inst1_p17<-dados%>%filter(Pergunta=="P17" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p17)<-c("m�s","P17")
inst1_p19<-dados%>%filter(Pergunta=="P19" & Inst�ncia=="Primeira")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst1_p19)<-c("m�s","P19")

primeira_inst<-full_join(inst1_p11, inst1_p13, by="m�s")%>%full_join(.,inst1_p17, by="m�s")%>%full_join(.,inst1_p19, by="m�s")
primeira_inst[is.na(primeira_inst)]=0


require(lubridate)
require(data.table)
##############################
############################
#####meses=1:month(floor_date(Sys.Date() - months(1), "month")) # at� o m�s anterior ao atual
meses<-1:12
combin<-data.frame(m�s=meses,P11=rep(0,length(meses)),P13=rep(0,length(meses)),P17=rep(0,length(meses)),P19=rep(0,length(meses)))


require(prodlim)
pos=which(is.na(row.match(as.data.frame(combin$m�s),as.data.frame(primeira_inst$m�s))))
primeira_inst<-rbind(primeira_inst,combin[pos,])%>%arrange(m�s)

primeira_inst$Inst�ncia<-rep("Primeira",dim(primeira_inst)[1])

#multiplicado por 100 para colocar em porcentagem no power bi
#Grau de cumprimento acumulado
primeira_inst<-primeira_inst%>%mutate(GCacumulado=(cumsum(P13)/(cumsum(P11)+1+cumsum(P17)-cumsum(P19))))

#Grau de cumprimento mensal
primeira_inst<-primeira_inst%>%mutate(GCmensal=(P13/(P11+1+P17-P19)))

#Grau de cumprimento atual
primeira_inst$GCatual<-rep(last(primeira_inst$GCacumulado),dim(primeira_inst)[1])


primeira_inst[is.na(primeira_inst)]=0



#Segunda inst�ncia
inst2_p11<-dados%>%filter(Pergunta=="P11" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p11)<-c("m�s","P11")
inst2_p13<-dados%>%filter(Pergunta=="P13" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p13)<-c("m�s","P13")
inst2_p15<-dados%>%filter(Pergunta=="P15" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p15)<-c("m�s","P15")
inst2_p17<-dados%>%filter(Pergunta=="P17" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p17)<-c("m�s","P17")
inst2_p19<-dados%>%filter(Pergunta=="P19" & Inst�ncia=="Segunda")%>%group_by(m�s)%>%summarise(quant=sum(quant))
names(inst2_p19)<-c("m�s","P19")

segunda_inst<-full_join(inst2_p11, inst2_p13, by="m�s")%>%full_join(.,inst2_p15, by="m�s")%>%full_join(.,inst2_p17, by="m�s")%>%full_join(.,inst2_p19, by="m�s")
segunda_inst[is.na(segunda_inst)]=0



combin2<-data.frame(m�s=meses,P11=rep(0,length(meses)),P13=rep(0,length(meses)),P15=rep(0,length(meses)),P17=rep(0,length(meses)),P19=rep(0,length(meses)))
pos2=which(is.na(row.match(as.data.frame(combin2$m�s),as.data.frame(segunda_inst$m�s))))
segunda_inst<-rbind(segunda_inst,combin2[pos2,])%>%arrange(m�s)
segunda_inst$Inst�ncia<-rep("Segunda",dim(segunda_inst)[1])


#Grau de cumprimento acumulado
segunda_inst<-segunda_inst%>%mutate(GCacumulado=(cumsum(P13)/(cumsum(P11)+1-cumsum(P15)+cumsum(P17)-cumsum(P19))))

#Grau de cumprimento mensal
segunda_inst<-segunda_inst%>%mutate(GCmensal=(P13/(P11+1-P15+P17-P19)))

#Grau de cumprimento atual
segunda_inst$GCatual<-rep(last(segunda_inst$GCacumulado),dim(segunda_inst)[1])

segunda_inst[is.na(segunda_inst)]=0

#TRT total
primeira_inst2<-primeira_inst%>%mutate(P15=rep(0,dim(primeira_inst)[1]))
TRT_total<-rbind(primeira_inst2, segunda_inst)%>%group_by(m�s)%>%summarise(P11=sum(P11),P13=sum(P13),P15=sum(P15),P17=sum(P17),P19=sum(P19))

#Grau de cumprimento acumulado
TRT_total<-TRT_total%>%mutate(GCacumulado=(cumsum(P13)/(cumsum(P11)+1-cumsum(P15)+cumsum(P17)-cumsum(P19))))

#Grau de cumprimento mensal
TRT_total<-TRT_total%>%mutate(GCmensal=(P13/(P11+1-P15+P17-P19)))

#Grau de cumprimento atual
TRT_total$GCatual<-rep(last(TRT_total$GCacumulado),dim(TRT_total)[1])

TRT_total$Inst�ncia<-"TRT total"

TRT_total[is.na(TRT_total)]=0


Final<-rbind(primeira_inst2,segunda_inst,TRT_total)


meses=c("janeiro","fevereiro","mar�o","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro")


aux=1:dim(Final)[1]


for(i in 1:max(Final$m�s)){
  a=which(Final$m�s==i)
  aux[a]=meses[i]
}


Final$mes_nomes=aux