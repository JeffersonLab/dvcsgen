      SUBROUTINE VZERO(xarr,N)
      INTEGER N,i
      REAL xarr(N)
      do i=1,N
       xarr(i)=0
      enddo
      return
      end
c
c
c
       real function vdotmn(a,b,n)
       implicit none
       real a(4),b(4),s,s1,s2
       integer i,n
       s=0.0
       s1=0.0
       s2=0.0
       vdotmn=0.0
       do i=1,3
         s=s+a(i)*b(i)
         s1=s1+a(i)*a(i)
         s2=s2+b(i)*b(i)
       enddo
       if(n.eq.4) s=s-a(n)*b(n)
       if(s1.gt.0.0.and.s2.gt.0.0) vdotmn=s/sqrt(s1*s2)
       return
       end
c
c
c
       SUBROUTINE  MYRANMAR(VEC,LEN)
       implicit none
       REAL VEC(LEN)
       INTEGER i,LEN
c       CALL RANDOM_SEED(size=LEN)
       CALL RANDOM_NUMBER(VEC)
       return
      end 
c
c
      REAL FUNCTION ZBQLU01(DUMMY)
c      CALL RANDOM_SEED()
      CALL RANDOM_NUMBER(ZBQLU01)
      return
      end 
c
c
c
      REAL FUNCTION ZBQLNOR(MU,SIGMA)
*
*       Returns a random number Normally distributed with mean
*       MU and standard deviation |SIGMA|, using the Box-Muller
*       algorithm
*
      DOUBLE PRECISION THETA,R,PI
      REAL ZBQLU01,MU,SIGMA
      DOUBLE PRECISION SPARE
      INTEGER STATUS
      SAVE STATUS,SPARE,PI
      DATA STATUS /-1/

      IF (STATUS.EQ.-1) PI = 4.0D0*DATAN(1.0D0)

      IF (STATUS.LE.0) THEN
       THETA = 2.0D0*PI*ZBQLU01(0.0)
       R = DSQRT( -2.0D0*DLOG(1.0D0*ZBQLU01(0.0)) )
       ZBQLNOR = (R*DCOS(THETA))
       SPARE = (R*DSIN(THETA))
       STATUS = 1
      ELSE
       ZBQLNOR = SPARE
       STATUS = 0
      ENDIF
      
      ZBQLNOR = MU + (SIGMA*ZBQLNOR)

      END
c
      SUBROUTINE MYRNORML2(rran,lrun)
      integer lrun
      real rran(lrun)
c      call rnorml(rran,lrun)  ! from Mathlib
      call MYRNORML(rran,lrun)
      return
      end
******************************************************************
      SUBROUTINE MYRNORML(rran,lrun)
      integer lrun
      real rran(lrun)
      do i=1,lrun
           rran(i)=ZBQLNOR(0.0,1.0)
      enddo
      return
      end
c
c
c
      FUNCTION DIVDIF(F,A,NN,X,MM)
      DIMENSION A(NN),F(NN),T(20),D(20)
      LOGICAL EXTRA
      LOGICAL MFLAG,RFLAG
      DATA MMAX/10/
C
C  TABULAR INTERPOLATION USING SYMMETRICALLY PLACED ARGUMENT POINTS.
C
C  START.  FIND SUBSCRIPT IX OF X IN ARRAY A.
      IF( (NN.LT.2) .OR. (MM.LT.1) ) GO TO 20
      N=NN
      M=MIN0(MM,MMAX,N-1)
      MPLUS=M+1
      IX=0
      IY=N+1
      IF(A(1).GT.A(N)) GO TO 4
C     (SEARCH INCREASING ARGUMENTS.)
    1    MID=(IX+IY)/2
         IF(X.GE.A(MID)) GO TO 2
            IY=MID
            GO TO 3
C        (IF TRUE.)
    2       IX=MID
    3    IF(IY-IX.GT.1) GO TO 1
         GO TO 7
C     (SEARCH DECREASING ARGUMENTS.)
    4    MID=(IX+IY)/2
         IF(X.LE.A(MID)) GO TO 5
            IY=MID
            GO TO 6
