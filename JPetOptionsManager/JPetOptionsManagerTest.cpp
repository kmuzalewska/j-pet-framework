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
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <boost/foreach.hpp>
#include <string>
#include <set>
#include <exception>
#include <iostream>
namespace pt = boost::property_tree;

JPetOptionsManager::JPetOptionsManager(){
	
} 
void JPetOptionsManager::createFileFromOptions(JPetOptions options){
	pt::ptree optionsTree;
		
}

JPetOptions JPetOptionsManager::createOptionsFromFile(std::string filename){
	JPetOptions options;
	pt::ptree optionsTree;
	pt::read_json(filename, optionsTree);
	for(ptree::const_iterator it = optionsTree.begin(); it != end; ++it){
		options.insert(it, optionsTree.get<std::string>(it,0))
	}
	
}
