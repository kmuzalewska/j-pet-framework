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
 *  @file JPetTaskLoader.h
 *  @brief Class loads user task and execute in a loop of events
 */

#ifndef _JPETTASKLOADER_H_
#define _JPETTASKLOADER_H_

#include "../JPetTaskIO/JPetTaskIO.h"

class JPetTaskLoader: public JPetTaskIO
{
public:
  JPetTaskLoader() {}
  JPetTaskLoader(const char* in_file_type,
                 const char* out_file_type,
                 JPetTask* taskToExecute);

  virtual void init(const JPetOptions::Options& opts); /// Overloading JPetTaskIO init
  virtual ~JPetTaskLoader();
protected:
  std::string generateProperNameFile(const std::string& srcFilename, const std::string& fileType) const;
  std::string getBaseFileName(const std::string& srcName) const;

  std::string fInFileType;
  std::string fOutFileType;
  //ClassDef(JPetTaskLoader, MODULE_VERSION );

};

#endif