C        (IF TRUE.)
    5       IX=MID
    6    IF(IY-IX.GT.1) GO TO 4
C
C  COPY REORDERED INTERPOLATION POINTS INTO (T(I),D(I)), SETTING
C  *EXTRA* TO TRUE IF M+2 POINTS TO BE USED.
    7 NPTS=M+2-MOD(M,2)
      IP=0
      L=0
      GO TO 9
    8    L=-L
         IF(L.GE.0) L=L+1
    9    ISUB=IX+L
         IF((1.LE.ISUB).AND.(ISUB.LE.N)) GO TO 10
C        (SKIP POINT.)
            NPTS=MPLUS
            GO TO 11
C        (INSERT POINT.)
   10       IP=IP+1
            T(IP)=A(ISUB)
            D(IP)=F(ISUB)
   11    IF(IP.LT.NPTS) GO TO 8
      EXTRA=NPTS.NE.MPLUS
C
C  REPLACE D BY THE LEADING DIAGONAL OF A DIVIDED-DIFFERENCE TABLE, SUP-
C  PLEMENTED BY AN EXTRA LINE IF *EXTRA* IS TRUE.
      DO 14 L=1,M
         IF(.NOT.EXTRA) GO TO 12
            ISUB=MPLUS-L
            D(M+2)=(D(M+2)-D(M))/(T(M+2)-T(ISUB))
   12    I=MPLUS
         DO 13 J=L,M
            ISUB=I-L
            D(I)=(D(I)-D(I-1))/(T(I)-T(ISUB))
            I=I-1
   13    CONTINUE
   14 CONTINUE
C
C  EVALUATE THE NEWTON INTERPOLATION FORMULA AT X, AVERAGING TWO VALUES
C  OF LAST DIFFERENCE IF *EXTRA* IS TRUE.
      SUM=D(MPLUS)
      IF(EXTRA) SUM=0.5*(SUM+D(M+2))
      J=M
      DO 15 L=1,M
         SUM=D(J)+(X-T(J))*SUM
         J=J-1
   15 CONTINUE
      DIVDIF=SUM
      RETURN
