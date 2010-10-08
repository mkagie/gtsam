/**
 * @file    GaussianBayesNet.h
 * @brief   Chordal Bayes Net, the result of eliminating a factor graph
 * @brief   GaussianBayesNet
 * @author  Frank Dellaert
 */

// \callgraph

#pragma once

#include <list>

#include <boost/shared_ptr.hpp>

#include <gtsam/base/types.h>
#include <gtsam/linear/GaussianConditional.h>
#include <gtsam/inference/BayesNet.h>

namespace gtsam {

	/** A Bayes net made from linear-Gaussian densities */
	typedef BayesNet<GaussianConditional> GaussianBayesNet;

	/** Create a scalar Gaussian */
	GaussianBayesNet scalarGaussian(varid_t key, double mu=0.0, double sigma=1.0);

	/** Create a simple Gaussian on a single multivariate variable */
	GaussianBayesNet simpleGaussian(varid_t key, const Vector& mu, double sigma=1.0);

	/**
	 * Add a conditional node with one parent
	 * |Rx+Sy-d|
	 */
	void push_front(GaussianBayesNet& bn, varid_t key, Vector d, Matrix R,
			varid_t name1, Matrix S, Vector sigmas);

	/**
	 * Add a conditional node with two parents
	 * |Rx+Sy+Tz-d|
	 */
	void push_front(GaussianBayesNet& bn, varid_t key, Vector d, Matrix R,
			varid_t name1, Matrix S, varid_t name2, Matrix T, Vector sigmas);

	/**
	 * Allocate a VectorConfig for the variables in a BayesNet
	 */
	boost::shared_ptr<VectorConfig> allocateVectorConfig(const GaussianBayesNet& bn);

	/**
	 * optimize, i.e. return x = inv(R)*d
	 */
	VectorConfig optimize(const GaussianBayesNet&);

	/**
	 * shared pointer version
	 */
	boost::shared_ptr<VectorConfig> optimize_(const GaussianBayesNet& bn);

	/*
	 * Backsubstitute
	 * (R*x)./sigmas = y by solving x=inv(R)*(y.*sigmas)
	 */
	VectorConfig backSubstitute(const GaussianBayesNet& bn, const VectorConfig& y);

	/*
	 * Backsubstitute in place, y is replaced with solution
	 */
	void backSubstituteInPlace(const GaussianBayesNet& bn, VectorConfig& y);

	/*
	 * Transpose Backsubstitute
	 * gy=inv(L)*gx by solving L*gy=gx.
	 * gy=inv(R'*inv(Sigma))*gx
	 * gz'*R'=gx', gy = gz.*sigmas
	 */
	VectorConfig backSubstituteTranspose(const GaussianBayesNet& bn, const VectorConfig& gx);

	/**
	 * Return (dense) upper-triangular matrix representation
	 */
	std::pair<Matrix, Vector> matrix(const GaussianBayesNet&);

  /**
   * Return RHS d as a VectorConfig
   * Such that backSubstitute(bn,d) = optimize(bn)
   */
  VectorConfig rhs(const GaussianBayesNet&);

} /// namespace gtsam
