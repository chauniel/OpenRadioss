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
Chd|  R2R_INPUT_INIT                source/coupling/rad2rad/r2r_input_init.F
Chd|-- called by -----------
Chd|        RADIOSS2                      source/engine/radioss2.F      
Chd|-- calls ---------------
Chd|        GET_SOCK_IBUF_C               source/coupling/rad2rad/rad2rad_c.c
Chd|        GET_SOCK_RBUF_C               source/coupling/rad2rad/rad2rad_c.c
Chd|        SEND_SOCK_IBUF_C              source/coupling/rad2rad/rad2rad_c.c
Chd|        SEND_SOCK_RBUF_C              source/coupling/rad2rad/rad2rad_c.c
Chd|        SPMD_IBCAST                   source/mpi/generic/spmd_ibcast.F
Chd|        SPMD_RBCAST                   source/mpi/generic/spmd_rbcast.F
Chd|        RAD2R_MOD                     share/modules/rad2r.F         
Chd|====================================================================
      SUBROUTINE R2R_INPUT_INIT(IRUNN)
C----6---------------------------------------------------------------7---------8
C   M o d u l e s
C-----------------------------------------------
      USE RAD2R_MOD
C-----------------------------------------------       
C   I m p l i c i t   T y p e s
C-----------------------------------------------
#include      "implicit_f.inc"
C-----------------------------------------------
C   G l o b a l   P a r a m e t e r s
C-----------------------------------------------
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "chara_c.inc"
#include      "com01_c.inc"
#include      "com04_c.inc"
#include      "com06_c.inc"
#include      "com08_c.inc"
#include      "com10_c.inc"
#include      "param_c.inc"
#include      "scr17_c.inc"
#include      "scr24_c.inc"
#include      "rad2r_c.inc"
#include      "scr05_c.inc"
#include      "scr03_c.inc"
#include      "task_c.inc"
C-----------------------------------------------------------------
C   D u m m y   A r g u m e n t s
C-----------------------------------------------
      INTEGER IRUNN    
C-----------------------------------------------
C   L o c a l   V a r i a b l e s
C-----------------------------------------------
      INTEGER I
      my_real DT_LOC(9)
C-----------------------------------------------

      IF (ISPMD.EQ.0) THEN    
        CALL SEND_SOCK_IBUF_C(SOCK0,IDDOM,1)
        CALL SEND_SOCK_IBUF_C(SOCK0,TH_VERS,1) 
        CALL SEND_SOCK_IBUF_C(SOCK0,ITFORM,1)
        CALL SEND_SOCK_IBUF_C(SOCK0,NPART,1)
        CALL SEND_SOCK_IBUF_C(SOCK0,NUMMAT0-1,1) 
        CALL SEND_SOCK_IBUF_C(SOCK0,NUMGEO0,1)       
        CALL SEND_SOCK_RBUF_C(SOCK0,DTHIS,1)
        DO I=1,9
          DT_LOC(I)= EP30
          IF (NTHGRP01(I).GT.0) DT_LOC(I)=DTHIS1(I)
        END DO
        CALL SEND_SOCK_RBUF_C(SOCK0,DT_LOC,9)       
        CALL SEND_SOCK_IBUF_C(SOCK0,AFORM,9)
        CALL SEND_SOCK_IBUF_C(SOCK0,IRUNN,1)
                     
        CALL GET_SOCK_IBUF_C(SOCK0,TH_VERS,1)
        CALL GET_SOCK_RBUF_C(SOCK0,DTHIS,1)
        CALL GET_SOCK_RBUF_C(SOCK0,DTHIS1,9)
      ENDIF
      
      IF (NSPMD.GT.1) THEN
        CALL SPMD_IBCAST(TH_VERS,TH_VERS,1,1,0,2)
        CALL SPMD_RBCAST(DTHIS,DTHIS,1,1,0,2)
        CALL SPMD_RBCAST(DTHIS1,DTHIS1,9,1,0,2)     
      ENDIF
                
C-----Multidomains -> TH must be written with format 4 in order to be read by rad2rad ---
      ITFORM = 3      
      DO I=1,9
        AFORM(I)=3
      END DO

C
C******************************************************************************C
           
	  
C-----------------------------------------------------------------
      RETURN
      END
C