C
   20 CALL KERMTR('E105.1',LGFILE,MFLAG,RFLAG)
      IF(MFLAG) THEN
         IF(LGFILE.EQ.0) THEN
            IF(MM.LT.1) WRITE(*,101) MM
            IF(NN.LT.2) WRITE(*,102) NN
         ELSE
            IF(MM.LT.1) WRITE(LGFILE,101) MM
            IF(NN.LT.2) WRITE(LGFILE,102) NN
         ENDIF
      ENDIF
      IF(.NOT.RFLAG) CALL ABEND
      RETURN
  101 FORMAT( 7X, 'FUNCTION DIVDIF ... M =',I6,' IS LESS THAN 1')
  102 FORMAT( 7X, 'FUNCTION DIVDIF ... N =',I6,' IS LESS THAN 2')
      END
          SUBROUTINE KERSET(ERCODE,LGFILE,LIMITM,LIMITR)
                    PARAMETER(KOUNTE  =  28)
          CHARACTER*6         ERCODE,   CODE(KOUNTE)
          LOGICAL             MFLAG,    RFLAG
          INTEGER             KNTM(KOUNTE),       KNTR(KOUNTE)
          DATA      LOGF      /  0  /
          DATA      CODE(1), KNTM(1), KNTR(1)  / 'C204.1', 100, 100 /
          DATA      CODE(2), KNTM(2), KNTR(2)  / 'C204.2', 100, 100 /
          DATA      CODE(3), KNTM(3), KNTR(3)  / 'C204.3', 100, 100 /
          DATA      CODE(4), KNTM(4), KNTR(4)  / 'C205.1', 100, 100 /
          DATA      CODE(5), KNTM(5), KNTR(5)  / 'C205.2', 100, 100 /
          DATA      CODE(6), KNTM(6), KNTR(6)  / 'C205.3', 100, 100 /
          DATA      CODE(7), KNTM(7), KNTR(7)  / 'C305.1', 100, 100 /
          DATA      CODE(8), KNTM(8), KNTR(8)  / 'C308.1', 100, 100 /
          DATA      CODE(9), KNTM(9), KNTR(9)  / 'C312.1', 100, 100 /
          DATA      CODE(10),KNTM(10),KNTR(10) / 'C313.1', 100, 100 /
          DATA      CODE(11),KNTM(11),KNTR(11) / 'C336.1', 100, 100 /
          DATA      CODE(12),KNTM(12),KNTR(12) / 'C337.1', 100, 100 /
          DATA      CODE(13),KNTM(13),KNTR(13) / 'C341.1', 100, 100 /
          DATA      CODE(14),KNTM(14),KNTR(14) / 'D103.1', 100, 100 /
          DATA      CODE(15),KNTM(15),KNTR(15) / 'D106.1', 100, 100 /
          DATA      CODE(16),KNTM(16),KNTR(16) / 'D209.1', 100, 100 /
          DATA      CODE(17),KNTM(17),KNTR(17) / 'D509.1', 100, 100 /
          DATA      CODE(18),KNTM(18),KNTR(18) / 'E100.1', 100, 100 /
          DATA      CODE(19),KNTM(19),KNTR(19) / 'E104.1', 100, 100 /
          DATA      CODE(20),KNTM(20),KNTR(20) / 'E105.1', 100, 100 /
          DATA      CODE(21),KNTM(21),KNTR(21) / 'E208.1', 100, 100 /
          DATA      CODE(22),KNTM(22),KNTR(22) / 'E208.2', 100, 100 /
          DATA      CODE(23),KNTM(23),KNTR(23) / 'F010.1', 100,   0 /
          DATA      CODE(24),KNTM(24),KNTR(24) / 'F011.1', 100,   0 /
          DATA      CODE(25),KNTM(25),KNTR(25) / 'F012.1', 100,   0 /
          DATA      CODE(26),KNTM(26),KNTR(26) / 'F406.1', 100,   0 /
          DATA      CODE(27),KNTM(27),KNTR(27) / 'G100.1', 100, 100 /
          DATA      CODE(28),KNTM(28),KNTR(28) / 'G100.2', 100, 100 /
          LOGF  =  LGFILE
          IF(ERCODE .EQ. ' ')  THEN
             L  =  0
          ELSE
             DO 10  L = 1, 6
                IF(ERCODE(1:L) .EQ. ERCODE)  GOTO 12
  10            CONTINUE
  12         CONTINUE
          ENDIF
          DO 14     I  =  1, KOUNTE
             IF(L .EQ. 0)  GOTO 13
             IF(CODE(I)(1:L) .NE. ERCODE(1:L))  GOTO 14
  13         KNTM(I)  =  LIMITM
             KNTR(I)  =  LIMITR
  14         CONTINUE
          RETURN
          ENTRY KERMTR(ERCODE,LOG,MFLAG,RFLAG)
          LOG  =  LOGF
          DO 20     I  =  1, KOUNTE
             IF(ERCODE .EQ. CODE(I))  GOTO 21
  20         CONTINUE
          WRITE(*,1000)  ERCODE
          CALL ABEND
          RETURN
  21      RFLAG  =  KNTR(I) .GE. 1
          IF(RFLAG  .AND.  (KNTR(I) .LT. 100))  KNTR(I)  =  KNTR(I) - 1
          MFLAG  =  KNTM(I) .GE. 1
          IF(MFLAG  .AND.  (KNTM(I) .LT. 100))  KNTM(I)  =  KNTM(I) - 1
          IF(.NOT. RFLAG)  THEN
             IF(LOGF .LT. 1)  THEN
                WRITE(*,1001)  CODE(I)
             ELSE
                WRITE(LOGF,1001)  CODE(I)
             ENDIF
          ENDIF
          IF(MFLAG .AND. RFLAG)  THEN
             IF(LOGF .LT. 1)  THEN
                WRITE(*,1002)  CODE(I)
             ELSE
                WRITE(LOGF,1002)  CODE(I)
             ENDIF
          ENDIF
          RETURN
1000      FORMAT(' KERNLIB LIBRARY ERROR. ' /
     +           ' ERROR CODE ',A6,' NOT RECOGNIZED BY KERMTR',
     +           ' ERROR MONITOR. RUN ABORTED.')
