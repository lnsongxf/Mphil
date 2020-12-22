install.packages("electionsBR")
install.packages("dplyr")
library(electionsBR)
library(dplyr)
anos <- seq(2004, 2016, by = 4)
dados <- lapply(anos, candidate_local)

######################################
# ANO 2004                           #
######################################

# Salva a lista de municípios (de forma não duplicada) em uma nova variável
mun<-unique(dados[[1]]$DESCRICAO_UE)

mun2 <- mun[1:10]

ano<-rep(2004, length(mun))
ano<-rep(2004, length(mun2))

# Cria as variáveis vazias
mulher_ver<-rep(0,length(mun))
total_ver<-rep(0,length(mun))
mulher_ele<-rep(0,length(mun))
total_ele<-rep(0,length(mun))


mulher_ver<-rep(0,length(mun2))
total_ver<-rep(0,length(mun2))
mulher_ele<-rep(0,length(mun2))
total_ele<-rep(0,length(mun2))



for (i in 1:length(mun2)){
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1

  mulher_ver[i]<-length(which(dados[[1]]$DESCRICAO_UE == mun[i] 
                         & dados[[1]]$CODIGO_SEXO == 4 
                         & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                         & dados[[1]]$CODIGO_CARGO == 13 
                         & dados[[1]]$NUM_TURNO == 1))

  # Conta o total de candidatos  
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  total_ver[i] <- length(which(dados[[1]]$DESCRICAO_UE == mun[i] 
                             & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[1]]$CODIGO_CARGO == 13 
                             & dados[[1]]$NUM_TURNO == 1))
  
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitas -- COD_SIT_TOT_TURNO == 1 --------- ISSO ESTÁ ERRADO
  
  mulher_ele[i]<-length(which(dados[[1]]$DESCRICAO_UE == mun[i] 
                              & dados[[1]]$CODIGO_SEXO == 4 
                              & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[1]]$CODIGO_CARGO == 13 
                              & dados[[1]]$NUM_TURNO == 1)
                              & dados[[1]]$COD_SIT_TOT_TURNO == 1)
  
  # Conta o total de pessoas 
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitos -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[1]]$DESCRICAO_UE == mun[i] 
                              & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[1]]$CODIGO_CARGO == 13 
                              & dados[[1]]$NUM_TURNO == 1)
                              & dados[[1]]$COD_SIT_TOT_TURNO == 1)
}

eleicoes_2004<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)
eleicoes_2004<-as.data.frame(eleicoes_2004)
head(eleicoes_2004)

######################################
# ANO 2008                           #
######################################

# Salva a lista de municípios (de forma não duplicada) em uma nova variável
mun<-unique(dados[[2]]$DESCRICAO_UE)
ano<-rep(2008, length(mun))

# Cria as variáveis vazias
mulher_ver<-rep(0,length(mun))
total_ver<-rep(0,length(mun))
mulher_ele<-rep(0,length(mun))
total_ele<-rep(0,length(mun))

for (i in 1:length(mun)){
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  
  mulher_ver[i]<-length(which(dados[[2]]$DESCRICAO_UE == mun[i] 
                              & dados[[2]]$CODIGO_SEXO == 4 
                              & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[2]]$CODIGO_CARGO == 13 
                              & dados[[2]]$NUM_TURNO == 1))
  
  # Conta o total de candidatos  
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  total_ver[i] <- length(which(dados[[2]]$DESCRICAO_UE == mun[i] 
                               & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[2]]$CODIGO_CARGO == 13 
                               & dados[[2]]$NUM_TURNO == 1))
  
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitas -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[2]]$DESCRICAO_UE == mun[i] 
                              & dados[[2]]$CODIGO_SEXO == 4 
                              & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[2]]$CODIGO_CARGO == 13 
                              & dados[[2]]$NUM_TURNO == 1)
                              & dados[[2]]$COD_SIT_TOT_TURNO == 1)
  
  # Conta o total de pessoas 
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitos -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[2]]$DESCRICAO_UE == mun[i] 
                             & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[2]]$CODIGO_CARGO == 13 
                             & dados[[2]]$NUM_TURNO == 1)
                             & dados[[2]]$COD_SIT_TOT_TURNO == 1)
}


eleicoes_2008<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)

