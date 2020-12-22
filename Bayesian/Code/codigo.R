###########################################################################
# Census Data
###########################################################################

# Load all packages used
library(readstata13)
library(readxl)
library(plyr)
library(electionsBR)
library(dplyr)

# Load the package and read the stata file with census data
censo <- read.dta13("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Exercícios\\data.dta")
head(censo)

# Read the IBGE file with municipalities' names and codes, drops unused columns and change column names
nomes_municipios <- read_excel("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Dados\\dtb_2010.xls")
head(nomes_municipios)
nomes_municipios<-nomes_municipios[,c(2,7,8)]
colnames(nomes_municipios)<-c("uf", "cod_munic", "nome_municipio")

# Merge data to get the correct names for municipalities and states, make some adjustments
# in the columns
censo_2<-merge(censo,nomes_municipios, by = "cod_munic", all.y=TRUE)
ncol(censo_2)
head(censo_2[,1:5])
censo_2[,3]<-censo_2[,310]
censo_2[,5]<-censo_2[,309]
censo_2<-censo_2[,1:308]
head(censo_2)

# Choose some variables from census to keep

variables<-c("ano", "cod_munic", "nome_municipio.x", "gini", "idhm", "idhm_e", "idhm_l",
             "idhm_r", "pop_rur", "pop_urb", "pop_total", "num_homens_total", "num_mulheres_total",
             "pia", "pea", "pop_ocup", "esperanca_anos_estudo", "expectativa_vida", 
             "num_empregos_formais", "numero_homicidios", "percentual_pobres", "percentual_pobres_criancas",
             "pib_pc", "taxa_fecundidade", "tx_analbabetismo", "pop_urb_proporcao",
             "pia_proporcao", "pop_ocup_proporcao", "ln_pop", "no", "ne", "se", "su",
             "co")
variables
head(censo_2)
censo_3<-censo_2[,variables]

# Verifying temporal stability of the selected variables
little_test<-censo_2[,c("cod_munic", "ano", "gini", "idhm", "esperanca_anos_estudo", "taxa_fecundidade", "pop_urb_proporcao")]
head(little_test)
summary(little_test[little_test$ano == 0,])
summary(little_test[little_test$ano == 1,])

little_testf<-melt(little_test, id.vars = c("cod_munic", "ano"), measure.vars = c("gini", "idhm", "esperanca_anos_estudo", "taxa_fecundidade", "pop_urb_proporcao"))

bp1 <- ggplot(little_testf[little_testf$variable == "gini",], aes(x = factor(ano), y=value, colour = factor(ano)))+
  geom_boxplot(width = .7) +
  xlab("") +
  ylab("Gini Index") +
  scale_x_discrete(labels=c("2000", "2010"))+
  theme_bw() +
  theme(axis.title = element_text(size = 10))+
  theme(legend.position = "none")
bp1

bp2 <- ggplot(little_testf[little_testf$variable == "idhm",], aes(x = factor(ano), y=value, colour = factor(ano)))+
  geom_boxplot(width = .7) +
  xlab("") +
  ylab("HDI") +
  scale_x_discrete(labels=c("2000", "2010"))+
  theme_bw() +
  theme(axis.title = element_text(size = 10))+
  theme(legend.position = "none")
bp2

bp3 <- ggplot(little_testf[little_testf$variable == "esperanca_anos_estudo",], aes(x = factor(ano), y=value, colour = factor(ano)))+
  geom_boxplot(width = .7) +
  xlab("") +
  ylab("Study (yrs)") +
  scale_x_discrete(labels=c("2000", "2010"))+
  theme_bw() +
  theme(axis.title = element_text(size = 10))+
  theme(legend.position = "none")
bp3

bp4 <- ggplot(little_testf[little_testf$variable == "taxa_fecundidade",], aes(x = factor(ano), y=value, colour = factor(ano)))+
  geom_boxplot(width = .7) +
  xlab("") +
  ylab("Fertility Rate") +
  scale_x_discrete(labels=c("2000", "2010"))+
  theme_bw() +
  theme(axis.title = element_text(size = 10))+
  theme(legend.position = "none")
