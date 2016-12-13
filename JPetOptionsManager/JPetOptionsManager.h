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
 *  @file JPetOptionsManager.h
 */

#ifndef JPETOPTIONSMANAGER_H
#define JPETOPTIONSMANAGER_H

#include <string>
#include "../JPetOptions/JPetOptions.h"

class JPetOptionsManager: public JPetOptions{

public:
  JPetOptionsManager();
  explicit JPetOptionsManager(const Options& opts);
  inline const char* getScopeConfigFile() const {
    return fOptions.at("scopeConfigFile").c_str();
  }
  inline const char* getScopeInputDirectory() const {
    return fOptions.at("scopeInputDirectory").c_str();
  }
  inline const char* getOutputFile() const {
    return fOptions.at("outputFile").c_str();
  }
  inline const char* getOutputPath() const {
    return fOptions.at("outputPath").c_str();
  }
  inline const char* getInputFile() const {
    return fOptions.at("inputFile").c_str();
  }  
  inline long long getFirstEvent() const {
    return std::stoll(fOptions.at("firstEvent"));
  }
  inline long long getLastEvent() const {
    return std::stoll(fOptions.at("lastEvent"));
  }
  long long getTotalEvents() const;
  
  inline int getRunNumber() const {
    return std::stoi(fOptions.at("runId"));
  }
  inline std::string getLocalDB() const {
    std::string result("");
    if (isLocalDB()) {
      result = fOptions.at("localDB");
    }
    return result;
  }
  inline std::string getLocalDBCreate() const {
    std::string result("");
    if (isLocalDBCreate()) {
      result = fOptions.at("localDBCreate");
    }
    return result;
  } 
  inline bool isProgressBar() const {
    return JPetCommonTools::to_bool(fOptions.at("progressBar"));
  }
  FileType getInputFileType() const;
  FileType getOutputFileType() const;

  inline Options getOptions() const {
    return fOptions;
  }
  static  Options getDefaultOptions() {
    return kDefaultOptions;
  }
  inline bool isLocalDB() const {
    return fOptions.count("localDB") > 0;
  }
  
  inline bool isLocalDBCreate() const {
    return fOptions.count("localDBCreate") > 0;
  }  
};
#endif
