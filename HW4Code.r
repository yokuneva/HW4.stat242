####################################################################################################
##                                                                                               ###
##                     HW 4                                                                     ####
####################################################################################################


setwd("/home/jenya/hw5")

##############################################################count number of flights leaving each airport

origin.count = system("cut -d',' -f17 *.csv|
                    egrep -i '(SFO|LAX|SMF|OAK)'| 
                    sort | uniq -c", intern = TRUE)



############################################################################convert to data frame for
#####################################################################################plot


m=as.data.frame(t(matrix(unlist(strsplit(origin.count, 
                                split = "[1-9] ")), nrow =2)))

m$V1 = as.numeric(gsub(" ","",m$V1))

names(m)=c("Number_of_Flights","Airport")



barplot(m$Number_of_Flights, beside = TRUE, names.arg = m$Airport, main = "Number of Flights")



###############################################get mean and sd using connection



######################################################### first, open the connection 
origin.delay = pipe("cut -d',' -f15,17  *.csv | egrep '(SFO|LAX|SMF|OAK)'", "r")

####################################################second, build the container
Total = as.data.frame(matrix(0, nrow = 4, ncol =4))
names(Total) = c("SFO", "LAX", "SMF", "OAK")


#################################################next get Sums and counts using while loop
######################storing results for the first block and adding the results 
#######################for all subsequent blocks


Rprof("check", memory.profiling=TRUE)

while (TRUE){
  c=readLines(origin.delay, n = 100)
  if(length (c) == 0)
    break
  tmp = tapply (as.numeric(as.character(
    data.frame(t(matrix(unlist(strsplit(c, split = ",")),nrow = 2)))[,1])), 
                as.factor(data.frame(t(matrix(unlist(strsplit(c, split = ",")),nrow = 2)))[,2]),
                
                function (x) { 
                  data.frame(rbind(sum(x, na.rm = TRUE),
                                   sum(!is.na(x)),
                                   length(x),
                                   sum(x^2, na.rm = TRUE)))})
  
  Total[names(tmp)] = Total[names(tmp)] + tmp
}

Rprof(NULL)
summaryRprof("check", memory = "both")


close(origin.delay)

########################################################get mean
means = Total[1,]/Total[2,]

########################################################get standard deviation
SDs = sqrt(Total[4,]/(Total[2,]-1)-(Total[1,]/Total[2,])^2)




#############################################################################################

######                               SQLite                                             #####

#############################################################################################

#####################################first created my_airline_database in SQL from shell 

setwd('/home/jenya/hw5')
m=dbDriver("SQLite")
con = dbConnect(m, dbname = "my_airline_all")
rs = dbSendQuery(con, statement = paste(
                      "SELECT Origin, AVG(ArrDelay) AS mean, Count (Origin) AS count,
                      AVG(ArrDelay*ArrDelay) - AVG(ArrDelay)*AVG(ArrDelay) AS variance", 
                      "FROM delays",
                      "WHERE Origin = 'SFO' OR Origin = 'SMF' OR Origin = 'LAX' OR Origin = 'OAK'",
                      "GROUP BY Origin"))

Rprof("check", memory.profiling=TRUE)

df=fetch(rs, n = -1)
Rprof(NULL)

summaryRprof("check", memory = "both")

df$sd = sqrt(df$variance)