bp4


bp5 <- ggplot(little_testf[little_testf$variable == "pop_urb_proporcao",], aes(x = factor(ano), y=value, colour = factor(ano), group = factor(ano)))+
  geom_boxplot(width = .7) +
  xlab("") +
  ylab("Urban Pop (%)") +
  scale_x_discrete(labels=c("2000", "2010"))+
  theme_bw() +
  theme(axis.title = element_text(size = 10))+
  theme(legend.position = "none")
bp5

pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Census-comparison.pdf", width = 5.7, height = 2.75)
gridExtra::grid.arrange(bp1, bp2, bp3, bp4, bp5, ncol=3)
dev.off()

# Choosing saving data from both census (just in case...)
censo_2002<-censo_3[censo_3$ano == 0,]
censo_2010<-censo_3[censo_3$ano == 1,]

# Saving only data from 2010 to use later
censo_3<-censo_3[censo_3$ano == 1]
head(censo_3)

###########################################################################
#    Electoral data (from TSE)
###########################################################################

# Get data from server (local elections from 2004 to 2016)
anos <- seq(2004, 2016, by = 4)
dados <- lapply(anos, candidate_local)

######################################
# YEAR: 2004                           #
######################################

head(dados[[1]])

# Create a list of cities without duplicates

mun<-unique(dados[[1]][c("DESCRICAO_UE", "SIGLA_UE", "SIGLA_UF")])

# Create auxiliary variables
ano<-rep(2004, nrow(mun))
mulher_ver<-rep(0,nrow(mun))
total_ver<-rep(0,nrow(mun))
mulher_ele<-rep(0,nrow(mun))
total_ele<-rep(0,nrow(mun))

# Start a long and inefficient proccess of counting people who match the desired characteristics

for (i in 1:nrow(mun)){
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
     #(this one is probably redundanct, but helps to avoid data with errors)

  mulher_ver[i]<-length(which(dados[[1]]$SIGLA_UE == mun[i,2] 
                         & dados[[1]]$CODIGO_SEXO == 4 
                         & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                         & dados[[1]]$CODIGO_CARGO == 13 
                         & dados[[1]]$NUM_TURNO == 1))

  # Counts the total number of candidates (both genders)
  # To city council -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
      #(this one is probably redundanct, but helps to avoid data with errors)
 
  total_ver[i] <- length(which(dados[[1]]$SIGLA_UE == mun[i,2] 
                             & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[1]]$CODIGO_CARGO == 13 
                             & dados[[1]]$NUM_TURNO == 1))
  
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
      #(this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[1]]$SIGLA_UE == mun[i,2]
                              & dados[[1]]$CODIGO_SEXO == 4 
                              & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[1]]$CODIGO_CARGO == 13 
                              & dados[[1]]$NUM_TURNO == 1
                              & dados[[1]]$COD_SIT_TOT_TURNO == 1))
  
  # Counts total candidates
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
  #(this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[1]]$SIGLA_UE == mun[i,2]
                              & dados[[1]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[1]]$CODIGO_CARGO == 13 
                              & dados[[1]]$NUM_TURNO == 1
                              & dados[[1]]$COD_SIT_TOT_TURNO == 1))
}

# Creates a data-frame with all variables that were calculated in the for loop
eleicoes_2004<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)
eleicoes_2004<-as.data.frame(eleicoes_2004)

head(eleicoes_2004)

######################################
# YEAR: 2008                         #
######################################

# Create a list of cities without duplicates
mun<-unique(dados[[2]][c("DESCRICAO_UE", "SIGLA_UE", "SIGLA_UF")])

# Create auxiliary variables
ano<-rep(2008, nrow(mun))
mulher_ver<-rep(0,nrow(mun))
total_ver<-rep(0,nrow(mun))
mulher_ele<-rep(0,nrow(mun))
total_ele<-rep(0,nrow(mun))

# Start a long and inefficient proccess of counting people who match the desired characteristics

