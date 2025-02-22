!-------------------------------------------------------------------------------
! Copyright (c) 2019 FrontISTR Commons
! This software is released under the MIT License, see LICENSE.txt
!-------------------------------------------------------------------------------
!> This module provides conversion routines between HEC and FISTR data
!! structures and DOF based sparse matrix data structures (CSR/COO).
module m_sparse_matrix_contact
  use hecmw_util
  use m_hecmw_comm_f
  use m_sparse_matrix
  use m_sparse_matrix_hec
  implicit none

  private
  public :: sparse_matrix_contact_init_prof
  public :: sparse_matrix_contact_set_vals
  public :: sparse_matrix_contact_set_rhs
  public :: sparse_matrix_contact_get_rhs
  !
  public :: sparse_matrix_para_contact_set_vals
  public :: sparse_matrix_para_contact_set_rhs

contains

  !!$#define NEED_DIAG

  subroutine sparse_matrix_contact_init_prof(spMAT, hecMAT, hecLagMAT, hecMESH)
    type (sparse_matrix), intent(inout) :: spMAT
    type (hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange)
    type (hecmwST_local_mesh), intent(in) :: hecMESH
    integer(kind=kint) :: ndof, ndof2, N_loc, NL, NU, NZ, NN,nLag
    ndof=hecMAT%NDOF; ndof2=ndof*ndof
    NN = hecMAT%NP
    N_loc=hecMAT%N*ndof+hecLagMAT%num_lagrange
    if (sparse_matrix_is_sym(spMAT)) then
      NU=hecMAT%indexU(NN)
      NZ=NN*(ndof2+ndof)/2+NU*ndof2 &
        +hecLagMAT%numU_lagrange*ndof
    else
      NL=hecMAT%indexL(NN)
      NU=hecMAT%indexU(NN)
      NZ=(NN+NU+NL)*ndof2 &
        +(hecLagMAT%numL_lagrange+hecLagMAT%numU_lagrange)*ndof
    endif
    ! diagonal elements must be allocated for CRS format even if they are all zero
    if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) NZ=NZ+hecLagMAT%numL_lagrange
    call sparse_matrix_init(spMAT, N_loc, NZ)
    call sparse_matrix_hec_set_conv_ext(spMAT, hecMESH, ndof)
    if(hecLagMAT%num_lagrange > 0) print '(I3,A,4I10,A,2I10)', &
      hecmw_comm_get_rank(),' sparse_matrix_init ',hecMAT%N,hecMAT%NP,N_loc,NZ,' LAG',hecLagMAT%num_lagrange,spMAT%offset
    nLag = hecLagMAT%num_lagrange
    call hecmw_allreduce_I1(hecMESH, nLag, HECMW_SUM)
    if(hecmw_comm_get_rank() == 0) print *,'total number of contact nodes:',nLag
    spMAT%timelog = hecMAT%Iarray(22)
    if( hecmw_comm_get_size() > 1) then
      call sparse_matrix_para_contact_set_prof(spMAT, hecMAT, hecLagMAT)
    else
      call sparse_matrix_contact_set_prof(spMAT, hecMAT, hecLagMAT)
    endif
  end subroutine sparse_matrix_contact_init_prof

  subroutine sparse_matrix_contact_set_prof(spMAT, hecMAT, hecLagMAT)
    type(sparse_matrix), intent(inout) :: spMAT
    type(hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange)
    integer(kind=kint) :: ndof, ndof2
    integer(kind=kint) :: m, i, idof, i0, ii, ls, le, l, j, j0, jdof, jdofs
    !integer(kind=kint) :: offset_l, offset_d, offset_u
    ! CONVERT TO CSR or COO STYLE
    ndof=hecMAT%NDOF; ndof2=ndof*ndof
    m=1
    ii=0
    do i=1,hecMAT%N
      do idof=1,ndof
        i0=spMAT%offset+ndof*(i-1)
        ii=i0+idof
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) spMAT%IRN(ii-spMAT%offset)=m
        ! Lower
        if (.not. sparse_matrix_is_sym(spMAT)) then
          ls=hecMAT%indexL(i-1)+1
          le=hecMAT%indexL(i)
          do l=ls,le
            j=hecMAT%itemL(l)
            !if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
            !else
            !   j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            !endif
            !offset_l=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+jdof
              !spMAT%A(m)=hecMAT%AL(offset_l+jdof)
              m=m+1
            enddo
          enddo
        endif
        ! Diag
        !offset_d=ndof2*(i-1)+ndof*(idof-1)
        if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
        do jdof=jdofs,ndof
          if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
          spMAT%JCN(m)=i0+jdof
          !spMAT%A(m)=hecMAT%D(offset_d+jdof)
          m=m+1
        enddo
        ! Upper
        ls=hecMAT%indexU(i-1)+1
        le=hecMAT%indexU(i)
        do l=ls,le
          j=hecMAT%itemU(l)
          if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
          else
            j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
          endif
          !offset_u=ndof2*(l-1)+ndof*(idof-1)
          do jdof=1,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            spMAT%JCN(m)=j0+jdof
            !spMAT%A(m)=hecMAT%AU(offset_u+jdof)
            m=m+1
          enddo
        enddo
        ! Upper Lagrange
        if (hecLagMAT%num_lagrange > 0) then
          j0=spMAT%offset+ndof*hecMAT%N
          ls=hecLagMAT%indexU_lagrange(i-1)+1
          le=hecLagMAT%indexU_lagrange(i)
          do l=ls,le
            j=hecLagMAT%itemU_lagrange(l)
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            spMAT%JCN(m)=j0+j
            m=m+1
          enddo
        endif
      enddo
    enddo
    ! Lower Lagrange
    if (hecLagMAT%num_lagrange > 0) then
      i0=spMAT%offset+ndof*hecMAT%N
      do i=1,hecLagMAT%num_lagrange
        ii=i0+i
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) spMAT%IRN(ii-spMAT%offset)=m
        if (.not. sparse_matrix_is_sym(spMAT)) then
          ls=hecLagMAT%indexL_lagrange(i-1)+1
          le=hecLagMAT%indexL_lagrange(i)
          do l=ls,le
            j=hecLagMAT%itemL_lagrange(l)
            j0=spMAT%offset+ndof*(j-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+jdof
              m=m+1
            enddo
          enddo
        endif
        ! Diag( Only for CSR )
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) then
          spMAT%JCN(m)=ii
          m=m+1
        end if
      enddo
    endif
    if (spMAT%type == SPARSE_MATRIX_TYPE_CSR) spMAT%IRN(ii+1-spMAT%offset)=m
    if (m-1 < spMAT%NZ) spMAT%NZ=m-1
    if (m-1 /= spMAT%NZ) then
      write(*,*) 'ERROR: sparse_matrix_contact_set_prof on rank ',hecmw_comm_get_rank()
      write(*,*) 'm-1 = ',m-1,', NZ=',spMAT%NZ,',num_lagrange=',hecLagMAT%num_lagrange
      call hecmw_abort(hecmw_comm_get_comm())
    endif
  end subroutine sparse_matrix_contact_set_prof

  subroutine sparse_matrix_para_contact_set_prof(spMAT, hecMAT, hecLagMAT)
    type(sparse_matrix), intent(inout) :: spMAT
    type(hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange)
    integer(kind=kint) :: ndof, ndof2
    integer(kind=kint) :: m, i, idof, i0, ii, ls, le, l, j, j0, jdof, jdofs
    !integer(kind=kint) :: offset_l, offset_d, offset_u
    ! CONVERT TO CSR or COO STYLE
    if(spMAT%type /= SPARSE_MATRIX_TYPE_COO) then
      write(*,*) 'ERROR: sparse_matrix_para_contact_set_prof on rank ',hecmw_comm_get_rank()
      write(*,*) 'spMAT%type must be SPARSE_MATRIX_TYPE_COO, only for mumps'
      call hecmw_abort(hecmw_comm_get_comm())
    endif
    !    write(myrank+20,*)'matrix profile'
    ndof=hecMAT%NDOF; ndof2=ndof*ndof
    m=1
    do i=1,hecMAT%NP
      !     Internal Nodes First
      if(i <= hecMAT%N) then
        do idof=1,ndof
          i0=spMAT%offset+ndof*(i-1)
          ii=i0+idof
          ! Exact Lower Triangle (No External Nodes)
          if(.not. sparse_matrix_is_sym(spMAT)) then
            ls=hecMAT%indexL(i-1)+1
            le=hecMAT%indexL(i)
            do l=ls,le
              j=hecMAT%itemL(l)
              j0=spMAT%offset+ndof*(j-1)
              !offset_l=ndof2*(l-1)+ndof*(idof-1)
              do jdof=1,ndof
                if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
                spMAT%JCN(m)=j0+jdof
                !                write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
                !spMAT%A(m)=hecMAT%AL(offset_l+jdof)
                m=m+1
              enddo
            enddo
          endif
          ! Diag Part
          !offset_d=ndof2*(i-1)+ndof*(idof-1)
          if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
          do jdof=jdofs,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            spMAT%JCN(m)=i0+jdof
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
            !spMAT%A(m)=hecMAT%D(offset_d+jdof)
            m=m+1
          enddo
          ! Upper Triangle (Possible External Nodes)
          ls=hecMAT%indexU(i-1)+1
          le=hecMAT%indexU(i)
          do l=ls,le
            j=hecMAT%itemU(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
              if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
            endif
            !offset_u=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+jdof
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
              !spMAT%A(m)=hecMAT%AU(offset_u+jdof)
              m=m+1
            enddo
          enddo
          ! Upper COL Lagrange
          if (hecLagMAT%num_lagrange > 0) then
            j0=spMAT%offset+ndof*hecMAT%N
            ls=hecLagMAT%indexU_lagrange(i-1)+1
            le=hecLagMAT%indexU_lagrange(i)
            do l=ls,le
              j=hecLagMAT%itemU_lagrange(l)
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+j
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
              m=m+1
            enddo
          endif
        enddo
      else
        !       External Nodes
        i0 = spMAT%conv_ext(ndof*(i-hecMAT%N))-ndof
        do idof=1,ndof
          ii=i0+idof
          ! Lower
          ls=hecMAT%indexL(i-1)+1
          le=hecMAT%indexL(i)
          do l=ls,le
            j=hecMAT%itemL(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            endif
            if(sparse_matrix_is_sym(spMAT).and.j0 < i0) cycle
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+jdof
              !               write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
              !spMAT%A(m)=hecMAT%AL(offset_l+jdof)
              m=m+1
            enddo
          enddo

          ! Diag
          !offset_d=ndof2*(i-1)+ndof*(idof-1)
          if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
          do jdof=jdofs,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            spMAT%JCN(m)=i0+jdof
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
            !spMAT%A(m)=hecMAT%D(offset_d+jdof)
            m=m+1
          enddo
          !
          ! Upper
          ls=hecMAT%indexU(i-1)+1
          le=hecMAT%indexU(i)
          do l=ls,le
            j=hecMAT%itemU(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            endif
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
            !offset_u=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              spMAT%JCN(m)=j0+jdof
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
              !spMAT%A(m)=hecMAT%AU(offset_u+jdof)
              m=m+1
            enddo
          enddo
          !
          ! Upper COL Lagrange
          if (hecLagMAT%num_lagrange > 0) then
            j0=spMAT%offset+ndof*hecMAT%N
            ls=hecLagMAT%indexU_lagrange(i-1)+1
            le=hecLagMAT%indexU_lagrange(i)
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) then

            else
              do l=ls,le
                j=hecLagMAT%itemU_lagrange(l)
                if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
                spMAT%JCN(m)=j0+j
                !                write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
                m=m+1
              enddo
            endif
          endif
        enddo

      endif
    enddo
    ! Lower ROW Lagrange
    if (hecLagMAT%num_lagrange > 0) then
      i0=spMAT%offset+ndof*hecMAT%N
      do i=1,hecLagMAT%num_lagrange
        ii=i0+i
        ls=hecLagMAT%indexL_lagrange(i-1)+1
        le=hecLagMAT%indexL_lagrange(i)
        do l=ls,le
          j=hecLagMAT%itemL_lagrange(l)
          if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
          else
            j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
          endif
          if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
          !          j0=spMAT%OFFSET+ndof*(j-1)
          do jdof=1,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            spMAT%JCN(m)=j0+jdof
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m)
            m=m+1
          enddo
        enddo
      enddo
    endif

    !    if (sparse_matrix_is_sym(spMAT) .and. m-1 < spMAT%NZ) spMAT%NZ=m-1
    if (m-1 /= spMAT%NZ) then
      write(*,*) 'ERROR: sparse_matrix_para_contact_set_prof on rank ',hecmw_comm_get_rank()
      write(*,*) 'm-1 = ',m-1,', NZ=',spMAT%NZ,',num_lagrange=',hecLagMAT%num_lagrange
      call hecmw_abort(hecmw_comm_get_comm())
    endif
  end subroutine sparse_matrix_para_contact_set_prof

  subroutine sparse_matrix_contact_set_vals(spMAT, hecMAT, hecLagMAT)
    type(sparse_matrix), intent(inout) :: spMAT
    type(hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange)
    integer(kind=kint) :: ndof, ndof2
    integer(kind=kint) :: m, i, idof, i0, ii, ls, le, l, j, j0, jdof, jdofs
    integer(kind=kint) :: offset_l, offset_d, offset_u
    ndof=hecMAT%NDOF; ndof2=ndof*ndof
    m=1
    ii=0
    do i=1,hecMAT%N
      do idof=1,ndof
        i0=spMAT%offset+ndof*(i-1)
        ii=i0+idof
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR .and. spMAT%IRN(ii-spMAT%offset)/=m) &
          stop "ERROR: sparse_matrix_contact_set_a"
        ! Lower
        if (.not. sparse_matrix_is_sym(spMAT)) then
          ls=hecMAT%indexL(i-1)+1
          le=hecMAT%indexL(i)
          do l=ls,le
            j=hecMAT%itemL(l)
            !if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
            !else
            !   j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            !endif
            offset_l=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if ( spMAT%type==SPARSE_MATRIX_TYPE_COO ) then
                if( spMAT%IRN(m)/=ii ) stop "ERROR: sparse_matrix_contact_set_a"
              end if
              if (spMAT%JCN(m)/=j0+jdof) stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m)=hecMAT%AL(offset_l+jdof)
              m=m+1
            enddo
          enddo
        endif
        ! Diag
        offset_d=ndof2*(i-1)+ndof*(idof-1)
        if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
        do jdof=jdofs,ndof
          if ( spMAT%type==SPARSE_MATRIX_TYPE_COO ) then
            if( spMAT%IRN(m)/=ii ) stop "ERROR: sparse_matrix_contact_set_a"
          end if
          if (spMAT%JCN(m)/=i0+jdof) stop "ERROR: sparse_matrix_contact_set_a"
          spMAT%A(m)=hecMAT%D(offset_d+jdof)
          m=m+1
        enddo
        ! Upper
        ls=hecMAT%indexU(i-1)+1
        le=hecMAT%indexU(i)
        do l=ls,le
          j=hecMAT%itemU(l)
          if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
          else
            j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
          endif
          offset_u=ndof2*(l-1)+ndof*(idof-1)
          do jdof=1,ndof
            if ( spMAT%type==SPARSE_MATRIX_TYPE_COO ) then
              if( spMAT%IRN(m)/=ii ) stop "ERROR: sparse_matrix_contact_set_a"
            end if
            if (spMAT%JCN(m)/=j0+jdof) stop "ERROR: sparse_matrix_contact_set_a"
            spMAT%A(m)=hecMAT%AU(offset_u+jdof)
            m=m+1
          enddo
        enddo
        ! Upper Lagrange
        if (hecLagMAT%num_lagrange > 0) then
          j0=spMAT%offset+ndof*hecMAT%N
          ls=hecLagMAT%indexU_lagrange(i-1)+1
          le=hecLagMAT%indexU_lagrange(i)
          do l=ls,le
            if ( spMAT%type==SPARSE_MATRIX_TYPE_COO ) then
              if( spMAT%IRN(m)/=ii ) stop "ERROR: sparse_matrix_contact_set_a"
            end if
            if (spMAT%JCN(m)/=j0+hecLagMAT%itemU_lagrange(l)) &
              stop "ERROR: sparse_matrix_contact_set_a"
            spMAT%A(m)=hecLagMAT%AU_lagrange((l-1)*ndof+idof)
            m=m+1
          enddo
        endif
      enddo
    enddo
    ! Lower Lagrange
    if (hecLagMAT%num_lagrange > 0) then
      i0=spMAT%offset+ndof*hecMAT%N
      do i=1,hecLagMAT%num_lagrange
        ii=i0+i
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) spMAT%IRN(ii-spMAT%offset)=m
        if (.not. sparse_matrix_is_sym(spMAT)) then
          ls=hecLagMAT%indexL_lagrange(i-1)+1
          le=hecLagMAT%indexL_lagrange(i)
          do l=ls,le
            j=hecLagMAT%itemL_lagrange(l)
            j0=spMAT%offset+ndof*(j-1)
            do jdof=1,ndof
              if ( spMAT%type==SPARSE_MATRIX_TYPE_COO ) then
                if( spMAT%IRN(m)/=ii ) stop "ERROR: sparse_matrix_contact_set_a"
              end if
              if (spMAT%JCN(m)/=j0+jdof) &
                stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m)=hecLagMAT%AL_lagrange((l-1)*ndof+jdof)
              m=m+1
            enddo
          enddo
        endif
        ! Diag( Only for CSR )
        if (spMAT%type==SPARSE_MATRIX_TYPE_CSR) then
          spMAT%A(m)=0.d0
          m=m+1
        end if
      enddo
    endif

    if (spMAT%type == SPARSE_MATRIX_TYPE_CSR .and. spMAT%IRN(ii+1-spMAT%offset)/=m) &
      stop "ERROR: sparse_matrix_contact_set_a"
    if (m-1 /= spMAT%NZ) stop "ERROR: sparse_matrix_contact_set_a"
  end subroutine sparse_matrix_contact_set_vals

  subroutine sparse_matrix_para_contact_set_vals(spMAT, hecMAT, hecLagMAT, conMAT)
    type(sparse_matrix), intent(inout) :: spMAT
    type(hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange)
    type(hecmwST_matrix), intent(in) :: conMAT
    integer(kind=kint) :: ndof, ndof2
    integer(kind=kint) :: m, i, idof, i0, ii, ls, le, l, j, j0, jdof, jdofs
    integer(kind=kint) :: offset_l, offset_d, offset_u

    if(spMAT%type /= SPARSE_MATRIX_TYPE_COO) then
      write(*,*) 'ERROR: sparse_matrix_para_contact_set_vals on rank ',hecmw_comm_get_rank()
      write(*,*) 'spMAT%type must be SPARSE_MATRIX_TYPE_COO, only for mumps'
      call hecmw_abort(hecmw_comm_get_comm())
    endif
    !    write(myrank+20,*)'matrix values'
    ndof=hecMAT%NDOF; ndof2=ndof*ndof
    m=1
    do i=1,hecMAT%NP
      !     Internal Nodes First
      if(i <= hecMAT%N) then
        i0=spMAT%offset+ndof*(i-1)
        do idof=1,ndof
          ii=i0+idof
          ! Lower
          if (.not. sparse_matrix_is_sym(spMAT)) then
            ls=hecMAT%indexL(i-1)+1
            le=hecMAT%indexL(i)
            do l=ls,le
              j=hecMAT%itemL(l)
              if (j > hecMAT%N) stop 'j > hecMAT%N'
              j0=spMAT%offset+ndof*(j-1)
              offset_l=ndof2*(l-1)+ndof*(idof-1)
              do jdof=1,ndof
                if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                  stop "ERROR: sparse_matrix_contact_set_a"
                if (spMAT%JCN(m)/=j0+jdof)  &
                  stop "ERROR: sparse_matrix_contact_set_a"
                spMAT%A(m)=hecMAT%AL(offset_l+jdof) + conMAT%AL(offset_l+jdof)
                !                write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
                m=m+1
              enddo
            enddo
          endif
          ! Diag
          offset_d=ndof2*(i-1)+ndof*(idof-1)
          if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
          do jdof=jdofs,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
              stop "ERROR: sparse_matrix_contact_set_a"
            if (spMAT%JCN(m)/=i0+jdof)   &
              stop "ERROR: sparse_matrix_contact_set_a"
            !            print *,myrank,'spMAT',size(spMAT%A),m,size(hecMAT%D),size(conMAT%D),offset_d,jdof
            spMAT%A(m)=hecMAT%D(offset_d+jdof) + conMAT%D(offset_d+jdof)
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
            m=m+1
          enddo
          ! Upper
          ls=hecMAT%indexU(i-1)+1
          le=hecMAT%indexU(i)
          do l=ls,le
            j=hecMAT%itemU(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
              if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
            endif
            offset_u=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                stop "ERROR: sparse_matrix_contact_set_a"
              if (spMAT%JCN(m)/=j0+jdof)  &
                stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m)=hecMAT%AU(offset_u+jdof) + conMAT%AU(offset_u+jdof)
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
              m=m+1
            enddo
          enddo
          ! Upper Lagrange
          if (hecLagMAT%num_lagrange > 0) then
            j0=spMAT%offset+ndof*hecMAT%N
            ls=hecLagMAT%indexU_lagrange(i-1)+1
            le=hecLagMAT%indexU_lagrange(i)
            do l=ls,le
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                stop "ERROR: sparse_matrix_contact_set_a"
              if (spMAT%JCN(m)/=j0+hecLagMAT%itemU_lagrange(l)) &
                stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m)=hecLagMAT%AU_lagrange((l-1)*ndof+idof)
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
              m=m+1
            enddo
          endif
        enddo
      else
        !       External Nodes
        i0 = spMAT%conv_ext(ndof*(i-hecMAT%N))-ndof
        do idof=1,ndof
          ii=i0+idof
          ! Lower
          ls=hecMAT%indexL(i-1)+1
          le=hecMAT%indexL(i)
          do l=ls,le
            j=hecMAT%itemL(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            endif
            if(sparse_matrix_is_sym(spMAT).and.j0 < i0) cycle
            offset_l=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              !            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
              !            spMAT%JCN(m)=j0+jdof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                stop "ERROR: sparse_matrix_contact_set_a"
              if (spMAT%JCN(m)/=j0+jdof)   &
                stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m) = conMAT%AL(offset_l+jdof)
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
              m=m+1
            enddo
          enddo

          ! Diag
          offset_d=ndof2*(i-1)+ndof*(idof-1)
          if (sparse_matrix_is_sym(spMAT)) then; jdofs=idof; else; jdofs=1; endif
          do jdof=jdofs,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
              stop "ERROR: sparse_matrix_contact_set_a"
            if (spMAT%JCN(m)/=i0+jdof)  &
              stop "ERROR: sparse_matrix_contact_set_a"
            !            if (spMAT%type==SPARSE_MATRIX_TYPE_COO) spMAT%IRN(m)=ii
            !            spMAT%JCN(m)=i0+jdof
            spMAT%A(m) = conMAT%D(offset_d+jdof)
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
            m=m+1
          enddo
          !
          ! Upper
          ls=hecMAT%indexU(i-1)+1
          le=hecMAT%indexU(i)
          do l=ls,le
            j=hecMAT%itemU(l)
            if (j <= hecMAT%N) then
              j0=spMAT%offset+ndof*(j-1)
            else
              j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
            endif
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
            offset_u=ndof2*(l-1)+ndof*(idof-1)
            do jdof=1,ndof
              if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                stop "ERROR: sparse_matrix_contact_set_a"
              if (spMAT%JCN(m)/=j0+jdof) stop "ERROR: sparse_matrix_contact_set_a"
              spMAT%A(m) = conMAT%AU(offset_u+jdof)
              !              write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
              m=m+1
            enddo
          enddo
          !
          ! Upper Lagrange
          if (hecLagMAT%num_lagrange > 0) then
            j0=spMAT%offset+ndof*hecMAT%N
            ls=hecLagMAT%indexU_lagrange(i-1)+1
            le=hecLagMAT%indexU_lagrange(i)
            if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) then
              !             Do nothing
            else
              do l=ls,le
                if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
                  stop "ERROR: sparse_matrix_contact_set_a"
                if (spMAT%JCN(m)/=j0+hecLagMAT%itemU_lagrange(l)) &
                  stop "ERROR: sparse_matrix_contact_set_a"
                spMAT%A(m)=hecLagMAT%AU_lagrange((l-1)*ndof+idof)
                !                write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
                m=m+1
              enddo
            endif
          endif
        enddo

      endif
    enddo
    ! Lower ROW Lagrange
    if (hecLagMAT%num_lagrange > 0) then
      i0=spMAT%offset+ndof*hecMAT%N
      do i=1,hecLagMAT%num_lagrange
        ii=i0+i
        ls=hecLagMAT%indexL_lagrange(i-1)+1
        le=hecLagMAT%indexL_lagrange(i)
        do l=ls,le
          j=hecLagMAT%itemL_lagrange(l)
          if (j <= hecMAT%N) then
            j0=spMAT%offset+ndof*(j-1)
          else
            j0=spMAT%conv_ext(ndof*(j-hecMAT%N))-ndof
          endif
          if (sparse_matrix_is_sym(spMAT) .and. j0 < i0) cycle
          do jdof=1,ndof
            if (spMAT%type==SPARSE_MATRIX_TYPE_COO .and. spMAT%IRN(m)/=ii) &
              stop "ERROR: sparse_matrix_contact_set_a"
            if (spMAT%JCN(m)/=j0+jdof) &
              stop "ERROR: sparse_matrix_contact_set_a"
            spMAT%A(m)=hecLagMAT%AL_lagrange((l-1)*ndof+jdof)
            !            write(myrank+20,*)m,spMAT%IRN(m),spMAT%JCN(m),spMAT%A(m)
            m=m+1
          enddo
        enddo
      enddo
    endif
    !    print *,myrank,'spMAT%irn',ii,spMAT%offset, m,spMAT%NZ
    if (spMAT%type == SPARSE_MATRIX_TYPE_CSR) then
      if(spMAT%IRN(ii+1-spMAT%offset)/=m) &
        stop "ERROR: sparse_matrix_contact_set_a"
    endif
    if (m-1 /= spMAT%NZ) then
      write(*,*) 'ERROR: sparse_matrix_para_contact_set_vals on rank ',hecmw_comm_get_rank()
      write(*,*) 'm-1 = ',m-1,', NZ=',spMAT%NZ,',num_lagrange=',hecLagMAT%num_lagrange
      call hecmw_abort(hecmw_comm_get_comm())
    endif
  end subroutine sparse_matrix_para_contact_set_vals

  subroutine sparse_matrix_contact_set_rhs(spMAT, hecMAT, hecLagMAT)
    implicit none
    type (sparse_matrix), intent(inout) :: spMAT
    type (hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange
    integer :: nndof,npndof,ierr,i
    allocate(spMAT%rhs(spMAT%N_loc), stat=ierr)
    if (ierr /= 0) then
      write(*,*) " Allocation error, spMAT%rhs"
      call hecmw_abort(hecmw_comm_get_comm())
    endif
    nndof=hecMAT%N*hecMAT%ndof
    npndof=hecMAT%NP*hecMAT%ndof
    do i=1,nndof
      spMAT%rhs(i) = hecMAT%b(i)
    enddo
    ! skip external DOF in hecMAT%b
    if (hecLagMAT%num_lagrange > 0) then
      do i=1,hecLagMAT%num_lagrange
        spMAT%rhs(nndof+i) = hecMAT%b(npndof+i)
      enddo
    endif
  end subroutine sparse_matrix_contact_set_rhs

  subroutine sparse_matrix_para_contact_set_rhs(spMAT, hecMAT, hecLagMAT, conMAT)
    implicit none
    type (sparse_matrix), intent(inout) :: spMAT
    type (hecmwST_matrix), intent(in) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(in) :: hecLagMAT !< type hecmwST_matrix_lagrange
    type (hecmwST_matrix), intent(in) :: conMAT
    integer :: nndof,npndof,ierr,ndof,i,i0,j
    real(kind=kreal), allocatable :: rhs_con(:), rhs_con_sum(:)

    !   assemble contact components of external nodes only
    allocate(rhs_con(spMAT%N),stat=ierr)
    rhs_con(:) = 0.0D0
    ndof = hecMAT%ndof
    do i= hecMAT%N+1,hecMAT%NP
      i0=spMAT%conv_ext(ndof*(i-hecMAT%N))-ndof
      if((i0 < 0.or.i0 > spMAT%N)) then
        do j=1,ndof
          if(conMAT%b((i-1)*ndof+j) /= 0.0D0) then
            print *,hecmw_comm_get_rank(),'i0',i,spMAT%N,'conMAT%b',conMAT%b((i-1)*ndof+j)
            stop
          endif
        enddo
      else
        if(i0 > spMAT%N - ndof) then
          print *,hecmw_comm_get_rank(),'ext out',hecMAT%N,hecMAT%NP,i,i0
        endif
        do j=1,ndof
          if(conMAT%b((i-1)*ndof+j) /= 0.0D0) then
            rhs_con(i0+j) = conMAT%b((i-1)*ndof+j)
          endif
        enddo
      endif
    enddo
    allocate(rhs_con_sum(spMAT%N))
    call hecmw_allreduce_DP(rhs_con, rhs_con_sum, spMAT%N, hecmw_sum, hecmw_comm_get_comm())
    deallocate(rhs_con)

    allocate(spMAT%rhs(spMAT%N_loc), stat=ierr)
    if (ierr /= 0) then
      write(*,*) " Allocation error, spMAT%rhs"
      call hecmw_abort(hecmw_comm_get_comm())
    endif
    nndof=hecMAT%N*hecMAT%ndof
    npndof=hecMAT%NP*hecMAT%ndof
    do i=1,nndof
      spMAT%rhs(i) = rhs_con_sum(spMAT%offset+i) + hecMAT%b(i) + conMAT%b(i)
    end do
    deallocate(rhs_con_sum)
    if (hecLagMAT%num_lagrange > 0) then
      do i=1,hecLagMAT%num_lagrange
        spMAT%rhs(nndof+i) = conMAT%b(npndof+i)
      end do
    endif
  end subroutine sparse_matrix_para_contact_set_rhs

  subroutine sparse_matrix_contact_get_rhs(spMAT, hecMAT, hecLagMAT)
    implicit none
    type (sparse_matrix), intent(inout) :: spMAT
    type (hecmwST_matrix), intent(inout) :: hecMAT
    type (hecmwST_matrix_lagrange), intent(inout) :: hecLagMAT !< type hecmwST_matrix_lagrange
    integer :: nndof,npndof,i
    nndof=hecMAT%N*hecMAT%ndof
    npndof=hecMAT%NP*hecMAT%ndof
    do i=1,nndof
      hecMAT%x(i) = spMAT%rhs(i)
    enddo
    ! TODO: call update to get external DOF from neighboring domains???
    if (hecLagMAT%num_lagrange > 0) then
      do i=1,hecLagMAT%num_lagrange
        hecMAT%x(npndof+i) = spMAT%rhs(nndof+i)
      enddo
    endif
    deallocate(spMAT%rhs)
  end subroutine sparse_matrix_contact_get_rhs

end module m_sparse_matrix_contact
