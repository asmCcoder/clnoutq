# CLNOUTQ - Clean OUTQ

## Description

I recently found that QEZJOBLOG had 1558 spool files. I could have easily deleted all or the old ones, but I don't want to have to do this often. Repetive tasks should be automated. I couldn't find a command in OS/400 V4R5 to do this (delete SPLF by age), so I made my own. Basically, what it does is: gets the list of all spool files from an OUTQ specified by parameter, decides which ones should be deleted (based in parameter values) and deletes them.

## Parameters

CLNOUTQ is called with seven paramenters:
* &OUTQ - Name of the OUTQ to delete SPLFs from.
* &OUTQLIB - Library of the OUTQ above.
* &EXPDAYS - Number of days a SPLF is considered expired. Max. 99
* &SENDRES - 'Y' if want to send a message at the end to &TOUSR
* &TOUSR   - User profile ID to receive the message, if above 'Y
* &DLTQTMP - 'Y' if want to delete the file created in QTEMP
* &KEEPSAV - 'Y' if want to keep spool files with Status SAV

#### Example

```text
CALL PGM(CLNOUTQ) PARM('QEZJOBLOG' 'QUSRSYS' '30' 'Y' 'DASTA' 'N' 'Y')
```
Will delete all, except the ones with Status = SAV, spool files from QUSRSYS/QEZJOBLOG that are older than 30 days. At the end it will send a message with the count of how many SPLF were deleted to user DASTA. And will not delete the temporary file created in QTEMP, thus one can check what was deleted.