for (i in 1:nrow(mun)){
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
        #(this one is probably redundanct, but helps to avoid data with errors)
  
  mulher_ver[i]<-length(which(dados[[2]]$SIGLA_UE == mun[i,2] 
                              & dados[[2]]$CODIGO_SEXO == 4 
                              & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[2]]$CODIGO_CARGO == 13 
                              & dados[[2]]$NUM_TURNO == 1))
  
  # Counts the total number of candidates (both genders)
  # To city council -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
       #(this one is probably redundanct, but helps to avoid data with errors)
  
  total_ver[i] <- length(which(dados[[2]]$SIGLA_UE == mun[i,2] 
                               & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[2]]$CODIGO_CARGO == 13 
                               & dados[[2]]$NUM_TURNO == 1))
  
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
        #(this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[2]]$SIGLA_UE == mun[i,2]  
                              & dados[[2]]$CODIGO_SEXO == 4 
                              & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[2]]$CODIGO_CARGO == 13 
                              & dados[[2]]$NUM_TURNO == 1
                              & dados[[2]]$COD_SIT_TOT_TURNO == 1))
  
  # Counts total candidates
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
      # (this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[2]]$SIGLA_UE == mun[i,2] 
                             & dados[[2]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[2]]$CODIGO_CARGO == 13 
                             & dados[[2]]$NUM_TURNO == 1
                             & dados[[2]]$COD_SIT_TOT_TURNO == 1))
}

# Creates a data-frame with all variables that were calculated in the for loop
eleicoes_2008<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)
eleicoes_2008<-as.data.frame(eleicoes_2008)

######################################
# YEAR: 2012                         #
######################################

# Create a list of cities without duplicates
mun<-unique(dados[[3]][c("DESCRICAO_UE", "SIGLA_UE", "SIGLA_UF")])

# Create auxiliary variables
ano<-rep(2012, nrow(mun))
mulher_ver<-rep(0,nrow(mun))
total_ver<-rep(0,nrow(mun))
mulher_ele<-rep(0,nrow(mun))
total_ele<-rep(0,nrow(mun))

# Start a long and inefficient proccess of counting people who match the desired characteristics
for (i in 1:nrow(mun)){
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
       #(this one is probably redundanct, but helps to avoid data with errors)
  
  mulher_ver[i]<-length(which(dados[[3]]$SIGLA_UE == mun[i,2]
                              & dados[[3]]$CODIGO_SEXO == 4 
                              & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[3]]$CODIGO_CARGO == 13 
                              & dados[[3]]$NUM_TURNO == 1))
  
  # Counts the total number of candidates (both genders)
  # To city council -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
        #(this one is probably redundanct, but helps to avoid data with errors)

  total_ver[i] <- length(which(dados[[3]]$SIGLA_UE == mun[i,2] 
                               & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[3]]$CODIGO_CARGO == 13 
                               & dados[[3]]$NUM_TURNO == 1))
  
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
      #(this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[3]]$SIGLA_UE == mun[i,2]
                              & dados[[3]]$CODIGO_SEXO == 4 
                              & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[3]]$CODIGO_CARGO == 13 
                              & dados[[3]]$NUM_TURNO == 1
                              & (dados[[3]]$COD_SIT_TOT_TURNO == 1 
                                      | dados[[3]]$COD_SIT_TOT_TURNO == 2 
                                      | dados[[3]]$COD_SIT_TOT_TURNO == 3)))
  
  # Counts total candidates
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
  # (this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[3]]$SIGLA_UE == mun[i,2] 
                             & dados[[3]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[3]]$CODIGO_CARGO == 13 
                             & dados[[3]]$NUM_TURNO == 1
                             & (dados[[3]]$COD_SIT_TOT_TURNO == 1 
                                | dados[[3]]$COD_SIT_TOT_TURNO == 2 
                                | dados[[3]]$COD_SIT_TOT_TURNO == 3)))
}



# Creates a data-frame with all variables that were calculated in the for loop
eleicoes_2012<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)
eleicoes_2012<-as.data.frame(eleicoes_2012)

head(eleicoes_2012)

######################################
# YEAR: 2016                         #
######################################

# Create a list of cities without duplicates
mun<-unique(dados[[4]][c("DESCRICAO_UE", "SIGLA_UE", "SIGLA_UF")])

