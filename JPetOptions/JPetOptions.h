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
 *  @file JPetOptions.h
 */

#ifndef JPETOPTIONS_H
#define JPETOPTIONS_H

#include <string>
#include <map>
#include "../JPetCommonTools/JPetCommonTools.h"
#include "../JPetOptionsInterface/JPetOptionsInterface.h"

class JPetOptions: public JPetOptionsInterface
{

public:
  enum FileType {
    kNoType, kScope, kRaw, kRoot, kHld, kZip, kPhysEve, kPhysHit, kPhysSig, kRawSig, kRecoSig, kTslotCal, kTslotRaw, kUndefinedFileType
  };
  typedef std::map<std::string, std::string> Options;
  typedef std::vector<std::string> InputFileNames;

  JPetOptions();
  explicit JPetOptions(const Options& opts);
  void resetEventRange();
  static Options resetEventRange(const Options& srcOpts);

protected:
  static Options kDefaultOptions;

  void handleErrorMessage(const std::string& errorMessage, const std::out_of_range& outOfRangeException) const;
  FileType handleFileType(const std::string& fileType) const;
  void setOptions(const Options& opts) {
    fOptions = opts;
  }
  void setStringToFileTypeConversion();
  Options fOptions;
  std::map<std::string, JPetOptions::FileType> fStringToFileType;

};
#endif /*  !JPETOPTIONS_H */
