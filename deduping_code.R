dupes_dpci <- EDS_ANALYTICS_STAGE_1[,.(N_DPCI = .N), by = c("CO_LOC_REF_I","MDSE_ITEM_I")][N_DPCI > 1]
setkey(dupes_dpci,CO_LOC_REF_I, MDSE_ITEM_I)
setkey(EDS_ANALYTICS_STAGE_1,CO_LOC_REF_I, MDSE_ITEM_I)
dupes_dpci2 <- merge(EDS_ANALYTICS_STAGE_1, dupes_dpci[with = FALSE], by=.EACHI, all = FALSE)
setkey(dupes_dpci2,CO_LOC_REF_I, MDSE_ITEM_I)
dupes_dpci3 <- dupes_dpci2[CIRC_F == 'Y']

de_duped <- EDS_ANALYTICS_STAGE_1 %>% anti_join(dupes_dpci, by = c("CO_LOC_REF_I","MDSE_ITEM_I")) # should be 3989332 = 4005136 - 15804

de_duped_add <- rbind.data.frame(de_duped,dupes_dpci3[,-"N_DPCI"]) # Add the deduped rows back. # should be 3997234 = 3989332 + 7902

EDS_ANALYTICS_STAGE_1 <- de_duped_add