1001      FORMAT(/' ***** RUN TERMINATED BY CERN LIBRARY ERROR ',
     +           'CONDITION ',A6)
1002      FORMAT(/' ***** CERN LIBRARY ERROR CONDITION ',A6)
          END
      SUBROUTINE ABEND
C
C CERN PROGLIB# Z035    ABEND           .VERSION KERNVAX  1.10  811126

      STOP '*** ABEND ***'
      END

*
* $Id: gauss64.F,v 1.1.1.1 1996/04/01 15:02:13 mclareni Exp $
*
* $Log: gauss64.F,v $
* Revision 1.1.1.1  1996/04/01 15:02:13  mclareni
* Mathlib gen
*
*
      FUNCTION DGAUSS(F,A,B,EPS)
*
* $Id: imp64.inc,v 1.1.1.1 1996/04/01 15:02:59 mclareni Exp $
*
* $Log: imp64.inc,v $
* Revision 1.1.1.1  1996/04/01 15:02:59  mclareni
* Mathlib gen
*
*
* imp64.inc
*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER NAME*(*)
      PARAMETER (NAME = 'DGAUSS')
      DIMENSION W(12),X(12)

      PARAMETER (Z1 = 1, HF = Z1/2, CST = 5*Z1/1000)

      DATA X( 1) /9.6028985649753623D-1/, W( 1) /1.0122853629037626D-1/
      DATA X( 2) /7.9666647741362674D-1/, W( 2) /2.2238103445337447D-1/
      DATA X( 3) /5.2553240991632899D-1/, W( 3) /3.1370664587788729D-1/
      DATA X( 4) /1.8343464249564980D-1/, W( 4) /3.6268378337836198D-1/
      DATA X( 5) /9.8940093499164993D-1/, W( 5) /2.7152459411754095D-2/
      DATA X( 6) /9.4457502307323258D-1/, W( 6) /6.2253523938647893D-2/
      DATA X( 7) /8.6563120238783174D-1/, W( 7) /9.5158511682492785D-2/
      DATA X( 8) /7.5540440835500303D-1/, W( 8) /1.2462897125553387D-1/
      DATA X( 9) /6.1787624440264375D-1/, W( 9) /1.4959598881657673D-1/
      DATA X(10) /4.5801677765722739D-1/, W(10) /1.6915651939500254D-1/
      DATA X(11) /2.8160355077925891D-1/, W(11) /1.8260341504492359D-1/
      DATA X(12) /9.5012509837637440D-2/, W(12) /1.8945061045506850D-1/

      H=0
      IF(B .EQ. A) GO TO 99
      CONST=CST/ABS(B-A)
      BB=A
    1 AA=BB
      BB=B
    2 C1=HF*(BB+AA)
      C2=HF*(BB-AA)
      S8=0
      DO 3 I = 1,4
      U=C2*X(I)
    3 S8=S8+W(I)*(F(C1+U)+F(C1-U))
      S16=0
      DO 4 I = 5,12
      U=C2*X(I)
    4 S16=S16+W(I)*(F(C1+U)+F(C1-U))
      S16=C2*S16
      IF(ABS(S16-C2*S8) .LE. EPS*(1+ABS(S16))) THEN
       H=H+S16
       IF(BB .NE. B) GO TO 1
      ELSE
       BB=C1
       IF(1+CONST*ABS(C2) .NE. 1) GO TO 2
       H=0
       write(*,*)' DGAUSS: D103.1, TOO HIGH ACCURACY REQUIRED'
       stop
c       GO TO 99
      END IF
   99 DGAUSS=H
      RETURN
      END
*
* $Id: gauss64.F,v 1.1.1.1 1996/04/01 15:02:13 mclareni Exp $
*
* $Log: gauss64.F,v $
* Revision 1.1.1.1  1996/04/01 15:02:13  mclareni
* Mathlib gen
*
*
      FUNCTION DGAUSS1(F,A,B,EPS)
