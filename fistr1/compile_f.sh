export FRONTISTR_SRC=$HOME/WelSimLLC-github/FrontISTR
export WELSIM_LIBPACK=$HOME/WelSimLLC/CodeDV/libPack/Linux
export WELSIM_EXEC=$HOME/WelSimLLC/executable30
export INTEL_DIR=$HOME/mySys/intel/oneapi/compiler/2022.1.0/linux
export MKL_DIR=$HOME/mySys/intel/oneapi/mkl/2022.1.0


export BUILD_INC='-Jobj/Release/ -cpp -fallow-argument-mismatch -fallow-invalid-boz -DHECMW_METIS_VER=5 -DWITH_MKL -DHECMW_WITH_MUMPS  -O2 -Wall -I/home/liang/WelSimLLC/CodeDV/libPack/Linux/include/mumps -I/home/liang/WelSimLLC-github/FrontISTR/hecmw1/src/common -I/home/liang/WelSimLLC-github/FrontISTR/hecmw1/src/hecmw -I/home/liang/WelSimLLC-github/FrontISTR/hecmw1/src/solver -I/home/liang/WelSimLLC-github/FrontISTR/hecmw1/src/visualizer -I/home/liang/WelSimLLC-github/FrontISTR/fistr1/src/common -I/home/liang/WelSimLLC-github/FrontISTR/hecmw1/obj/Release -I/home/liang/WelSimLLC-github/FrontISTR/fistr1/obj/Release'


#common
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_contact.f90 -o obj/Release/src/common/fstr_contact.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_common.f90 -o obj/Release/src/common/fstr_ctrl_common.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_dynamic.f90 -o obj/Release/src/common/fstr_ctrl_dynamic.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_eigen.f90 -o obj/Release/src/common/fstr_ctrl_eigen.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_freq.f90 -o obj/Release/src/common/fstr_ctrl_freq.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_heat.f90 -o obj/Release/src/common/fstr_ctrl_heat.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_material.f90 -o obj/Release/src/common/fstr_ctrl_material.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_modifier.f90 -o obj/Release/src/common/fstr_ctrl_modifier.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_ctrl_static.f90 -o obj/Release/src/common/fstr_ctrl_static.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_debug_dump.f90 -o obj/Release/src/common/fstr_debug_dump.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_get_prop.f90 -o obj/Release/src/common/fstr_get_prop.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_precheck.f90 -o obj/Release/src/common/fstr_precheck.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_rcap_io.F90 -o obj/Release/src/common/fstr_rcap_io.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_setup.f90 -o obj/Release/src/common/fstr_setup.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/fstr_setup_util.f90 -o obj/Release/src/common/fstr_setup_util.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/common/hecmw2fstr_mesh_conv.f90 -o obj/Release/src/common/hecmw2fstr_mesh_conv.o


# lib
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/dynamic_mass.f90 -o obj/Release/src/lib/dynamic_mass.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/eigen_LIB.f90 -o obj/Release/src/lib/eigen_LIB.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/GaussM.f90 -o obj/Release/src/lib/GaussM.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_CAPACITY.f90 -o obj/Release/src/lib/heat_LIB_CAPACITY.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_CONDUCTIVITY.f90 -o obj/Release/src/lib/heat_LIB_CONDUCTIVITY.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_DFLUX.f90 -o obj/Release/src/lib/heat_LIB_DFLUX.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB.f90 -o obj/Release/src/lib/heat_LIB.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_FILM.f90 -o obj/Release/src/lib/heat_LIB_FILM.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_NEUTRAL.f90 -o obj/Release/src/lib/heat_LIB_NEUTRAL.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/heat_LIB_RADIATE.f90 -o obj/Release/src/lib/heat_LIB_RADIATE.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/m_common_struct.f90 -o obj/Release/src/lib/m_common_struct.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/m_fstr.f90 -o obj/Release/src/lib/m_fstr.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/m_out.f90 -o obj/Release/src/lib/m_out.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/m_step.f90 -o obj/Release/src/lib/m_step.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/m_timepoint.f90 -o obj/Release/src/lib/m_timepoint.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/precheck_LIB_2d.f90 -o obj/Release/src/lib/precheck_LIB_2d.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/precheck_LIB_3d.f90 -o obj/Release/src/lib/precheck_LIB_3d.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/precheck_LIB_shell.f90 -o obj/Release/src/lib/precheck_LIB_shell.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/solve_LINEQ.f90 -o obj/Release/src/lib/solve_LINEQ.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_1d.f90 -o obj/Release/src/lib/static_LIB_1d.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_2d.f90 -o obj/Release/src/lib/static_LIB_2d.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_3d.f90 -o obj/Release/src/lib/static_LIB_3d.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_3dIC.f90 -o obj/Release/src/lib/static_LIB_3dIC.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_3d_vp.f90 -o obj/Release/src/lib/static_LIB_3d_vp.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_beam.f90 -o obj/Release/src/lib/static_LIB_beam.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_C3D4_selectiveESNS.f90 -o obj/Release/src/lib/static_LIB_C3D4_selectiveESNS.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_C3D8.f90 -o obj/Release/src/lib/static_LIB_C3D8.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB.f90 -o obj/Release/src/lib/static_LIB.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_Fbar.f90 -o obj/Release/src/lib/static_LIB_Fbar.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/static_LIB_shell.f90 -o obj/Release/src/lib/static_LIB_shell.o

