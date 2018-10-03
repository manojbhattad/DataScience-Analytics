### IPL(Indian Premier League) Proj Analysis

## Set working directory where dataset file is kept
print(getwd())
setwd("<file path where .csv dataset file to be analysed is stored>")
print(getwd())

## Read data from csv files.. files with header
matches <- fread("matches.csv", header = TRUE)
delivery <- fread("deliveries.csv", header = TRUE)

dim(matches)
dim(delivery)

## Create data table for matches & delivery files read
DT_matches <- as.data.table(matches)
DT_delivery <- as.data.table(delivery)

is.data.table(DT_matches)
is.data.table(DT_delivery)

DT_matches[1:2, c(4,7,8)]    # Viewing data of first 2 rows of matches fill
DT_delivery[1:2]    # Viewing data of first 2 rows of delivery file
head(DT_matches, 2)   # Viewing data of first 2 rows of matches file: another method
tail(DT_matches, 1)   # Viewing data of last row of matches file: another method

## Some data cleaning and parsing 
DT_matches[, umpire3:= NULL]     # Removed column 'umpire3' as it has no values
colnames(DT_matches)      # Check columns of matches after removal of umpire3

# Apply 'NA' for blank(null) values of columns
DT_matches$city[DT_matches$city==""] <- "NA"
DT_matches$umpire1[DT_matches$umpire1==""] <- "NA"
DT_matches$umpire2[DT_matches$umpire2==""] <- "NA"

DT_delivery$player_dismissed[DT_delivery$player_dismissed==""] <- "NA"
DT_delivery$dismissal_kind[DT_delivery$dismissal_kind==""] <- "NA"
DT_delivery$fielder[DT_delivery$fielder==""] <- "NA"
#DT_matches%>%replace_with_na_all(condition = ~.id == "")
#DT_delivery%>%replace_with_na(replace = list(player_dismissed = "", dismissal_kind = "", fielder = "" ))
#DT_delivery%>%replace_with_na_all(condition = ~.dismissal_kind == "")
head(DT_delivery, 1)

unique(DT_matches$team1, incomparables = FALSE)  # Display names of teams uniquely i.e. total teams in IPL

# Replace IPL team names with abbreviations
#** replace(DT_matches,("Mumbai Indians","Kolkata Knight Riders","Royal Challengers Bangalore","Deccan Chargers","Chennai Super Kings","Rajasthan Royals","Delhi Daredevils","Gujarat Lions","Kings XI Punjab","Sunrisers Hyderabad","Rising Pune Supergiants","Kochi Tuskers Kerala","Pune Warriors","Rising Pune Supergiant"),("MI","KKR","RCB","DC","CSK","RR","DD","GL","KXIP","SRH","RPS","KTK","PW","RPS"))
#**DT_match_r = as.data.table(replace(DT_matches,c("Mumbai Indians","Kolkata Knight Riders","Royal Challengers Bangalore","Deccan Chargers","Chennai Super Kings","Rajasthan Royals","Delhi Daredevils","Gujarat Lions","Kings XI Punjab","Sunrisers Hyderabad","Rising Pune Supergiants","Kochi Tuskers Kerala","Pune Warriors","Rising Pune Supergiant"),c("MI","KKR","RCB","DC","CSK","RR","DD","GL","KXIP","SRH","RPS","KTK","PW","RPS")))
#unique(DT_match_r$team1))   # Display abbreviated names of teams

## Some Basic Analysis-
c("Total Matches Played:",length(DT_matches$id))
c("Venues Played At:",unique(DT_matches$city))     
c('Teams:',unique(DT_matches$team1, na.rm=TRUE))  # ..still it gives 'NA' value if present

cat('Total venues played at:\n',length(unique(DT_matches$city)))
cat('Total teams:\n',length(unique(DT_matches$team1)))
cat('Total umpires:\n ',length(unique(DT_matches$umpire1)))

# List of Players with 'Man Of The Match' award in descending order
library(plyr)
DT_matches_order <- data.table(count(DT_matches, 'player_of_match'))
DT_matches_order[order(-freq)]

c("Player with maximum 'Man Of The Match' award:",sort(table(DT_matches$player_of_match), decreasing = TRUE)[1])
c("Team with highest no. of match win:",sort(table(DT_matches$winner), decreasing = TRUE)[1])

