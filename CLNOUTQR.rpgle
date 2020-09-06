     H/TITLE Clean a specific OUTQ
     H* SYSTEM      : V4R5
     H* PROGRAMMER  : David Asta
     H* DATE-WRITTEN: 05/SEP/2020
     H* (C) COPYRIGHT 2020 David Asta under MIT License
     H*
     H* PARAMETERS:
     H*    PEXPDAYSA - Number of days a SPLF is considered expired.
     H*    PKEEPSAV  - If 'Y', spools with Status SAV will be kept.
     H* This program reads all records from WRKOUTQSPL and decides if the
     H*  record should be kept or deleted, based on:
     H*    1) Delete if the JOB's Date in the record is older than x days
     H*    2) Keep if JOB's Status in the record is equal to SAV
     H* The number of x days is received by parameter.
     F**********************************************************************
     FWRKOUTQSPLUF   E             DISK
     D**********************************************************************
     D* Variables
     DPEXPDAYSA        S              2A
     DPKEEPSAV         S              1A
     DWEXPDAYS         S              2S 0 INZ(*ZEROS)
     DWTODD            S              2S 0 INZ(*ZEROS)
     DWTODM            S              2S 0 INZ(*ZEROS)
     DWTODY            S              4S 0 INZ(*ZEROS)
     DWTODDA           S              2A
     DWTODMA           S              2A
     DWTODYA           S              4A
     DWTODJDA          S             15A
     DWTODJD           S             15S 5 INZ(*ZEROS)
     DWJOBDA           S              2A
     DWJOBMA           S              2A
     DWJOBYA           S              4A
     DWJOBJDA          S             15A
     DWJOBJD           S             15S 5 INZ(*ZEROS)
     DWNUMPAGES        S              5S 0 INZ(*ZEROS)
     C**********************************************************************
     C* Receive parameters (x days)
     C     *ENTRY        PLIST
     C                   PARM                    PEXPDAYSA
     C                   PARM                    PKEEPSAV
     C* and convert it to numeric
     C                   MOVEL     PEXPDAYSA     WEXPDAYS
     C* Get today's date
     C                   EVAL      WTODD = *DAY
     C                   EVAL      WTODM = *MONTH
     C                   EVAL      WTODY = *YEAR
     C* And convert it to Julian Date
     C                   MOVEL     WTODD         WTODDA
     C                   MOVEL     WTODM         WTODMA
     C                   MOVEL     WTODY         WTODYA
     C                   CALL      'CALCJULIAN'
     C                   PARM                    WTODDA
     C                   PARM                    WTODMA
     C                   PARM                    WTODYA
     C                   PARM                    WTODJDA
     C                   MOVEL     WTODJDA       WTODJD
     C* Begin reading the file, from the beginning
     C     *START        SETLL     WRKOUTQSPL
     C* Loop until End Of File
     C                   DOU       %EOF
     C                   READ      WRKOUTQSPL
     C* If we have reached the EOF, exit the DOU loop
     C                   IF        %EOF
     C                   LEAVE
     C                   ENDIF
     C* Convert PAGES into a numeric field
     C                   MOVE      PAGES         WNUMPAGES
     C* When converting to numeric, if it's a text we get either a negative
     C*  number or a big number. This indicates that the record is not valid
     C*  We'll delete it.
     C                   IF        WNUMPAGES < 0 OR WNUMPAGES > 20
     C                   DELETE    QPRTSPLQ
     C                   ELSE
     C* Otherwise we'll check number of days until today, and status not SAV
     C                   EXSR      PROCESSRECORD
     C                   ENDIF
     C                   ENDDO
     C* End of program
     C                   MOVE      *ON           *INLR
     C                   RETURN
     C**********************************************************************
     C     PROCESSRECORD BEGSR
     C* Get JOB's date
     C                   MOVE      DATEDY        WJOBDA
     C                   MOVE      DATEMO        WJOBMA
     C* and convert year from YY to 20YY
     C                   MOVEL     20            WJOBYA
     C                   MOVE      DATEYE        WJOBYA
     C* and convert it to Julian Date
     C                   CALL      'CALCJULIAN'
     C                   PARM                    WJOBDA
     C                   PARM                    WJOBMA
     C                   PARM                    WJOBYA
     C                   PARM                    WJOBJDA
     C                   MOVEL     WJOBJDA       WJOBJD
     C* If JOB date is newer than WEXPDAYS
     C                   IF        (WTODJD - WJOBJD) < WEXPDAYS                 IF1
     C* check STATUS
     C*    STATUS        IFEQ      'SAV'
     C                   IF        STATUS = 'SAV'                               IF2
     C* If parameter told us to not keep SPLF if Status = SAV, delete record
     C     PKEEPSAV      IFNE      'Y'                                          IF3
     C                   DELETE    QPRTSPLQ
     C                   ENDIF                                                  FI3
     C* If Status not SAV, delete record
     C                   ELSE                                                   EL2
     C                   DELETE    QPRTSPLQ
     C                   ENDIF                                                  FI2
     C                   ENDIF                                                  FI1
     C                   ENDSR