#lib/contact
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/contact/bucket_search.f90 -o obj/Release/src/lib/contact/bucket_search.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/contact/contact_lib.f90 -o obj/Release/src/lib/contact/contact_lib.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/contact/fstr_contact_def.F90 -o obj/Release/src/lib/contact/fstr_contact_def.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/contact/fstr_contact_param.f90 -o obj/Release/src/lib/contact/fstr_contact_param.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/contact/surf_ele.f90 -o obj/Release/src/lib/contact/surf_ele.o

#lib/element
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/element.f90 -o obj/Release/src/lib/element/element.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/hex20n.f90 -o obj/Release/src/lib/element/hex20n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/hex8n.f90 -o obj/Release/src/lib/element/hex8n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/line2n.f90 -o obj/Release/src/lib/element/line2n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/line3n.f90 -o obj/Release/src/lib/element/line3n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/prism15n.f90 -o obj/Release/src/lib/element/prism15n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/prism6n.f90 -o obj/Release/src/lib/element/prism6n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/quad4n.f90 -o obj/Release/src/lib/element/quad4n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/quad8n.f90 -o obj/Release/src/lib/element/quad8n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/quad9n.f90 -o obj/Release/src/lib/element/quad9n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/quadrature.f90 -o obj/Release/src/lib/element/quadrature.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/tet10n.f90 -o obj/Release/src/lib/element/tet10n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/tet4n.f90 -o obj/Release/src/lib/element/tet4n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/tri3n.f90 -o obj/Release/src/lib/element/tri3n.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/element/tri6n.f90 -o obj/Release/src/lib/element/tri6n.o

#lib/physics
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/calMatMatrix.f90 -o obj/Release/src/lib/physics/calMatMatrix.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/creep.f90 -o obj/Release/src/lib/physics/creep.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/ElasticLinear.f90 -o obj/Release/src/lib/physics/ElasticLinear.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/Elastoplastic.f90 -o obj/Release/src/lib/physics/Elastoplastic.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/Hyperelastic.f90 -o obj/Release/src/lib/physics/Hyperelastic.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/material.f90 -o obj/Release/src/lib/physics/material.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/mechgauss.f90 -o obj/Release/src/lib/physics/mechgauss.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/physics/Viscoelastic.f90 -o obj/Release/src/lib/physics/Viscoelastic.o

#lib/utilities
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/utilities/dictionary.f90 -o obj/Release/src/lib/utilities/dictionary.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/utilities/linkedlist.f90 -o obj/Release/src/lib/utilities/linkedlist.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/utilities/ttable.f90 -o obj/Release/src/lib/utilities/ttable.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/lib/utilities/utilities.f90 -o obj/Release/src/lib/utilities/utilities.o


