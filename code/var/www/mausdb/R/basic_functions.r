##################################################################################################################
# basic functions: assay-independent functions
##################################################################################################################

suppressMessages(suppressWarnings(library(gregmisc)))

#########################################################
# global settings
color_male_mutant    = "lightblue"
color_male_control   = "royalblue"
color_female_mutant  = "salmon2"
color_female_mutant  = "orange2"
color_female_control = "red3"
color_else           = "white"

pch_male_mutant      = 15
pch_male_control     = 15
pch_female_mutant    = 20
pch_female_control   = 20
pch_else             = 2

symbolsize           = 1
linewidth            = 2
textsize             = 1.2
#########################################################


#########################################################
# function html_break
html_break <- function() {
   print("<br />", quote=FALSE)
}
#########################################################
# function html_line
html_line <- function(width) {
   print(paste("<hr width='", width, "%' align='left'/>", sep=""), quote=FALSE)
}
#########################################################
# function df2html: converts a data frame to a HTML table
df2html <- function(tab) {
    nr <- nrow(tab)            # number of rows
    nc <- ncol(tab)            # number of columns
    cat("<table border=1>")
    cat("<th>")
    cat(colnames(tab), sep=paste("</th>", "<th>", sep=''))
    cat("</th>")
    for (i in 1:nr) {          # loop over all rows
        cat("<tr align='right'>")
        for (j in 1:nc) {      # loop over all columns within row
            cat("<td>",as.character(tab[i,j]), "</td>", sep="")
        }
        cat("</tr>")
    }
    cat("</table>")
}
#########################################################

