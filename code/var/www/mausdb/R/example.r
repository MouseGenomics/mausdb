invisible(options(echo = FALSE))

#########################################################################################
# this example file demonstrates the use of the MausDB R interface and how R output
# is reformatted for proper HTML display.
#########################################################################################

# load R package
library(lattice)

# include user defined functions
source("/var/www/mausdb/R/basic_functions.r")         # load user defined functions

# set path for output file (don't change)
OUTPATH="/var/www/mausdb/R/output/MYSESSIONDIR/"

# read data that has been written to a file by SQL script
# if your script is named "example.sql", enter "example_data.txt" here
data=read.delim(paste(OUTPATH, "example_data.txt", sep=""), na.strings = "(NULL)")

# attach data frame
attach(data)

# total number of animals
tiere<-length(mouse_id)

#################
# show data table
#################

# "--H1" and "H1--" will be replaced by "<H1>" and "</H1>" tags for proper HTML display
print(paste("--H11. Example data for a selection of", tiere, "animalsH1--"), quote=FALSE)

# R function defined in include file basic_functions.r (see above): converts R data frame to HTML table
print(df2html(data))

# R functions defined in include file basic_functions.r (see above): HTML shortcuts
html_break()
html_line(50)


# "--H2" and "H2--" will be replaced by "<H2>" and "</H2>" tags for proper HTML display
print("--H2HistogramsH2--", quote=FALSE)

################
# 1. image: mass
################
# start jpeg image (needed for HTML inline display of image)
jpeg(paste(OUTPATH, "example_", 1, ".jpeg", sep=""), quality=100, width=700, height=700)

hist(na.omit(data$mass), xlab=paste("body mass [g]"), cex.main=1.1, main="body mass", freq=F)
lines(density(na.omit(data$mass)), lty=2)

# write image tag (needed for HTML inline display of image)
print(paste("__example_", 1,".jpeg__", sep=""), quote = FALSE)
# finish image output
invisible(dev.off())

# R functions defined in include file basic_functions.r (see above): HTML shortcuts
html_break()

##################
# 2. image: length
##################
# start jpeg image (needed for HTML inline display of image)
jpeg(paste(OUTPATH, "example_", 2, ".jpeg", sep=""), quality=100, width=700, height=700)

hist(na.omit(data$length), xlab=paste("body length [mm]"), cex.main=1.1, main="body length", freq=F)
lines(density(na.omit(data$mass)), lty=2)

# write image tag (needed for HTML inline display of image)
print(paste("__example_", 2,".jpeg__", sep=""), quote = FALSE)
# finish image output
invisible(dev.off())

# R functions defined in include file basic_functions.r (see above): HTML shortcuts
html_break()


# "--H2" and "H2--" will be replaced by "<H2>" and "</H2>" tags for proper HTML display
print("--H2Scatter plotH2--", quote=FALSE)

########################
# 3. image: scatter plot
########################
# start jpeg image (needed for HTML inline display of image)
jpeg(paste(OUTPATH, "example_", 3, ".jpeg", sep=""), quality=100, width=700, height=700)

plot(mass~length, xlab=paste("body length [mm]"), ylab=paste("body mass [g]"), cex.main=1.1, main="body mass vs. length")

# write image tag (needed for HTML inline display of image)
print(paste("__example_", 3,".jpeg__", sep=""), quote = FALSE)
# finish image output
invisible(dev.off())


# R functions defined in include file basic_functions.r (see above): HTML shortcuts
html_break()

# footer line
print(paste("--H3Output generated ", format(Sys.time(), "%m.%d.%Y %H:%M:%S"), "H3--"), quote=FALSE)

#########################################################
# set cut mark to excise R final output which we are not interested in
# do not remove
print("cut_start", quote=FALSE)

