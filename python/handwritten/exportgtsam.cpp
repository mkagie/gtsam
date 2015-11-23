/* ----------------------------------------------------------------------------

 * GTSAM Copyright 2010, Georgia Tech Research Corporation, 
 * Atlanta, Georgia 30332-0415
 * All Rights Reserved
 * Authors: Frank Dellaert, et al. (see THANKS for the full author list)

 * See LICENSE for the license information

 * -------------------------------------------------------------------------- */

/**
 * @brief exports the python module 
 * @author Andrew Melim 
 * @author Ellon Paiva Mendes (LAAS-CNRS)
 **/

#include <boost/python.hpp>
#include <boost/cstdint.hpp>

#include <numpy_eigen/NumpyEigenConverter.hpp>

#include <gtsam/base/Matrix.h>
#include <gtsam/base/Vector.h>

using namespace boost::python;
using namespace gtsam;
using namespace std;

// Geometry
void exportPoint2();
void exportPoint3();
void exportRot2();
void exportRot3();
void exportPose2();
void exportPose3();
void exportPinholeCamera();

// Linear
void exportNoiseModels();

// Nonlinear
void exportValues();
void exportNonlinearFactor();
void exportNonlinearFactorGraph();
void exportLevenbergMarquardtOptimizer();
void exportISAM2();

// Slam
void exportPriorFactors();
void exportBetweenFactors();

// Utils (or Python wrapper specific functions)
void registerNumpyEigenConversions();

//-----------------------------------//

BOOST_PYTHON_MODULE(libgtsam_python){

  // Should be the first thing to be done
  import_array();
  
  registerNumpyEigenConversions();

  exportPoint2();
  exportPoint3();
  exportRot2();
  exportRot3();
  exportPose2();
  exportPose3();
  exportPinholeCamera();

  exportNoiseModels();

  exportValues();
  exportNonlinearFactor();
  exportNonlinearFactorGraph();
  exportLevenbergMarquardtOptimizer();
  exportISAM2();

  exportPriorFactors();
  exportBetweenFactors();
}