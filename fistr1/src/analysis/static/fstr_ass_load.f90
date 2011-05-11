!======================================================================!
!                                                                      !
! Software Name : FrontISTR Ver. 3.0                                   !
!                                                                      !
!      Module Name : Static Analysis                                   !
!                                                                      !
!            Written by X. YUAN(AdavanceSoft), K. Sato(Advancesoft)    !
!                                                                      !
!                                                                      !
!      Contact address :  IIS,The University of Tokyo, CISS            !
!                                                                      !
!      "Structural Analysis for Large Scale Assembly"                  !
!                                                                      !
!======================================================================!
!======================================================================!
!
!> \brief  This module provides functions to take into acount external load
!!
!>  \author     X. YUAN(AdavanceSoft), K. Sato(Advancesoft)
!>  \date       2009/08/26
!>  \version    0.00
!!
!======================================================================!
module m_fstr_ass_load
    implicit none
    contains
!
!======================================================================!
!> This subroutine assmble following external force into fstrSOLID%GL and hecMAT%B afterwards
!>  -#  concentrated nodal force
!>  -#  surface pressure
!>  -#  volume force
!>  -#  thermal force

    subroutine fstr_ass_load(cstep, hecMESH, hecMAT, fstrSOLID)
!======================================================================!
      use m_fstr
      use m_static_lib
      use m_fstr_precheck
      use mMechGauss
      use mReadTemp
      use mULoad
      integer, intent(in)                  :: cstep     !< current step
      type (hecmwST_matrix),intent(inout)  :: hecMAT    !< hecmw matrix
      type (hecmwST_local_mesh),intent(in) :: hecMESH   !< hecmw mesh
      type (fstr_solid),intent(inout)      :: fstrSOLID !< fstr_solid

      real(kind=kreal) :: xx(20), yy(20), zz(20)
      real(kind=kreal) :: params(0:6)
      real(kind=kreal) :: vect(60)
      integer(kind=kint) :: iwk(60)
      integer(kind=kint) :: nodLocal(20)
      real(kind=kreal) :: tt(20), tt0(20), factor
      integer(kind=kint) :: ndof, ig0, ig, ityp, ltype, iS0, iE0, ik, in, i, j
      integer(kind=kint) :: icel, ic_type, nn, iS, isect, id, iset, nsize
      integer(kind=kint) :: itype, iE, ierror, grpid
      real(kind=kreal) :: fval, rho, thick, pa1
      logical :: fg_surf
      integer(kind=kint) :: tstep
      type( tMaterial ), pointer :: material     !< material information

      ndof = hecMAT%NDOF
      factor = fstrSOLID%factor(2)
      if( cstep<=fstrSOLID%nstep_tot .and. fstrSOLID%step_ctrl(cstep)%solution==stepVisco ) factor=1.d0
! -------------------------------------------------------------------
!  CLOAD
! -------------------------------------------------------------------
      fstrSOLID%GL(:)=0.d0
      do ig0= 1, fstrSOLID%CLOAD_ngrp_tot
        grpid = fstrSOLID%CLOAD_ngrp_GRPID(ig0)
        if( .not. fstr_isLoadActive( fstrSOLID, grpid, cstep ) ) cycle
        ig= fstrSOLID%CLOAD_ngrp_ID(ig0)
        ityp= fstrSOLID%CLOAD_ngrp_DOF(ig0)
        fval= fstrSOLID%CLOAD_ngrp_val(ig0)
        iS0= hecMESH%node_group%grp_index(ig-1) + 1
        iE0= hecMESH%node_group%grp_index(ig  )
        do ik= iS0, iE0
          in   = hecMESH%node_group%grp_item(ik)
          fstrSOLID%GL(ndof*(in-1)+ityp)=fstrSOLID%GL(ndof*(in-1)+ityp)+fval
        enddo
      enddo
!
!
! -------------------------------------------------------------------
!  DLOAD
! -------------------------------------------------------------------
      do ig0= 1, fstrSOLID%DLOAD_ngrp_tot
        grpid = fstrSOLID%DLOAD_ngrp_GRPID(ig0)
        if( .not. fstr_isLoadActive( fstrSOLID, grpid, cstep ) ) cycle
        ig= fstrSOLID%DLOAD_ngrp_ID(ig0)
        ltype= fstrSOLID%DLOAD_ngrp_LID(ig0)
        do i=0,6
          params(i)= fstrSOLID%DLOAD_ngrp_params(i,ig0)
        enddo