# IPL team winner with maximum no. of runs and corresponding details
DT_matches_winByMaxRuns <- DT_matches[which.max(DT_matches$win_by_runs)]
DT_matches_winByMaxRuns[,.(season,team1,team2,winner,win_by_runs)]
c('IPL match winner with max no. of runs:',DT_matches_winByMaxRuns[,.(season,team1,team2,winner,win_by_runs)])

# IPL team winner with maximum no. of wickets and corresponding details
DT_matches_winByMaxWickets <- DT_matches[which.max(DT_matches$win_by_wickets)]
DT_matches_winByMaxWickets[,.(season,team1,team2,winner,win_by_wickets)]
c('IPL match winner with max no. of wickets:',DT_matches_winByMaxRuns[,.(season,team1,team2,winner,win_by_wickets)])

c('Toss decision & count:',table(DT_matches$toss_decision))
c('Toss decision in percentage:',table(DT_matches$toss_decision)*100/length(DT_matches$id))

#** Bar chart for 'Toss Decisions' across Seasons (Seasons-vs-Toss_Decision)
library(RColorBrewer)
colours = c("red", "blue")
toss.count <- as.matrix(table(DT_matches$toss_decision, DT_matches$season))
toss.count
ylim_2 <- (sort(table(DT_matches$toss_decision, DT_matches$season),decreasing=TRUE)[1])+5
ylim_2

#bar_toss.season <- barplot(toss.count, beside=TRUE, main="Season-vs-Toss_Decision", xlab="season", ylab='toss count', col=colours, border="yellow", ylim = c(0,55),legend.text=unique(DT_matches$toss_decision))
bar_toss.season <- barplot(toss.count, beside=TRUE, main="Season-vs-Toss_Decision", xlab="season", ylab='toss count', col=colours, border="yellow", ylim=c(0,ylim_2))
legend("topleft", unique(DT_matches$toss_decision), cex = 1.2, fill = colours)
text(bar_toss.season, toss.count+1.5, labels = as.character(toss.count))

#** Bar chart for Team-vs-Toss_Winner_Count
toss.winner <- sort(table(DT_matches$toss_winner),decreasing=TRUE)
toss.winner

bar_toss.winner <- barplot(toss.winner, main="Team-vs-Toss_Winning_Count", xlab="team", ylab='toss winning count', col="blue", border="black", ylim=c(0,90), las=2)
text(bar_toss.winner, toss.winner+2.5, labels = as.character(toss.winner))

# merging data tables DT_matches & DT_delivery
DT_del.m <- data.table(delivery, key="match_id")
DT_match.m <-data.table(matches, key="id" )
DT_merge <- merge(DT_del.m, DT_match.m, by.x="match_id", by.y="id", all.x=TRUE )
is.data.table(DT_merge)

#** Line graph for runs across the season
Season.total_runs <- aggregate(DT_merge$total_runs~DT_merge$season, FUN=sum)
Season.total_runs

lineGraph_totalRuns <- plot(Season.total_runs, type="o", col="blue", main="Season-vs-Total_Runs", xlab="season", ylab="total runs")
#text(lineGraph_totalRuns, Season.total_runs+2, labels=as.character(Season.total_runss))    ... not giving expected result

#** Line graph for runs across the season
season.batsman_runs6 <- as.matrix(table(DT_merge$batsman_runs, DT_merge$season)[7,])
season.batsman_runs6
season.batsman_runs4 <- as.matrix(table(DT_merge$batsman_runs, DT_merge$season)[5,])
season.batsman_runs4

par(mfrow=c(1,1))
lineGraph_runs.4 <- plot(season.batsman_runs4, type="o", col="red", main="Season-vs-4s", xlab="season", ylab="4s")
lineGraph_runs.6 <- plot(season.batsman_runs6, type="o", col="blue", main="Season-vs-6s", xlab="season", ylab="6s")

lineGraph_runs.4 <- plot(season.batsman_runs4, type="o", col="red", main="Season-vs-4s&6s", xlab="season", ylab="4s & 6s", ylim=c(500,2500))
lines(season.batsman_runs6, type="o", col="blue")
legend(8,2250, c("4s","6s"), col=c("red","blue"), lty=c(1,1), cex=0.8)



