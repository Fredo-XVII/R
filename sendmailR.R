# this script works with Microsoft outlook
library(sendmailR)
server <- 'SMTP.companyname.Com'
         
from <- "alfredo.marquez@email.com"
to <- "alfredo.marquez@email.com"
subject <- "R email Test"
body <- "BODY"
sendmail(from, to , subject, body, control=list(smtpServer = server))

-----

# Testing sending a file with email

library(sendmailR)
server <- 'SMTP.co.Com'
from <- "Everyone@TheWorld.com"
to <- c("email@co.com")
subject <- "You know..."
body <- "Just kidding!"
attachmentPath <- "~/Desktop/check.csv"
attachmentName <- "check.csv"
attachmentObject <- mime_part(x=attachmentPath,name=attachmentName)
bodyWithAttachment <- list(body,attachmentObject)
sendmail(from, 
         to , 
         subject, 
         bodyWithAttachment, 
         attach.files = c(attachment),
         control=list(smtpServer = server)
         )

-------

#[1:40 PM] Ralph Asher: 
testdf <- 
    openxlsx:::write.xlsx(x =list(
      'df1' = nonpeakstoredf_JustCOpure,
      'df2' = nonpeakstoredf_needaddtlthroughput
    ),
    file=paste(scenarioname_input,'.xlsx',sep=''),
    asTable=F)
#without the testdf<- part , this saves to my C: drive just fine
#library(sendmailR)
server <- 'SMTP.email.Com'from <- "email@co.com"
to <- "email@co.com"
subject <- "R email Test"
body <- list(
  "Testing R email Body hear",
  mime_part(x=testdf,name='testdf.xlsx')
)

sendmail(from, to , subject, body, control=list(smtpServer = server))
#Error in writeLines(mp$text, con) : invalid 'text' argument