! ----- START & END
        fg_surf = (ltype == 100)
        if( fg_surf ) then                  ! surface group
          iS0= hecMESH%surf_group%grp_index(ig-1) + 1
          iE0= hecMESH%surf_group%grp_index(ig  )
        else                                ! element group
          iS0= hecMESH%elem_group%grp_index(ig-1) + 1
          iE0= hecMESH%elem_group%grp_index(ig  )
        endif
        do ik= iS0, iE0
          if( fg_surf ) then                ! surface group
            ltype  = hecMESH%surf_group%grp_item(2*ik)*10
            icel   = hecMESH%surf_group%grp_item(2*ik-1)
            ic_type= hecMESH%elem_type(icel)
          else                              ! element group
            icel   = hecMESH%elem_group%grp_item(ik)
            ic_type= hecMESH%elem_type(icel)
          endif
          if (hecmw_is_etype_link(ic_type)) cycle
         ! if( ic_type==3422 ) ic_type=342
          nn = hecmw_get_max_node(ic_type)
! ----- node ID
          iS= hecMESH%elem_node_index(icel-1)
          do j=1,nn
            nodLOCAL(j)= hecMESH%elem_node_item (iS+j)
! ----- nodal coordinate
            xx(j)=hecMESH%node(3*nodLOCAL(j)-2)
            yy(j)=hecMESH%node(3*nodLOCAL(j)-1)
            zz(j)=hecMESH%node(3*nodLOCAL(j)  )
! ----- create iwk array ***
            do i=1,ndof
              iwk(ndof*(j-1)+i)=ndof*(nodLOCAL(j)-1)+i
            enddo
          enddo
! ----- section  ID
          isect= hecMESH%section_ID(icel)
! ----- Get Properties
          material => fstrSOLID%elements(icel)%gausses(1)%pMaterial
          rho = material%variables(M_DENSITY)
          call fstr_get_thickness(hecMESH,isect,thick)
! ----- Section Data
          if (ndof==2) then
            id=hecMESH%section%sect_opt(isect)
            if( id==0 ) then
              iset=1
            else if( id==1 ) then
              iset=0
            else if( id==2) then
              iset=2
            endif
            pa1=1.d0
          endif
! ----- Create local stiffness
          if (ic_type==241 .or.ic_type==242 .or. ic_type==231 .or. ic_type==232 .or. ic_type==2322 ) then
            call DL_C2(ic_type,nn,xx(1:nn),yy(1:nn),rho,pa1,ltype,params,vect(1:nn*ndof),nsize,iset)
			
          else if (ic_type==341 .or. ic_type==351 .or. ic_type==361 .or.     &
                   ic_type==342 .or. ic_type==352 .or. ic_type==362 ) then
            call DL_C3(ic_type,nn,xx(1:nn),yy(1:nn),zz(1:nn),rho,ltype,params,vect(1:nn*ndof),nsize)
!
          else if ( ic_type.eq.741 ) then
            call DL_S4( xx,yy,zz,rho,thick,ltype,params,vect,nsize )
          else if ( ic_type.EQ.731 ) then
            call DL_S3( xx,yy,zz,rho,thick,ltype,params,vect,nsize )
          endif
! ----- Add vector
          do j=1,nsize
              fstrSOLID%GL( iwk(j) )=fstrSOLID%GL( iwk(j) )+vect(j)
          enddo
        enddo
      enddo
	  
! -----Uload
      call uloading( cstep, factor, fstrSOLID%GL )
	  
!C
!C Update for fstrSOLID%GL
!C 
      if( hecMESH%n_dof==3 ) then
        call hecmw_update_3_R (hecMESH,fstrSOLID%GL,hecMESH%n_node)
      else if( hecMESH%n_dof==2 ) then
        call hecmw_update_2_R (hecMESH,fstrSOLID%GL,hecMESH%n_node)
      endif
	  
      do i=1, hecMESH%n_node*  hecMESH%n_dof
          hecMAT%B(i)=factor*fstrSOLID%GL(i)-fstrSOLID%QFORCE(i)
      enddo
