/*
 * SPQRUtil.h
 *
 *   Created on: Jul 1, 2010
 *       Author: nikai
 *  Description: the utility functions for SPQR
 */

#pragma once

#include <gtsam/base/Matrix.h>

#ifdef GT_USE_LAPACK
#include <gtsam/spqr_mini/spqr_subset.hpp>

namespace gtsam {

	/** make stairs and speed up householder_spqr. Stair is defined as the row index of where zero entries start in each column */
	long* MakeStairs(Matrix &A);

	/** Householder tranformation, zeros below diagonal */
	void householder_spqr(Matrix &A, long* Stair = NULL);

	void householder_spqr_colmajor(boost::numeric::ublas::matrix<double, boost::numeric::ublas::column_major>& A, long *Stair);
}
#endif
