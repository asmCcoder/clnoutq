/*********************************************************************/
/* CLNOUTQ - Clean OUTQ                                              */
/*  SYSTEM      : V4R5                                               */
/*  PROGRAMMER  : David Asta                                         */
/*  DATE-WRITTEN: 05/SEP/2020                                        */
/*  (C) COPYRIGHT 2020 David Asta under MIT License                  */
/*                                                                   */
/* PARAMETERS:                                                       */
/*    &OUTQ - Name of the OUTQ to delete SPLFs from                  */
/*    &OUTQLIB - Library of the OUTQ above                           */
/*    &EXPDAYS - Number of days a SPLF is considered expired (max.99)*/
/*    &SENDRES - 'Y' if want to send a message at the end to &TOUSR  */
/*    &TOUSR   - User profile ID to receive the message, if above 'Y */
/*    &DLTQTMP - 'Y' if want to delete the file created in QTEMP     */
/*    &KEEPSAV - 'Y' if want to keep spool files with Status SAV     */
/*                                                                   */
/* This program gets the list of all SPLFs (WRKOUTQ) on a specifc    */
/*  OUTQ (&OUTQ) and copies the list (CPYSPLF) into QTEMP/WRKOUTQSPL.*/
/* Then calls an RPG program (CLNOUTQR) which will delete the records*/
/*  from QTEMP/WRKOUTQSPL that don't match the criteria: newer than  */
/*  &EXPDAYS or Status = SAV (if &KEEPSAV = 'Y')                     */
/* Finally, this CL reads each record left on QTEMP/WRKOUTQSPL and   */
/*  deletes the SPL (DLTSPLF).                                       */
/*********************************************************************/
             PGM        PARM(&OUTQ &OUTQLIB &EXPDAYS &SENDRES &TOUSR +
                          &DLTQTMP &KEEPSAV)

             DCL        VAR(&OUTQ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OUTQLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&EXPDAYS) TYPE(*CHAR) LEN(2)
             DCL        VAR(&SENDRES) TYPE(*CHAR) LEN(1)
             DCL        VAR(&TOUSR) TYPE(*CHAR) LEN(10)
             DCL        VAR(&DLTQTMP) TYPE(*CHAR) LEN(1)
             DCL        VAR(&KEEPSAV) TYPE(*CHAR) LEN(1)
             DCL        VAR(&COUNTER) TYPE(*DEC) LEN(6) VALUE(0)
             DCL        VAR(&COUNTERC) TYPE(*CHAR) LEN(6) VALUE(' ')
             DCL        VAR(&SPLNBRD) TYPE(*DEC) LEN(4) VALUE(0)

             DCLF       FILE(WRKOUTQSPL)

/* If WRKOUTQSPL already exists in QTEMP, clear it */
             CLRPFM     FILE(QTEMP/WRKOUTQSPL)
/* Otherwise, create a duplicate copy to work with */
             MONMSG     MSGID(CPF3142) EXEC(CRTDUPOBJ +
                          OBJ(WRKOUTQSPL) FROMLIB(*LIBL) +
                          OBJTYPE(*FILE) TOLIB(QTEMP))
/* Override with DBF, so from now on we use this file in QTEMP */
             OVRDBF     FILE(WRKOUTQSPL) TOFILE(QTEMP/WRKOUTQSPL) +
                          MBR(*FIRST)
/* Generate SPL of the contents of the OUTQ */
             WRKOUTQ    OUTQ(&OUTQLIB/&OUTQ) OUTPUT(*PRINT)
/* Copy SPL into QTEMP/WRKOUTQSPL */
             CPYSPLF    FILE(QPRTSPLQ) TOFILE(QTEMP/WRKOUTQSPL) +
                          SPLNBR(*LAST)
/* Call RPG program that will read WRKOUTQSPL and delete the ones */
/*  that don't match our criteria                                 */
             CALL       PGM(CLNOUTQR) PARM(&EXPDAYS &KEEPSAV)
/* Read all records left on QTEMP/WRKOUTQSPL */
/* and delete corresponding SPLFs in the OUTQ */
READPF:
             RCVF
/* If EOF, leave this loop */
             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(EOF))
/* Otherwise, delete SPLF */
             CHGVAR     VAR(&SPLNBRD) VALUE(&FILNUM)
             DLTSPLF    FILE(&FILE) JOB(&NUMBER/&USER/&JOB) +
                          SPLNBR(&SPLNBRD)
             CHGVAR     VAR(&COUNTER) VALUE(&COUNTER + 1)
/* Loop back to continue reading records */
             GOTO       CMDLBL(READPF)
EOF:
/* Send a message to &TOUSR, if &SENDRES = 'Y' */
             IF         COND(&SENDRES *NE 'Y') THEN(GOTO CMDLBL(NOMSG))
             CHGVAR     VAR(&COUNTERC) VALUE(&COUNTER)
             SNDMSG     MSG('Deleted ' *CAT &COUNTERC *CAT ' spool +
                          files.') TOUSR(&TOUSR)
NOMSG:
/* Delete QTEMP/WRKOUTQSPL, if &DLTQTMP = 'Y' */
             IF         COND(&DLTQTMP *EQ 'Y') THEN(DLTF +
                          FILE(QTEMP/WRKOUTQSPL))
/* Delete OVR */
             DLTOVR     FILE(WRKOUTQSPL)
             ENDPGM
