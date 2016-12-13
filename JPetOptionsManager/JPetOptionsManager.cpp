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
 *  @file JPetOptionsManager.cpp
 */

#include "./JPetOptionsManager.h"
#include "./JPetOptions.h"
#include "../JPetLoggerInclude.h"

JPetOptionsManager::JPetOptionsManager():JPetOptions(){	
}
JPetOptionsManager::JPetOptionsManager(const Options& opts):JPetOptions(opts){  
}
JPetOptionsManager::FileType JPetOptionsManager::getInputFileType() const
{
  return handleFileType("inputFileType");
}

JPetOptionsManager::FileType JPetOptionsManager::getOutputFileType() const
{
  return handleFileType("outputFileType");
}

/// It returns the total number of events calculated from
/// first and last event given in the range of events to calculate.
/// If first or last event is set to -1 then the -1 is returned.
/// If last - first < 0 then -1 is returned.
/// Otherwise last - first +1 is returned.
long long JPetOptionsManager::getTotalEvents() const
{
  long long first = getFirstEvent();
  long long last = getLastEvent();
  long long diff = -1;
  if ((first >= 0) && (last >= 0) && ((last - first) >= 0)) {
    diff = last - first + 1;
  }
  return diff;
}