*
* $Id: imp64.inc,v 1.1.1.1 1996/04/01 15:02:59 mclareni Exp $
*
* $Log: imp64.inc,v $
* Revision 1.1.1.1  1996/04/01 15:02:59  mclareni
* Mathlib gen
*
*
* imp64.inc
*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER NAME*(*)
      PARAMETER (NAME = 'DGAUSS')
      DIMENSION W(12),X(12)

      PARAMETER (Z1 = 1, HF = Z1/2, CST = 5*Z1/1000)

      DATA X( 1) /9.6028985649753623D-1/, W( 1) /1.0122853629037626D-1/
      DATA X( 2) /7.9666647741362674D-1/, W( 2) /2.2238103445337447D-1/
      DATA X( 3) /5.2553240991632899D-1/, W( 3) /3.1370664587788729D-1/
      DATA X( 4) /1.8343464249564980D-1/, W( 4) /3.6268378337836198D-1/
      DATA X( 5) /9.8940093499164993D-1/, W( 5) /2.7152459411754095D-2/
      DATA X( 6) /9.4457502307323258D-1/, W( 6) /6.2253523938647893D-2/
      DATA X( 7) /8.6563120238783174D-1/, W( 7) /9.5158511682492785D-2/
      DATA X( 8) /7.5540440835500303D-1/, W( 8) /1.2462897125553387D-1/
      DATA X( 9) /6.1787624440264375D-1/, W( 9) /1.4959598881657673D-1/
      DATA X(10) /4.5801677765722739D-1/, W(10) /1.6915651939500254D-1/
      DATA X(11) /2.8160355077925891D-1/, W(11) /1.8260341504492359D-1/
      DATA X(12) /9.5012509837637440D-2/, W(12) /1.8945061045506850D-1/

      H=0
      IF(B .EQ. A) GO TO 99
      CONST=CST/ABS(B-A)
      BB=A
    1 AA=BB
      BB=B
    2 C1=HF*(BB+AA)
      C2=HF*(BB-AA)
      S8=0
      DO 3 I = 1,4
      U=C2*X(I)
    3 S8=S8+W(I)*(F(C1+U)+F(C1-U))
      S16=0
      DO 4 I = 5,12
      U=C2*X(I)
    4 S16=S16+W(I)*(F(C1+U)+F(C1-U))
      S16=C2*S16
      IF(ABS(S16-C2*S8) .LE. EPS*(1+ABS(S16))) THEN
       H=H+S16
       IF(BB .NE. B) GO TO 1
      ELSE
       BB=C1
       IF(1+CONST*ABS(C2) .NE. 1) GO TO 2
       H=0
       write(*,*)' DGAUSS: D103.1, TOO HIGH ACCURACY REQUIRED'
       stop
