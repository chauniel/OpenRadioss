Copyright>        OpenRadioss
Copyright>        Copyright (C) 1986-2022 Altair Engineering Inc.
Copyright>    
Copyright>        This program is free software: you can redistribute it and/or modify
Copyright>        it under the terms of the GNU Affero General Public License as published by
Copyright>        the Free Software Foundation, either version 3 of the License, or
Copyright>        (at your option) any later version.
Copyright>    
Copyright>        This program is distributed in the hope that it will be useful,
Copyright>        but WITHOUT ANY WARRANTY; without even the implied warranty of
Copyright>        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Copyright>        GNU Affero General Public License for more details.
Copyright>    
Copyright>        You should have received a copy of the GNU Affero General Public License
Copyright>        along with this program.  If not, see <https://www.gnu.org/licenses/>.
Copyright>    
Copyright>    
Copyright>        Commercial Alternative: Altair Radioss Software 
Copyright>    
Copyright>        As an alternative to this open-source version, Altair also offers Altair Radioss 
Copyright>        software under a commercial license.  Contact Altair to discuss further if the 
Copyright>        commercial version may interest you: https://www.altair.com/radioss/.    
Chd|====================================================================
Chd|  I10TRC                        source/interfaces/intsort/i10trc.F
Chd|-- called by -----------
Chd|        I10MAIN_TRI                   source/interfaces/intsort/i10main_tri.F
Chd|-- calls ---------------
Chd|====================================================================
      SUBROUTINE I10TRC(
     1      NSN   ,I_STOK   ,CAND_N ,CAND_E,CAND_F,
     2      CAND_A,NUM_IMP  ,IND_IMP)
C-----------------------------------------------
C   I m p l i c i t   T y p e s
C-----------------------------------------------
#include      "implicit_f.inc"
C-----------------------------------------------
C   G l o b a l   P a r a m e t e r s
C-----------------------------------------------
#include      "mvsiz_p.inc"
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "units_c.inc"
#include      "warn_c.inc"
#include      "com04_c.inc"
#include      "param_c.inc"
C-----------------------------------------------
C   ROLE DE LA ROUTINE:
C   ===================
C   TRI sur N de CAND_N CAND_E CAND_F
C   et elimination des noeuds en rebond 
C-----------------------------------------------
C-----------------------------------------------
C   D u m m y   A r g u m e n t s
C-----------------------------------------------
      INTEGER I_STOK,NSN,NUM_IMP,IND_IMP(*)
      INTEGER CAND_N(*),CAND_E(*),CAND_A(*),
     .        CAND_T
C     REAL
      my_real
     .        CAND_F(6,*),CAND_TF
C-----------------------------------------------
C   L o c a l   V a r i a b l e s
C-----------------------------------------------
      INTEGER I, I_ST0,N,NN,K,
     .        IGET(I_STOK), IPUT(I_STOK)
C=======================================================================
C
      DO 100 N=1,NSN+3
 100  CAND_A(N) = 0
C=======================================================================
C     LES NOEUDS DELETES DEVIENNENT NSN+1 
C=======================================================================
      IF(NUM_IMP.GT.0)THEN
        DO I=1,I_STOK
         IPUT(I)=0
        END DO
        DO N=1,NUM_IMP
	  I= IND_IMP(N)
          IPUT(I)=1
        END DO
        DO I=1,I_STOK
         IF(CAND_F(1,I).EQ.ZERO.AND.IPUT(I).EQ.0)THEN
          CAND_N(I) = NSN+1
         ENDIF
        END DO
      ELSE
      DO 200 I=1,I_STOK
      IF(CAND_F(1,I).EQ.ZERO .OR. CAND_N(I) == 0)THEN
        CAND_N(I) = NSN+1
      ENDIF
 200  CONTINUE
      ENDIF !IF(NUM_IMP.GT.0)
C=======================================================================
C     CAND_A : DENOMBREMENT DE CHAQUE NOEUD 
C     APRES 300 CAND_A[3:NSN+3] : OCCURENCE DES NOEUDS [1:NSN+1] 
C=======================================================================
      DO 300 I=1,I_STOK
        NN = CAND_N(I) + 2
        CAND_A(NN) = CAND_A(NN) + 1
 300  CONTINUE
C=======================================================================
C     CAND_A : ADRESSE DE CHAQUE NOEUD 
C     APRES 400 CAND_A[2:NSN+2] : ADRESSE DES NOEUDS [1:NSN+1] 
C=======================================================================
      CAND_A(1) = 1
      CAND_A(2) = 1
      DO 400 N=3,NSN+2
 400  CAND_A(N) = CAND_A(N) + CAND_A(N-1)
C=======================================================================
C     IPUT(I) ADRESSE OU DOIT ALLER I
C     IGET(K) ADRESSE D'OU DOIT VENIR K
C     APRES 500 CAND_A[1:NSN+1] : ADRESSE DES NOEUDS [1:NSN+1] 
C=======================================================================
      DO 500 I=1,I_STOK
        NN = CAND_N(I) + 1
        K = CAND_A(NN)
        IPUT(I) = K
        IGET(K) = I
        CAND_A(NN) = CAND_A(NN) + 1
 500  CONTINUE
C=======================================================================
C     TRI DE CAND_N CAND_E CAND_F
C     SUR N CROISSANT
C     PERMUTATION 1 PASSE
C=======================================================================
      DO N=1,NUM_IMP
       K=IND_IMP(N)
       I = IPUT(K)
       IND_IMP(N)=I
      END DO
C      
      DO 600 K=1,I_STOK
        I = IGET(K)
C
        CAND_T = CAND_N(K)
        CAND_N(K) = CAND_N(I)
        CAND_N(I) = CAND_T
C
        CAND_T = CAND_E(K)
        CAND_E(K) = CAND_E(I)
        CAND_E(I) = CAND_T
C
        CAND_TF = CAND_F(1,K)
        CAND_F(1,K) = CAND_F(1,I)
        CAND_F(1,I) = CAND_TF
C
        CAND_TF = CAND_F(2,K)
        CAND_F(2,K) = CAND_F(2,I)
        CAND_F(2,I) = CAND_TF
C
        CAND_TF = CAND_F(3,K)
        CAND_F(3,K) = CAND_F(3,I)
        CAND_F(3,I) = CAND_TF
C
        CAND_TF = CAND_F(4,K)
        CAND_F(4,K) = CAND_F(4,I)
        CAND_F(4,I) = CAND_TF
C
        CAND_TF = CAND_F(5,K)
        CAND_F(5,K) = CAND_F(5,I)
        CAND_F(5,I) = CAND_TF
C
        CAND_TF = CAND_F(6,K)
        CAND_F(6,K) = CAND_F(6,I)
        CAND_F(6,I) = CAND_TF
C
        IPUT(I) = IPUT(K)
        IGET(IPUT(I)) = I
 600  CONTINUE
C=======================================================================
C     CAND_A[NSN+1] : ADRESSE DE NSN+1 
C=======================================================================
      I_STOK = CAND_A(NSN+1) - 1
      CAND_A(NSN+2) = CAND_A(NSN+1)
C

      RETURN
      END