#analysis/static
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_AddBC.f90 -o obj/Release/src/analysis/static/fstr_AddBC.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_AddContactStiff.f90 -o obj/Release/src/analysis/static/fstr_AddContactStiff.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_ass_load.f90 -o obj/Release/src/analysis/static/fstr_ass_load.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Ctrl_TimeInc.f90 -o obj/Release/src/analysis/static/fstr_Ctrl_TimeInc.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Cutback.f90 -o obj/Release/src/analysis/static/fstr_Cutback.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_mat_con_contact.f90 -o obj/Release/src/analysis/static/fstr_mat_con_contact.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_NodalStress.f90 -o obj/Release/src/analysis/static/fstr_NodalStress.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Residual.f90 -o obj/Release/src/analysis/static/fstr_Residual.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Restart.f90 -o obj/Release/src/analysis/static/fstr_Restart.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_solve_NLGEOM.f90 -o obj/Release/src/analysis/static/fstr_solve_NLGEOM.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_solve_NonLinear.f90 -o obj/Release/src/analysis/static/fstr_solve_NonLinear.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Spring.f90 -o obj/Release/src/analysis/static/fstr_Spring.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_StiffMatrix.f90 -o obj/Release/src/analysis/static/fstr_StiffMatrix.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/fstr_Update.f90 -o obj/Release/src/analysis/static/fstr_Update.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/make_result.f90 -o obj/Release/src/analysis/static/make_result.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/readtemp.f90 -o obj/Release/src/analysis/static/readtemp.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/static_echo.f90 -o obj/Release/src/analysis/static/static_echo.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/static/static_output.f90 -o obj/Release/src/analysis/static/static_output.o

#analysis/heat
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/fstr_solve_heat.f90 -o obj/Release/src/analysis/heat/fstr_solve_heat.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_echo.f90 -o obj/Release/src/analysis/heat/heat_echo.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_get_amplitude.f90 -o obj/Release/src/analysis/heat/heat_get_amplitude.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_init.f90 -o obj/Release/src/analysis/heat/heat_init.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_io.f90 -o obj/Release/src/analysis/heat/heat_io.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_bc_CFLUX.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_bc_CFLUX.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_bc_DFLUX.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_bc_DFLUX.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_bc_FILM.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_bc_FILM.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_bc_FIXT.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_bc_FIXT.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_bc_RADIATE.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_bc_RADIATE.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_boundary.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_boundary.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_capacity.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_capacity.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_mat_ass_conductivity.f90 -o obj/Release/src/analysis/heat/heat_mat_ass_conductivity.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_solve_main.f90 -o obj/Release/src/analysis/heat/heat_solve_main.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/heat/heat_solve_TRAN.f90 -o obj/Release/src/analysis/heat/heat_solve_TRAN.o

# analysis/dynamic
# analysis/dynamic/freq
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/freq/fstr_frequency_analysis.f90 -o obj/Release/src/analysis/dynamic/freq/fstr_frequency_analysis.o

# analysis/dynamic/mode
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_EIG_lanczos.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_EIG_lanczos.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_EIG_lanczos_util.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_EIG_lanczos_util.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_EIG_output.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_EIG_output.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_EIG_setMASS.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_EIG_setMASS.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_EIG_tridiag.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_EIG_tridiag.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/mode/fstr_solve_eigen.f90 -o obj/Release/src/analysis/dynamic/mode/fstr_solve_eigen.o

# analysis/dynamic/transit
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_mat_ass_bc_ac.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_mat_ass_bc_ac.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/fstr_EIG_lanczos_util.f90 -o obj/Release/src/analysis/dynamic/transit/fstr_EIG_lanczos_util.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_mat_ass_bc.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_mat_ass_bc.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_mat_ass_bc_vl.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_mat_ass_bc_vl.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_mat_ass_couple.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_mat_ass_couple.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_mat_ass_load.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_mat_ass_load.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_output.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_output.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/dynamic_var_init.f90 -o obj/Release/src/analysis/dynamic/transit/dynamic_var_init.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/fstr_dynamic_nlexplicit.f90 -o obj/Release/src/analysis/dynamic/transit/fstr_dynamic_nlexplicit.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/fstr_dynamic_nlimplicit.f90 -o obj/Release/src/analysis/dynamic/transit/fstr_dynamic_nlimplicit.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/fstr_solve_dynamic.f90 -o obj/Release/src/analysis/dynamic/transit/fstr_solve_dynamic.o
gfortran $BUILD_INC -c $FRONTISTR_SRC/fistr1/src/analysis/dynamic/transit/table_dyn.f90 -o obj/Release/src/analysis/dynamic/transit/table_dyn.o