c       GO TO 99
      END IF
   99 DGAUSS1=H
      RETURN
      END

      DOUBLE PRECISION FUNCTION DDILOG(X)

      DOUBLE PRECISION X,Y,T,S,A,PI3,PI6,ZERO,ONE,HALF,MALF,MONE,MTWO
      DOUBLE PRECISION C(0:18),H,ALFA,B0,B1,B2

      DATA ZERO /0.0D0/, ONE /1.0D0/
      DATA HALF /0.5D0/, MALF /-0.5D0/, MONE /-1.0D0/, MTWO /-2.0D0/
      DATA PI3 /3.28986 81336 96453D0/, PI6 /1.64493 40668 48226D0/

      DATA C( 0) / 0.42996 69356 08137 0D0/
      DATA C( 1) / 0.40975 98753 30771 1D0/
      DATA C( 2) /-0.01858 84366 50146 0D0/
      DATA C( 3) / 0.00145 75108 40622 7D0/
      DATA C( 4) /-0.00014 30418 44423 4D0/
      DATA C( 5) / 0.00001 58841 55418 8D0/
      DATA C( 6) /-0.00000 19078 49593 9D0/
      DATA C( 7) / 0.00000 02419 51808 5D0/
      DATA C( 8) /-0.00000 00319 33412 7D0/
      DATA C( 9) / 0.00000 00043 45450 6D0/
      DATA C(10) /-0.00000 00006 05784 8D0/
      DATA C(11) / 0.00000 00000 86121 0D0/
      DATA C(12) /-0.00000 00000 12443 3D0/
      DATA C(13) / 0.00000 00000 01822 6D0/
      DATA C(14) /-0.00000 00000 00270 1D0/
      DATA C(15) / 0.00000 00000 00040 4D0/
      DATA C(16) /-0.00000 00000 00006 1D0/
      DATA C(17) / 0.00000 00000 00000 9D0/
      DATA C(18) /-0.00000 00000 00000 1D0/

      IF(X .EQ. ONE) THEN
       DDILOG=PI6
       RETURN
      ELSE IF(X .EQ. MONE) THEN
       DDILOG=MALF*PI6
       RETURN
      END IF
      T=-X
      IF(T .LE. MTWO) THEN
       Y=MONE/(ONE+T)
       S=ONE
       A=-PI3+HALF*(LOG(-T)**2-LOG(ONE+ONE/T)**2)
      ELSE IF(T .LT. MONE) THEN
       Y=MONE-T
       S=MONE
       A=LOG(-T)
       A=-PI6+A*(A+LOG(ONE+ONE/T))
      ELSE IF(T .LE. MALF) THEN
       Y=(MONE-T)/T
       S=ONE
       A=LOG(-T)
       A=-PI6+A*(MALF*A+LOG(ONE+T))
      ELSE IF(T .LT. ZERO) THEN
       Y=-T/(ONE+T)
       S=MONE
       A=HALF*LOG(ONE+T)**2
      ELSE IF(T .LE. ONE) THEN
       Y=T
       S=ONE
       A=ZERO
      ELSE
       Y=ONE/T
       S=MONE
       A=PI6+HALF*LOG(T)**2
      END IF

      H=Y+Y-ONE
      ALFA=H+H
      B1=ZERO
      B2=ZERO
      DO 1 I = 18,0,-1
      B0=C(I)+ALFA*B1-B2
      B2=B1
    1 B1=B0
      DDILOG=-(S*(B0-H*B2)+A)
      RETURN
      END

*
* $Id: asinh64.F,v 1.1.1.1 1996/04/01 15:01:50 mclareni Exp $
*
* $Log: asinh64.F,v $
* Revision 1.1.1.1  1996/04/01 15:01:50  mclareni
* Mathlib gen
*
*
      FUNCTION DASINH(X)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      CHARACTER*(*) NAME
      PARAMETER(NAME='DASINH')
      DIMENSION C(0:19)

      DATA C( 0) / 0.90649 39198 46333 18D0/
      DATA C( 1) /-0.02704 21478 78869 64D0/
      DATA C( 2) / 0.00211 68145 57973 56D0/
      DATA C( 3) /-0.00021 76650 54603 40D0/
      DATA C( 4) / 0.00002 55196 04364 81D0/
      DATA C( 5) /-0.00000 32329 14485 29D0/
      DATA C( 6) / 0.00000 04310 66959 88D0/
      DATA C( 7) /-0.00000 00596 06134 55D0/
      DATA C( 8) / 0.00000 00084 69211 32D0/
      DATA C( 9) /-0.00000 00012 29008 59D0/
      DATA C(10) / 0.00000 00001 81376 79D0/
      DATA C(11) /-0.00000 00000 27138 46D0/
      DATA C(12) / 0.00000 00000 04107 37D0/
      DATA C(13) /-0.00000 00000 00627 70D0/
      DATA C(14) / 0.00000 00000 00096 72D0/
      DATA C(15) /-0.00000 00000 00015 01D0/
      DATA C(16) / 0.00000 00000 00002 34D0/
      DATA C(17) /-0.00000 00000 00000 37D0/
      DATA C(18) / 0.00000 00000 00000 06D0/
      DATA C(19) /-0.00000 00000 00000 01D0/

      V=ABS(X)
      IF(V .LE. 1) THEN
       H=2*V**2-1
       ALFA=H+H
       B1=0
       B2=0
       DO 1 I = 19,0,-1
       B0=C(I)+ALFA*B1-B2
       B2=B1
    1  B1=B0
       R=SIGN(V*(B0-B2),X)
      ELSE
       R=LOG(X+SQRT(1+X**2))
      ENDIF
      DASINH=R
      RETURN
      END