eleicoes_2008<-as.data.frame(eleicoes_2008)

head(eleicoes_2008)

######################################
# ANO 2012                           #
######################################

# Salva a lista de municípios (de forma não duplicada) em uma nova variável
mun<-unique(dados[[3]]$DESCRICAO_UE)
ano<-rep(2012, length(mun))

# Cria as variáveis vazias
mulher_ver<-rep(0,length(mun))
total_ver<-rep(0,length(mun))
mulher_ele<-rep(0,length(mun))
total_ele<-rep(0,length(mun))

for (i in 1:length(mun)){
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  
  mulher_ver[i]<-length(which(dados[[3]]$DESCRICAO_UE == mun[i] 
                              & dados[[3]]$CODIGO_SEXO == 4 
                              & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[3]]$CODIGO_CARGO == 13 
                              & dados[[3]]$NUM_TURNO == 1))
  
  # Conta o total de candidatos  
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  total_ver[i] <- length(which(dados[[3]]$DESCRICAO_UE == mun[i] 
                               & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[3]]$CODIGO_CARGO == 13 
                               & dados[[3]]$NUM_TURNO == 1))
  
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitas -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[3]]$DESCRICAO_UE == mun[i] 
                              & dados[[3]]$CODIGO_SEXO == 4 
                              & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[3]]$CODIGO_CARGO == 13 
                              & dados[[3]]$NUM_TURNO == 1)
                        & dados[[3]]$COD_SIT_TOT_TURNO == 1)
  
  # Conta o total de pessoas 
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitos -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[3]]$DESCRICAO_UE == mun[i] 
                             & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[3]]$CODIGO_CARGO == 13 
                             & dados[[3]]$NUM_TURNO == 1)
                             & dados[[3]]$COD_SIT_TOT_TURNO == 1)
}


eleicoes_2012<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)

eleicoes_2012<-as.data.frame(eleicoes_2012)

head(eleicoes_2012)

######################################
# ANO 2016                           #
######################################

# Salva a lista de municípios (de forma não duplicada) em uma nova variável
mun<-unique(dados[[4]]$DESCRICAO_UE)
ano<-rep(2016, length(mun))

# Cria as variáveis vazias
mulher_ver<-rep(0,length(mun))
total_ver<-rep(0,length(mun))
mulher_ele<-rep(0,length(mun))
total_ele<-rep(0,length(mun))

for (i in 1:length(mun)){
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  
  mulher_ver[i]<-length(which(dados[[4]]$DESCRICAO_UE == mun[i] 
                              & dados[[4]]$CODIGO_SEXO == 4 
                              & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[4]]$CODIGO_CARGO == 13 
                              & dados[[4]]$NUM_TURNO == 1))
  
  # Conta o total de candidatos  
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  total_ver[i] <- length(which(dados[[4]]$DESCRICAO_UE == mun[i] 
                               & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[4]]$CODIGO_CARGO == 13 
                               & dados[[4]]$NUM_TURNO == 1))
  
  # Conta o total de mulheres candidatas  -- CODIGO_SEXO == 4
  # a vereadoras no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitas -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[4]]$DESCRICAO_UE == mun[i] 
                              & dados[[4]]$CODIGO_SEXO == 4 
                              & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[4]]$CODIGO_CARGO == 13 
                              & dados[[4]]$NUM_TURNO == 1)
                        & dados[[4]]$COD_SIT_TOT_TURNO == 1)
  
  # Conta o total de pessoas 
  # a vereadores no município -- CODIGO_CARGO == 13 
  # com candidatura deferida -- COD_SITUACAO_CANDIDATURA == 2 
  # no primeiro turno  -- NUM_TURNO == 1
  # que foram eleitos -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[4]]$DESCRICAO_UE == mun[i] 
                             & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[4]]$CODIGO_CARGO == 13 
                             & dados[[4]]$NUM_TURNO == 1)
                       & dados[[4]]$COD_SIT_TOT_TURNO == 1)
}


eleicoes_2016<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)

eleicoes_2016<-as.data.frame(eleicoes_2016)

head(eleicoes_2016)

#####################################################################

# Juntando tudo em um arquivo só

eleicoes<-rbind(eleicoes_2004, eleicoes_2008, eleicoes_2012, eleicoes_2016)
