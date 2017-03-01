/**
 *  @copyright Copyright 2016 The J-PET Framework Authors. All rights reserved.
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
 *  @file JPetOptionsValidator.cpp
 */

#include "./JPetOptionsValidator.h"

JPetOptionsValidator::JPetOptionsValidator(){}

JPetOptionsValidator::JPetOptionsValidator(const Options& opts){}

bool JPetOptionsValidator::areCorrectOptions(const po::variables_map& variablesMap) const
{
  /* Parse range of events */
  if (variablesMap.count("range")) {
    if (variablesMap["range"].as< std::vector<int> >().size() != 2) {
      ERROR("Wrong number of bounds in range.");
      std::cerr << "Wrong number of bounds in range: " << variablesMap["range"].as< std::vector<int> >().size() << std::endl;
      return false;
    }
    if (
      variablesMap["range"].as< std::vector<int> >()[0]
      > variablesMap["range"].as< std::vector<int> >()[1]) {
      ERROR("Wrong range of events.");
      std::cerr << "Wrong range of events." << std::endl;
      return false;
    }
  }

  if (!isCorrectFileType(getFileType(variablesMap))) {
    ERROR("Wrong type of file.");
    std::cerr << "Wrong type of file: " << getFileType(variablesMap) << std::endl;
    std::cerr << "Possible options: hld, zip, root or scope" << std::endl;
    return false;
  }

  if (isRunNumberSet(variablesMap)) {
    int l_runId = variablesMap["runId"].as<int>();

    if (l_runId <= 0) {
      ERROR("Run id must be a number larger than 0.");
      std::cerr << "Run id must be a number larger than 0." << l_runId << std::endl;
      return false;
    }
  }

  if (isLocalDBSet(variablesMap)) {
    std::string localDBName = getLocalDBName(variablesMap);
    if ( !JPetCommonTools::ifFileExisting(localDBName) ) {
      ERROR("File : " + localDBName + " does not exist.");
      std::cerr << "File : " << localDBName << " does not exist" << std::endl;
      return false;
    }
  }

  std::vector<std::string> fileNames(variablesMap["file"].as< std::vector<std::string> >());
  for (unsigned int i = 0; i < fileNames.size(); i++) {
    if ( ! JPetCommonTools::ifFileExisting(fileNames[i]) ) {
      std::string fileName = fileNames[i];
      ERROR("File : " + fileName + " does not exist.");
      std::cerr << "File : " << fileNames[i] << " does not exist" << std::endl;
      return false;
    }
  }


  /// The run number option is neclegted if the input file is set as "scope"
  if (isRunNumberSet(variablesMap)) {
    if (getFileType(variablesMap) == "scope") {
      WARNING("Run number was specified but the input file type is a scope!\n The run number will be ignored!");
    }
  }

  /// Check if output path exists
  if (isOutputPath(variablesMap)) {
    auto dir = getOutputPath(variablesMap);
    if (!JPetCommonTools::isDirectory(dir)) {
      ERROR("Output directory : " + dir + " does not exist.");
      std::cerr << "Output directory: " << dir << " does not exist" << std::endl;
      return false;
    }
  }
  return true;
}
