     H/TITLE Calc JULIAN date
     H* SYSTEM      : V4R5
     H* PROGRAMMER  : David Asta
     H* DATE-WRITTEN: 05/SEP/2020
     H* (C) COPYRIGHT 2020 David Asta under MIT License
     H*
     H* Formula used from: https://en.wikipedia.org/wiki/Julian_day
     H* The algorithm is valid for all (possibly proleptic) Gregorian
     H* calendar dates after 23rd November 4713 BC
     D**********************************************************************
     D* Variables
     DPADAY            S              2A
     DPAMONTH          S              2A
     DPAYEAR           S              4A
     DPAJD             S             15A
     DPDAY             S              2S 0
     DPMONTH           S              2S 0
     DPYEAR            S              4S 0
     DPJD              S             15S 5
     DWTMP1            S             15S 0
     DWTMP2            S             15S 0
     C**********************************************************************
     C* Parameters: Day, Month, Year to convert, and Julian Date result.
     C     *ENTRY        PLIST
     C                   PARM                    PADAY
     C                   PARM                    PAMONTH
     C                   PARM                    PAYEAR
     C                   PARM                    PAJD
     C* Convert received parameters to numeric
     C                   MOVE      PADAY         PDAY
     C                   MOVE      PAMONTH       PMONTH
     C                   MOVE      PAYEAR        PYEAR
     C* Calculate Julian
     C*  JD = (1461 * (Y + 4800 + (M - 14) / 12)) /4
     C*       + (367 * (M - 2 - 12 * ((M - 14) / 12))) / 12
     C*       - (3 * ((Y - 4900 + (M - 14) / 12) / 100)) / 4 + D - 32075
     C                   EVAL      WTMP1 = %INT((PMONTH - 14) / 12)
     C                   EVAL      WTMP2 = %INT(PYEAR + 4800 + WTMP1)
     C                   EVAL      WTMP1 = %INT((1461 * WTMP2) / 4)
     C                   EVAL      PJD = WTMP1
     C*
     C                   EVAL      WTMP1 = %INT((PMONTH -14) / 12)
     C                   EVAL      WTMP2 = %INT(PMONTH - 2 - 12 * WTMP1)
     C                   EVAL      WTMP1 = %INT((367 * WTMP2) / 12)
     C                   EVAL      PJD = PJD + WTMP1
     C*
     C                   EVAL      WTMP1 = %INT((PMONTH - 14) / 12)
     C                   EVAL      WTMP2 = %INT((PYEAR + 4900 + WTMP1) /100)
     C                   EVAL      WTMP1 = %INT((3 * WTMP2) / 4)
     C                   EVAL      PJD = PJD - WTMP1 + PDAY - 32075
     C* Convert numeric result to alphanumeric, for the return parameter
     C                   MOVEL     PJD           PAJD
     C* Exit program
     C                   MOVE      *ON           *INLR
     C                   RETURN