# Create auxiliary variables
ano<-rep(2016, nrow(mun))
mulher_ver<-rep(0,nrow(mun))
total_ver<-rep(0,nrow(mun))
mulher_ele<-rep(0,nrow(mun))
total_ele<-rep(0,nrow(mun))

# Start a long and inefficient proccess of counting people who match the desired characteristics
for (i in 1:nrow(mun)){
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
       #(this one is probably redundanct, but helps to avoid data with errors)
  
  mulher_ver[i]<-length(which(dados[[4]]$SIGLA_UE == mun[i,2]  
                              & dados[[4]]$CODIGO_SEXO == 4 
                              & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[4]]$CODIGO_CARGO == 13 
                              & dados[[4]]$NUM_TURNO == 1))
  
  # Counts the total number of candidates (both genders)
  # To city council -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
       #(this one is probably redundanct, but helps to avoid data with errors)
  
  total_ver[i] <- length(which(dados[[4]]$SIGLA_UE == mun[i,2]  
                               & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                               & dados[[4]]$CODIGO_CARGO == 13 
                               & dados[[4]]$NUM_TURNO == 1))
  
  # Counts women candidates -- CODIGO_SEXO == 4
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
      #(this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  mulher_ele[i]<-length(which(dados[[4]]$SIGLA_UE == mun[i,2]  
                              & dados[[4]]$CODIGO_SEXO == 4 
                              & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                              & dados[[4]]$CODIGO_CARGO == 13 
                              & dados[[4]]$NUM_TURNO == 1
                              & (dados[[4]]$COD_SIT_TOT_TURNO == 1 
                                 | dados[[4]]$COD_SIT_TOT_TURNO == 2 
                                 | dados[[4]]$COD_SIT_TOT_TURNO == 3)))
  
  # Counts total candidates
  # To city council (câmara de vereadores) -- CODIGO_CARGO == 13
  # Whose candidatacy was accepted -- COD_SITUACAO_CANDIDATURA == 2
  # At first round  -- NUM_TURNO == 1
       # (this one is probably redundanct, but helps to avoid data with errors)
  # That were elected -- COD_SIT_TOT_TURNO == 1
  
  total_ele[i]<-length(which(dados[[4]]$SIGLA_UE == mun[i,2]  
                             & dados[[4]]$COD_SITUACAO_CANDIDATURA == 2 
                             & dados[[4]]$CODIGO_CARGO == 13 
                             & dados[[4]]$NUM_TURNO == 1
                             & (dados[[4]]$COD_SIT_TOT_TURNO == 1 
                                | dados[[4]]$COD_SIT_TOT_TURNO == 2 
                                | dados[[4]]$COD_SIT_TOT_TURNO == 3)))
}


# Creates a data-frame with all variables that were calculated in the for loop
eleicoes_2016<-cbind(mun, ano, mulher_ver, total_ver, mulher_ele, total_ele)
eleicoes_2016<-as.data.frame(eleicoes_2016)



# Merge all electoral data in one data.frame and saves in csv format

eleicoes<-rbind(eleicoes_2004, eleicoes_2008, eleicoes_2012, eleicoes_2016)

# Calculating the proportions

eleicoes$prop_cm <- round((eleicoes$mulher_ver/eleicoes$total_ver)*100,5)
eleicoes$prop_me <- round((eleicoes$mulher_ele/eleicoes$total_ele)*100,5)

eleicoes$ln_prop_cm<-ifelse(log(eleicoes$prop_cm)==-Inf, 0, log(eleicoes$prop_cm)) 
eleicoes$ln_prop_me<-ifelse(log(eleicoes$prop_me)==-Inf,0,log(eleicoes$prop_me))

write.csv(eleicoes, file = "C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\eleicoes.csv", quote = FALSE)

###############################################################################
# Merging everything
###############################################################################

# First, we put the TSE Key in census data (key from: https://github.com/tbrugz/ribge)
chave_mun<-read.csv("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Dados\\ibge-tse-map.csv")
head(chave_mun)
rownames(chave_mun)<-c("uf", "cod_munic", "cod_")
censo_4<- merge(censo_3, chave_mun, by.x = "cod_munic", by.y = "cod_municipio_ibge", all.x = TRUE)
head(censo_4)

