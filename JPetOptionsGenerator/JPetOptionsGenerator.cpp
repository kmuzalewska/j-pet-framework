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
 *  @file JPetOptionsGenerator.cpp
 */

#include "JPetOptionsGenerator.h"
#include <iostream>
#include "../JPetCommonTools/JPetCommonTools.h"
#include "../JPetLoggerInclude.h"
#include "../JPetScopeConfigParser/JPetScopeConfigParser.h"
#include <stdexcept>

JPetOptionsGenerator::JPetOptionsGenerator()
{

}
JPetOptionsGenerator::~JPetOptionsGenerator()
{

}

bool JPetOptionsGenerator::areCorrectOptions(const po::variables_map& variablesMap) const
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

std::vector<JPetOptions> JPetOptionsGenerator::generateOptions(const po::variables_map& optsMap, const std::map<std::string, std::string>& additionalOptions) const
{
  std::map<std::string, std::string> options = JPetOptions::getDefaultOptions();
  auto fileType = getFileType(optsMap);
  if (isCorrectFileType(fileType)) {
    options.at("inputFileType") = fileType;
  }
  if (isOutputPath(optsMap)) {
    options.at("outputPath") = JPetCommonTools::appendSlashToPathIfAbsent(getOutputPath(optsMap));
  }
  if (isRunNumberSet(optsMap)) {
    options.at("runId") = std::to_string(getRunNumber(optsMap));
  }
  if (isProgressBarSet(optsMap)) {
    options.at("progressBar") = "true";
  }
  if (isLocalDBSet(optsMap)) {
    options["localDB"] = getLocalDBName(optsMap);
  }
  if (isLocalDBCreateSet(optsMap)) {
    options["localDBCreate"] = getLocalDBCreateName(optsMap);
  }
  auto firstEvent  = getLowerEventBound(optsMap);
  auto lastEvent  = getHigherEventBound(optsMap);
  if (firstEvent >= 0) options.at("firstEvent") = std::to_string(firstEvent);
  if (lastEvent >= 0) options.at("lastEvent") = std::to_string(lastEvent);
  auto files = getFileNames(optsMap);

  /// We add additional options to already existing one.
  /// If the key already exists the element will not be updated.
  options.insert(additionalOptions.begin(), additionalOptions.end());

  std::vector<JPetOptions>  optionContainer;
  /// In case of scope there is one special input file
  /// which is a json config file which must be parsed.
  /// Based on its content the set of input directories are generated.
  /// The input directories contain data files.
  /// The config input file name also should be stored in a special option field.
  if (fileType == "scope") {
    assert(files.size() == 1); /// there should be only file which is config.
    auto configFileName = files.front();
    options.at("scopeConfigFile") =  configFileName;
    JPetScopeConfigParser scopeConfigParser;
    /// The scope module must use a fake input file name which will be used to
    /// produce the correct output file names by the following modules.
    /// At the same time, the input directory with true input files must be
    /// also added. The container of pairs <directory, fileName> is generated
    /// based on the content of the configuration file.
    JPetScopeConfigParser::DirFileContainer dirsAndFiles = scopeConfigParser.getInputDirectoriesAndFakeInputFiles(configFileName);
    for (const auto & dirAndFile : dirsAndFiles) {
      options.at("scopeInputDirectory") = dirAndFile.first;
      options.at("inputFile") = dirAndFile.second;
      optionContainer.push_back(JPetOptions(options));
    }
  } else {
    /// for every single input file we create separate JPetOptions
    for (const auto & file : files) {
      options.at("inputFile") = file;
      optionContainer.push_back(JPetOptions(options));
    }
  }
  return optionContainer;
}