c
c
c
          FUNCTION FINT(NARG,ARG,NENT,ENT,TABLE)
C
C   INTERPOLATION ROUTINE. AUTHOR C. LETERTRE.
C   MODIFIED BY B. SCHORR, 1.07.1982.
C
          implicit real * 4 (a-h,o-z)
          INTEGER   NENT(*)
          REAL*4      ARG(*),   ENT(*),   TABLE(*)
          INTEGER   INDEX(32)
          REAL*4      WEIGHT(32)
          LOGICAL   MFLAG,    RFLAG
          FINT  =  0.
          IF(NARG .LT. 1  .OR.  NARG .GT. 5)  GOTO 300
          LMAX      =  0
          ISTEP     =  1
          KNOTS     =  1
          INDEX(1)  =  1
          WEIGHT(1) =  1.
          DO 100    N  =  1, NARG
             X     =  ARG(N)
             NDIM  =  NENT(N)
             LOCA  =  LMAX
             LMIN  =  LMAX + 1
             LMAX  =  LMAX + NDIM
             IF(NDIM .GT. 2)  GOTO 10
             IF(NDIM .EQ. 1)  GOTO 100
             H  =  X - ENT(LMIN)
             IF(H .EQ. 0.)  GOTO 90
             ISHIFT  =  ISTEP
             IF(X-ENT(LMIN+1) .EQ. 0.)  GOTO 21
             ISHIFT  =  0
             ETA     =  H / (ENT(LMIN+1) - ENT(LMIN))
             GOTO 30
  10         LOCB  =  LMAX + 1
  11         LOCC  =  (LOCA+LOCB) / 2
             IF(X-ENT(LOCC))  12, 20, 13
  12         LOCB  =  LOCC
             GOTO 14
  13         LOCA  =  LOCC
  14         IF(LOCB-LOCA .GT. 1)  GOTO 11
             LOCA    =  MIN0( MAX0(LOCA,LMIN), LMAX-1 )
             ISHIFT  =  (LOCA - LMIN) * ISTEP
             ETA     =  (X - ENT(LOCA)) / (ENT(LOCA+1) - ENT(LOCA))
             GOTO 30
  20         ISHIFT  =  (LOCC - LMIN) * ISTEP
  21         DO 22  K  =  1, KNOTS
                INDEX(K)  =  INDEX(K) + ISHIFT
  22            CONTINUE
             GOTO 90
  30         DO 31  K  =  1, KNOTS
                INDEX(K)         =  INDEX(K) + ISHIFT
                INDEX(K+KNOTS)   =  INDEX(K) + ISTEP
                WEIGHT(K+KNOTS)  =  WEIGHT(K) * ETA
                WEIGHT(K)        =  WEIGHT(K) - WEIGHT(K+KNOTS)
  31            CONTINUE
             KNOTS  =  2*KNOTS
  90         ISTEP  =  ISTEP * NDIM
 100         CONTINUE
          DO 200    K  =  1, KNOTS
             I  =  INDEX(K)
             FINT  =  FINT + WEIGHT(K) * TABLE(I)
 200         CONTINUE
          RETURN
 300      CALL KERMTR('E104.1',LGFILE,MFLAG,RFLAG)
          IF(MFLAG) THEN
             IF(LGFILE .EQ. 0) THEN
                WRITE(*,1000) NARG
             ELSE
                WRITE(LGFILE,1000) NARG
             ENDIF
          ENDIF
          IF(.NOT. RFLAG) CALL ABEND
          RETURN
1000      FORMAT( 7X, 24HFUNCTION FINT ... NARG =,I6,
     +              17H NOT WITHIN RANGE)
          END
c
c
c
c
      SUBROUTINE UCOPY(SOURCE,TARGET,NA)
C. COPY NA WORDS FROM SOURCE TO TARGET ARRAY
      INTEGER*4 SOURCE(2),TARGET(2),NA,ZERO
      DATA ZERO/0/
      IF(NA.LE.ZERO) GOTO 77777
      IA=NA
      DO 1 I=1,IA
    1 TARGET(I)=SOURCE(I)
77777 RETURN
      END

