C******************************************************************************
C
C ############################################################################
C #    THE MAIN PROGRAMS BELOW GIVE TWO EXAMPLES OF TRACING FIELD LINES      #
C #      USING THE GEOPACK-2008 SOFTWARE  (release of Feb 08, 2008)              #
C ############################################################################
C
      PROGRAM EXAMPLE1
C
C   IN THIS EXAMPLE IT IS ASSUMED THAT WE KNOW GEOGRAPHIC COORDINATES OF A FOOTPOINT
C   OF A FIELD LINE AT THE EARTH'S SURFACE AND TRACE THAT LINE FOR A SPECIFIED
C   MOMENT OF UNIVERSAL TIME, USING A FULL IGRF EXPANSION FOR THE INTERNAL FIELD
C
      PARAMETER (LMAX=500)
C
C  LMAX IS THE UPPER LIMIT ON THE NUMBER OF FIELD LINE POINTS RETURNED BY THE TRACER.
C  IT CAN BE SET ARBITRARILY LARGE, DEPENDING ON THE SPECIFICS OF A PROBLEM UNDER STUDY.
C  IN THIS EXAMPLE, LMAX IS TENTATIVELY SET EQUAL TO 500.
C
      DIMENSION XX(LMAX),YY(LMAX),ZZ(LMAX), PARMOD(10)
c
c    Be sure to include an EXTERNAL statement in your codes, specifying the names
c    of external and internal field model subroutines in the package, as shown below.
c    In this example, the external and internal field models are T96_01 and IGRF_GSW_08,
c    respectively. Any other models can be used, provided they have the same format
c    and the same meaning of the input/output parameters.
c
      EXTERNAL T96_01,IGRF_GSW_08
C
C   DEFINE THE UNIVERSAL TIME AND PREPARE THE COORDINATE TRANSFORMATION PARAMETERS
C   BY INVOKING THE SUBROUTINE RECALC_08: IN THIS PARTICULAR CASE WE TRACE A LINE
C   FOR YEAR=1997, IDAY=350, UT HOUR = 21, MIN = SEC = 0
C
      IYEAR=1997
      IDAY=350
      IHOUR=21
      MIN=0
      ISEC=0
C
C  AT THAT TIME, ACCORDING TO THE OMNI DATABASE, THE SOLAR WIND VELOCITY IN GSE HAD THE
C  COMPONENTS
C
      VGSEX=-304.0
      VGSEY= -16.0
      VGSEZ=   4.0
C
C  NOTE, HOWEVER, THAT THE ABERRATION CORRECTION WAS ALREADY MADE IN THE OMNI SOLAR WIND DATA.
C  THEREFORE, TO CORRECTLY TRANSFORM THE DATA TO GSM COORDINATE SYSTEM, WE HAVE TO RESTORE
C  VGSEY TO ITS ORIGINAL OBSERVED VALUE:
C
      VGSEY=VGSEY+29.78
C
      CALL RECALC_08 (IYEAR,IDAY,IHOUR,MIN,ISEC,VGSEX,VGSEY,VGSEZ)
C
      OPEN(UNIT=1,FILE='LINTEST1.DAT')
C
      WRITE (1,100) IYEAR, IDAY, IHOUR, MIN
 100  FORMAT (' IYEAR=',I4,' IDAY=',I3,' IHOUR=',I2,' MIN=',I2,/)
C
      PARMOD(1)=3.
      PARMOD(2)=-20.
      PARMOD(3)=3.
      PARMOD(4)=-5.

      WRITE (1,110) PARMOD(1)
 110  FORMAT('   SOLAR WIND RAM PRESSURE (NANOPASCALS):',F6.1,/)
C
      WRITE (1,120) PARMOD(2)
 120  FORMAT ('   DST-INDEX: ',F6.0,/)
C
      WRITE (1,130) PARMOD(3),PARMOD(4)
 130  FORMAT ('   IMF By and Bz: ',2F6.1,/)
C
C    THE LINE WILL BE TRACED FROM A GROUND (RE=1.0) FOOTPOINT WITH GEOGRAPHICAL
C     LONGITUDE 45 DEGREES AND LATITUDE 75 DEGREES:
C
      GEOLAT=75.
      GEOLON=45.
      RE=1.0

      PRINT *, '  GEOGRAPHIC (GEOCENTRIC) LATITUDE (degs): ',GEOLAT
      PRINT *, '  GEOGRAPHIC (GEOCENTRIC) LONGITUDE (degs): ',GEOLON

      COLAT=(90.-GEOLAT)*.01745329
      XLON=GEOLON*.01745329
C
C   CONVERT SPHERICAL COORDS INTO CARTESIAN :
C
      CALL SPHCAR_08 (RE,COLAT,XLON,XGEO,YGEO,ZGEO,1)
C
C   TRANSFORM GEOGRAPHICAL GEOCENTRIC COORDS INTO SOLAR WIND MAGNETOSPHERIC ONES:
C
      CALL GEOGSW_08 (XGEO,YGEO,ZGEO,XGSW,YGSW,ZGSW,1)
C
c   SPECIFY TRACING PARAMETERS:
C
      DIR=1.
C            (TRACE THE LINE WITH A FOOTPOINT IN THE NORTHERN HEMISPHERE, THAT IS,
C             ANTIPARALLEL TO THE MAGNETIC FIELD)
C
      DSMAX=1.0
C               (MAXIMAL SPACING BETWEEN THE FIELD LINE POINTS SET EQUAL TO 1 RE)
C
      ERR=0.0001
C                 (PERMISSIBLE STEP ERROR SET AT ERR=0.0001)
      RLIM=60.
C            (LIMIT THE TRACING REGION WITHIN R=60 Re)
C
      R0=1.
C            (LANDING POINT WILL BE CALCULATED ON THE SPHERE R=1,
C                   I.E. ON THE EARTH'S SURFACE)
      IOPT=0
C           (IN THIS EXAMPLE IOPT IS JUST A DUMMY PARAMETER,
C                 WHOSE VALUE DOES NOT MATTER)
C
C   TRACE THE FIELD LINE:
C
      CALL TRACE_08 (XGSW,YGSW,ZGSW,DIR,DSMAX,ERR,RLIM,R0,IOPT,
     * PARMOD,T96_01,IGRF_GSW_08,XF,YF,ZF,XX,YY,ZZ,M,LMAX)
C
C   WRITE THE RESULTS IN THE DATAFILE 'LINTEST1.DAT':
C
        WRITE (1,20)
 20     FORMAT('  THE LINE IN GSW COORDS:',/)
        WRITE (1,21) (XX(L),YY(L),ZZ(L),L=1,M)
 21     FORMAT ((2X,3F6.2))

      CLOSE(UNIT=1)
      END