# Now we merge with elections data

dados<-merge(eleicoes, censo_4, by.x = "SIGLA_UE", by.y = "cod_municipio_tse", all.x = TRUE)
head(dados)

# Save in one csv file and hope to never again have to re-do this calculations

write.csv(dados, file = "C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\dados_completos.csv", quote = FALSE)
fac
######################################################################################
# Database manipulation
######################################################################################

# Reading the csv file
dados<-read.csv("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\dados_completos.csv")

# Eliminates municipalities that for some reason has NA in their codes
# I made this by visual inspection because for some odd reason could't do using a more autonomous rotine
# 12 observations were dropped - they had only 3 data.
# I think the trouble was in the archives with keys from IBGE. Maybe they are new places, but I'll check them later.

summary(dados$cod_munic)
dados[is.na(dados$cod_munic),]
mun_drop <- unique(dados[is.na(dados$cod_munic),"DESCRICAO_UE"])
dados<-dados[!is.na(dados$cod_munic),]

# Creating dummies for the law (0 if year = 04 or 08 and 1 otherwise)
dados$dummy_cota<- ifelse(dados$ano.x == 2004 | dados$ano.x == 2008, 0, 1)
table(dados$dummy_cota, dados$ano.x)

# Creating categorical variable for years (EF_t)
dados$dummy_ano<- ifelse(dados$ano.x == 2004, 0, ifelse(dados$ano.x == 2008, 1, ifelse(dados$ano.x == 2012, 2, 3)))
table(dados$dummy_ano, dados$ano.x)

# Creating year dummies
dados$a04 <- ifelse(dados$ano.x == 2004, 1, 0)
dados$a08 <- ifelse(dados$ano.x == 2008, 1, 0)
dados$a12 <- ifelse(dados$ano.x == 2012, 1, 0)
dados$a16 <- ifelse(dados$ano.x == 2016, 1, 0)

# Creating the fixed effect for municipalities
dados$dummy_mun <- as.double(factor(dados$cod_munic)) - 1
summary(dados$dummy_mun)

# Calculates the proportion of women in the city
dados$prop_mul <- round(dados$num_mulheres_total/dados$pop_total*100,2)

# Creates a factor for region
dados$regiao <- ifelse(dados$no == 1, "Norte", 
                       ifelse(dados$ne == 1, "Nordeste", 
                              ifelse(dados$se == 1, "Sudeste",
                                     ifelse(dados$su == 1, "Sul","Centro-Oeste"))))
table(dados$regiao)

######################################
# Descriptives
######################################

# Packages used
library(gplots)
library(foreign)
library(plm)
library(ggplot2)
library(doBy)
library(corrplot)
library(xtable)
library(stargazer)
library(reshape2)

############################################
# Share of Women
############################################

# Summaryzing data
head(dados)
s_propme <- summarySE(dados, measurevar = "prop_me", groupvars = c("ano.x", "regiao"), na.rm = TRUE)
s_propme

# Making the mean plot
pd <- position_dodge(0.1) # move them .05 to the left and right
pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Regions.pdf", width = 5.7, height = 2.75)
ggplot(s_propme, aes(x=ano.x, y=prop_me, colour = regiao, group = regiao)) + 
  geom_errorbar(aes(ymin=prop_me-se, ymax=prop_me+se), colour = "black", width=.1, position = pd) +
  geom_line(position=pd) +
  geom_point(position = pd, size = 3, shape = 21, fill = "white") +
  xlab("Year") +
  ylab("Share of Elected Women") +
  scale_colour_hue(name = "Region",
                   labels = c("Central-West", "Northeast", "North", "Southeast", "South"),
                   l = 40) +
  ggtitle("") +
  theme_bw() +
  theme(plot.title = element_text(size = 10))
  #theme(legend.justification = c(1,0),
        #legend.position = c(1,0)) +
  guides(colour = guide_legend(title.hjust = 0.3))
dev.off()
  
  
# Another graph, without regions

