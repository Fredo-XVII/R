#library RDCOMClient for sending mail through R

library(RDCOMClient)

subject <- paste("subject", etc, etc, sep = " ")
bodytext <- paste(item1,2,3 etc, sep = "\n")

OutApp <- COMCreate("Outlook.Application")
outMail <- OutApp$CreateItem(0)
outMail[["To"]] <- "recipientEmail"
outMail[["subject"]] <- subject
outMail[["body"]] <- body

outMail[["Attachments"]]$Add(addPathwayFile1)
outMail[["Attachments"]]$Add(addPathwayFile2)
outMail[["Attachments"]]$Add(addPathwayFile3)

outMail$Send()
