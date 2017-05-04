/**
 *  @copyright Copyright 2017 The J-PET Framework Authors. All rights reserved.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may find a copy of the License in the LICENCE file.
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  @file JPetOptionValidator.h
 */

#ifndef JPETOPTIONVALIDATOR_H
#define JPETOPTIONVALIDATOR_H

#include <map>
#include <string>
#include <boost/any.hpp>

/**
 * @brief Class to validate the user defined options.
 *
 */
class JPetOptionValidator
{
public:
  static bool areCorrectOptions(const std::map<std::string, boost::any>& optionsMap);
  static std::map<std::string, std::vector<bool(*)(std::pair <std::string, boost::any>)> > generateValidationMap();
  /// validation functions
  static bool isNumberBoundsInRangeValid(std::pair <std::string, boost::any> option);
  static bool isRangeOfEventsValid(std::pair <std::string, boost::any> option);
  static bool isCorrectFileType(std::pair <std::string, boost::any> option);
  static bool isRunIdValid(std::pair <std::string, boost::any> option);
  static bool isLocalDBValid(std::pair <std::string, boost::any> option);
  static bool areFilesValid(std::pair <std::string, boost::any> option);
  static bool isOutputDirectoryValid(std::pair <std::string, boost::any> option);
};
#endif /*  !JPETOPTIONVALIDATOR_H */