s2_propme <- summarySE(dados, measurevar = "prop_me", groupvars = c("ano.x"), na.rm = TRUE)
s2_propme
pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Share.pdf", width = 2.2, height = 2.75)
ggplot(s2_propme, aes(x=ano.x, y=prop_me)) + 
  geom_errorbar(aes(ymin=prop_me-se, ymax=prop_me+se), colour = "black", width=.1, position = pd) +
  geom_line(position=pd) +
  geom_point(position = pd, size = 3, shape = 21, fill = "white") +
  xlab("Year") +
  ylab("Share of Elected Women") +
  #ggtitle("Share of women elected in city council elections in Brazil") +
  theme_bw() +
  theme(plot.title = element_text(size = 10))
dev.off()

# Now the share of female candidates
s2_propcm <- summarySE(dados, measurevar = "prop_cm", groupvars = "ano.x", na.rm = TRUE)
s2_propcm
pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Share-candidates.pdf", width = 2.2, height = 2.75)
ggplot(s2_propcm, aes(x=ano.x, y=prop_cm)) + 
  geom_errorbar(aes(ymin=prop_cm-se, ymax=prop_cm+se), colour = "black", width=.1, position = pd) +
  geom_line(position=pd) +
  geom_point(position = pd, size = 3, shape = 21, fill = "white") +
  xlab("Year") +
  ylab("Share of Women Candidates") +
  #ggtitle("Share of candidates in city council elections in Brazil") +
  theme_bw() +
  theme(plot.title = element_text(size = 10))
dev.off()

# Overlaying plots (to look prettier :D )
df1<-data.frame(c(2004,2008,2012,2016,2004,2008,2012,2016),
           c("prop_cm","prop_cm","prop_cm","prop_cm","prop_me","prop_me","prop_me","prop_me"),
           c(20.61005, 20.65634, 32.49647, 33.12181, 12.42661, 12.30195, 13.56884, 13.73379))
df1
colnames(df1)<-c("dados.ano.x", "variable", "value")
df1
pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Share-overall.pdf", width = 5.7, height = 2.75)
ggplot(df1, aes(x=dados.ano.x, y=log(value), colour = variable, group = variable)) + 
  geom_line(position=pd) +
  geom_point(position = pd, size = 3, shape = 21, fill = "white") +
  xlab("Year") +
  ylab("Share") +
  scale_colour_hue(name = "Share of",
                   labels = c("Women candidate", "Women Elected"),
                   l = 40) +
  theme(legend.justification = c(1,0),
        legend.position = c(20,0)) +
  guides(colour = guide_legend(title.hjust = 0.3)) +
  theme_bw() +
  theme(plot.title = element_text(size = 10))
dev.off()

# Making boxplots
pdf("C:\\Users\\Aishameriane\\OneDrive\\Documentos\\Mestrado Economia\\Microeconometria - 2016-02\\Trabalho\\Trabalho-final\\Imagens\\Boxplots.pdf", width = 5.7, height = 2.75)
ggplot(dados, aes(x=factor(ano.x), y=prop_me, fill=factor(ano.x))) + 
  geom_boxplot() +
  guides(fill=FALSE)+
  xlab("Year") +
  ylab("Share of Elected Women") +
  #ggtitle("Distribution of the proportion of women elected in city council elections \n Brazil - 2004-2016") +
  theme_bw() +
  theme(plot.title = element_text(size = 10))+
  scale_fill_brewer(palette = "Blues")
dev.off()

# Getting the descriptives
summary(dados$prop_me[dados$ano.x==2004])
summary(dados$prop_me[dados$ano.x==2008], na.rm = TRUE)
summary(dados$prop_me[dados$ano.x==2012])
summary(dados$prop_me[dados$ano.x==2016], na.rm = TRUE)

# Calculating the means
mean(dados$prop_me[dados$ano.x==2004])
mean(dados$prop_me[dados$ano.x==2008 & dados$regiao == "Norte"], na.rm = TRUE)
mean(dados$prop_me[dados$ano.x==2012 & dados$regiao == "Norte"])
mean(dados$prop_me[dados$ano.x==2016], na.rm = TRUE)

