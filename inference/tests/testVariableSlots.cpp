/**
 * @file    testVariableSlots.cpp
 * @brief   
 * @author  Richard Roberts
 * @created Oct 5, 2010
 */

#include <gtsam/CppUnitLite/TestHarness.h>
#include <gtsam/base/TestableAssertions.h>

#include <gtsam/inference/VariableSlots-inl.h>
#include <gtsam/inference/SymbolicFactorGraph.h>

#include <boost/assign/std/vector.hpp>

using namespace gtsam;
using namespace std;
using namespace boost::assign;

/* ************************************************************************* */
TEST(VariableSlots, constructor) {

  SymbolicFactorGraph fg;
  fg.push_factor(2, 3);
  fg.push_factor(0, 1);
  fg.push_factor(0, 2);
  fg.push_factor(5, 9);

  VariableSlots actual(fg);

  static const size_t none = numeric_limits<size_t>::max();
  VariableSlots expected((SymbolicFactorGraph()));
  expected[0] += none, 0, 0, none;
  expected[1] += none, 1, none, none;
  expected[2] += 0, none, 1, none;
  expected[3] += 1, none, none, none;
  expected[5] += none, none, none, 0;
  expected[9] += none, none, none, 1;

  CHECK(assert_equal(expected, actual));
}

/* ************************************************************************* */
int main() {
  TestResult tr;
  return TestRegistry::runAllTests(tr);
}
/* ************************************************************************* */

