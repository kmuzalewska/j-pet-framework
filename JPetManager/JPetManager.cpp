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
 *  @file JPetManager.cpp
 */

#include "./JPetManager.h"

#include <cassert>
#include <string>

#include "../JPetLoggerInclude.h"
#include "../JPetCommonTools/JPetCommonTools.h"
#include "../JPetCmdParser/JPetCmdParser.h"

#include <TThread.h>
#include <TDSet.h>




JPetManager& JPetManager::getManager()
{
  static JPetManager instance;
  return instance;
}

bool JPetManager::run()
{
  INFO( "======== Starting processing all tasks: " + JPetCommonTools::getTimeString() + " ========\n" );
  std::vector<JPetTaskChainExecutor*> executors;
  std::vector<TThread*> threads;
  auto inputDataSeq = 0;
  /// For every input option, new TaskChainExecutor is created, which creates the chain of previously
  /// registered tasks. The inputDataSeq is the identifier of given chain.
  for (auto opt : fOptions) {
    JPetTaskChainExecutor* executor = new JPetTaskChainExecutor(fTaskGeneratorChain, inputDataSeq, opt);
    executors.push_back(executor);
    if (!executor->process()) {
      ERROR("While running process");
      return false;
    }
    //auto thr = executor->run();
    //if (thr) {
    //threads.push_back(thr);
    //} else {
    //ERROR("thread pointer is null");
    //}
    inputDataSeq++;
  }
  //for (auto thread : threads) {
  //assert(thread);
  //thread->Join();
  //}
  for (auto & executor : executors) {
    if (executor) {
      delete executor;
      executor = 0;
    }
  }

  INFO( "======== Finished processing all tasks: " + JPetCommonTools::getTimeString() + " ========\n" );
  return true;
}

void JPetManager::parseCmdLine(int argc, char** argv)
{
  JPetCmdParser parser;
  fOptions = parser.parseAndGenerateOptions(argc, (const char**)argv);
}

JPetManager::~JPetManager()
{
  /// delete shared caches for paramBanks
  /// @todo I think that should be changed
  JPetDBParamGetter::clearParamCache();
  JPetScopeParamGetter::clearParamCache();
}

void JPetManager::registerTask(const TaskGenerator& taskGen)
{
  assert(fTaskGeneratorChain);
  fTaskGeneratorChain->push_back(taskGen);
}