#######################################################
# Looking into the covariates
#######################################################

summary(dados[dados$ano.x == 2004,])
table(dados$dummy_cota, dados$ano.x)
table(dados$regiao, dados$ano.x)


quantitativas<-subset(dados, ano.x==2004, select = c(prop_me, gini, idhm, idhm_e, idhm_r,
                                        esperanca_anos_estudo, expectativa_vida, percentual_pobres,
                                        percentual_pobres_criancas, pib_pc, taxa_fecundidade, tx_analbabetismo,
                                        pop_urb_proporcao, prop_mul))

xtable(round(cor(quantitativas, method="spearman"),2))

quant_selected<-quantitativas[c("gini", "idhm", "esperanca_anos_estudo", "taxa_fecundidade", "pop_urb_proporcao")]
head(quant_selected)

dtf <- sapply(quant_selected, each(min, mean, max, sd, var))
xtable(dtf)

plotmeans(prop_me ~ dummy_mun, main="Heterogeineity across regions", data=dados[dados$regiao == "Nordeste",], bars = FALSE)



######################################################
# Fitting the model
#######################################################

library(lmtest)
library(plm)

head(dados)

# Fixed effect model
reg_FE1<- plm(ln_prop_me ~ dummy_cota + gini + idhm + esperanca_anos_estudo + taxa_fecundidade  + pop_urb_proporcao + ne + se + su + co + prop_mul, data = dados, index = c("SIGLA_UE", "ano.x"), model = "within")
summary(reg_FE1)
stargazer(reg_FE1)

fixef(reg_FE1)

# FE model estimating two-way effects: time and individuals
# This take more than an hour to run and the results are horrible!
reg_FE2<- plm(ln_prop_me ~ dummy_cota + gini + idhm + esperanca_anos_estudo + taxa_fecundidade  + pop_urb_proporcao + ne + se + su + co  + prop_mul, data = dados, index = c("SIGLA_UE", "ano.x"), model = "within", effect = "twoways")
summary(reg_FE2)

# FE model estimating one effect: time
# This model dropped the dummy
reg_FE3<- plm(ln_prop_me ~ dummy_cota + gini + idhm + esperanca_anos_estudo + taxa_fecundidade  + pop_urb_proporcao + ne + se + su + co  + prop_mul, data = dados, index = c("SIGLA_UE", "ano.x"), model = "within", effect = "time")
summary(reg_FE3)

# FE model estimating one effect: individuals
# This one have the same result from the first
reg_FE4<- plm(ln_prop_me ~ dummy_cota + gini + idhm + esperanca_anos_estudo + taxa_fecundidade  + pop_urb_proporcao + ne + se + su + co  + prop_mul, data = dados, index = c("SIGLA_UE", "ano.x"), model = "within", effect = "individual")
summary(reg_FE4)

# Random effect model
reg_RE<- plm(ln_prop_me ~ dummy_cota + gini + idhm + esperanca_anos_estudo + taxa_fecundidade  + pop_urb_proporcao + ne + se + su + co  + prop_mul, data = dados, index = c("SIGLA_UE", "ano.x"), model = "random")
summary(reg_RE)

# New RE model without non-significant variables
reg_RE2<- plm(ln_prop_me ~ dummy_cota + ne + se + no + co, data = dados, index = c("SIGLA_UE", "ano.x"), model = "random")
summary(reg_RE2)
stargazer(reg_RE2)

# Comparing both models using the Hausman test
phtest(reg_FE1, reg_RE2)

# Pooled OLS
reg_pool<- plm(ln_prop_me ~ dummy_cota + ne + se + su + co, data = dados, index = c("SIGLA_UE", "ano.x"), model = "pooling")
summary(reg_pool)

# Breusch-Pagan Lagrange Multiplier. H0 = no panel effect
plmtest(reg_pool, type=c("bp"))

coeftest(reg_RE2, vcov=vcovHC(reg_RE2, cluster="group"))

alpha<- 0.352854

exp(alpha)
100*(exp(alpha)-1)

boxplot(dados$prop_me ~ dados$dummy_cota)
