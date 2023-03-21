/**
 * Configuration header for FrontISTR
 */
#ifndef _FRONTISTRCONFIG_H_
#define _FRONTISTRCONFIG_H_

#define VERSION_MAJOR 5
#define VERSION_MINOR 5
#define VERSION_PATCH 0
#define GIT_HASH "0fe1a40f98fb0afe83df3718e65e97e67074cfb3"
#define BUILD_DATE "3/20/2023"

/* #undef _WINDOWS */
/* #undef NDEBUG */
/* #undef DEBUG */

#define WITH_TOOLS
/* #undef WITH_MPI */
#define WITH_OPENMP
/* #undef WITH_REFINER */
/* #undef WITH_REVOCAP */
/* #undef WITH_METIS */
/* #undef WITH_METIS_VER_4 */
#define WITH_MUMPS
#define WITH_LAPACK
/* #undef WITH_ML */
/* #undef WITH_PARMETIS */
#define WITH_MKL
/* #undef WITH_PARADISO */

#define HECMW_SERIAL
/* #undef HECMW_WITH_REFINER */
/* #undef HECMW_WITH_METIS */
/* #undef HECMW_PART_WITH_METIS */
/* #undef HECMW_METIS_VER */
/* #undef HECMW_WITH_ML */

#endif /* _FRONTISTRCONFIG_H_ */