!
!
! -------------------------------------------------------------------
!  TLOAD : THERMAL LOAD USING TEMPERATURE
! -------------------------------------------------------------------
!C
!C Set Temperature
!C
      if( fstrSOLID%TEMP_ngrp_tot > 0 .or. fstrSOLID%TEMP_irres > 0 ) then
        fstrSOLID%reftemp(:) = fstrSOLID%temperature(:)
        do ig0= 1, fstrSOLID%TEMP_ngrp_tot
          grpid = fstrSOLID%TEMP_ngrp_GRPID(ig0)
          if( .not. fstr_isLoadActive( fstrSOLID, grpid, cstep ) ) cycle
          ig= fstrSOLID%TEMP_ngrp_ID(ig0)
          fval=fstrSOLID%TEMP_ngrp_val(ig0)
          iS0= hecMESH%node_group%grp_index(ig-1) + 1
          iE0= hecMESH%node_group%grp_index(ig  )
          do ik= iS0, iE0
            in   = hecMESH%node_group%grp_item(ik)
            pa1 = fstrSOLID%reftemp( in )
            fstrSOLID%temperature( in ) = fval*factor
          enddo
        enddo

        if( fstrSOLID%TEMP_irres > 0 ) then
          call read_temperature_result(hecMESH, fstrSOLID%TEMP_tstep, fstrSOLID%temperature)
        endif

! ----- element TYPE loop.
        do itype= 1, hecMESH%n_elem_type
          iS= hecMESH%elem_type_index(itype-1) + 1
          iE= hecMESH%elem_type_index(itype  )
          ic_type= hecMESH%elem_type_item(itype)
          if (hecmw_is_etype_link(ic_type)) cycle
! ----- Set number of nodes
          nn = hecmw_get_max_node(ic_type)
! ----- element loop
          do icel= iS, iE
! ----- node ID
            iS= hecMESH%elem_node_index(icel-1)
            do j=1,nn
              nodLOCAL(j)=hecMESH%elem_node_item(iS+j)
! ----- nodal coordinate
              xx(j)=hecMESH%node(3*nodLOCAL(j)-2)
              yy(j)=hecMESH%node(3*nodLOCAL(j)-1)
              zz(j)=hecMESH%node(3*nodLOCAL(j)  )
              tt0(j)=fstrSOLID%reftemp( nodLOCAL(j) ) 
              tt(j) = fstrSOLID%temperature( nodLOCAL(j) ) 
! ----- create iwk array ***
              do i=1,ndof
                iwk(ndof*(j-1)+i)=ndof*(nodLOCAL(j)-1)+i
              enddo
            enddo
! ----- section  Data
            isect= hecMESH%section_ID(icel)
            if (ndof==2) then
              id=hecMESH%section%sect_opt(isect)
              if( id==0 ) then
                iset=1
              else if( id==1 ) then
                iset=0
              else if( id==2 ) then
                iset=2
              endif
              pa1=1.d0
            endif
! ----- Create local stiffness
            if (ic_type==241 .or. ic_type==242 .or. ic_type==231 .or. ic_type==232 ) then
              call TLOAD_C2(ic_type,nn,xx(1:nn),yy(1:nn),tt(1:nn),tt0(1:nn),  &
			         fstrSOLID%elements(icel)%gausses,pa1,iset,vect(1:nn*2) )

            else if (ic_type==341 .or. ic_type==351 .or. ic_type==361 .or.  &
                     ic_type==342 .or. ic_type==352 .or. ic_type==362 ) then
              call TLOAD_C3(ic_type,nn,xx(1:nn),yy(1:nn),zz(1:nn),tt(1:nn),tt0(1:nn), &
                            fstrSOLID%elements(icel)%gausses,vect(1:nn*ndof) )

            else if ( ic_type.eq.741 .or. ic_type.eq.731 ) then
              if( myrank == 0 ) then
                WRITE(IMSG,*) '*------------------------', &
                               '-------------------*'
                WRITE(IMSG,*) ' Thermal loading option for shell elements', &
                               'not yet available.'
                WRITE(IMSG,*) '*------------------------', &
                               '-------------------*'
                call hecmw_abort( hecmw_comm_get_comm())
              endif
            endif
! ----- Add vector
            do j=1,ndof*nn
          !     fstrSOLID%GL( iwk(j) )=fstrSOLID%GL( iwk(j) )+vect(j)
               hecMAT%B(iwk(j)) = hecMAT%B(iwk(j))+ vect(j)
            enddo
          enddo
        enddo
      endif

    end subroutine fstr_ass_load

end module m_fstr_ass_load