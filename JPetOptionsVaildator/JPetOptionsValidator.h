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
 *  @file JPetOptionsValidator.h
 */

#ifndef JPETOPTIONSVALIDATOR_H
#define JPETOPTIONSVALIDATOR_H

#include <string>
#include "../JPetOptionsValidator/JPetOptionsValidator.h"
#include "../JPetOptions/JPetOptions.h"

class JPetOptionsValidator{

public:
  JPetOptionsValidator();
  explicit JPetOptionsValidator(const JPetOptionsManager& opts);
  bool areCorrectOptions(const po::variables_map& variablesMap) const;	
};
#endif
