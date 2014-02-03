/**
 *  @copyright Copyright (c) 2013, Wojciech Krzemien
 *  @file JPetHLDReader.h
 *  @author Wojciech Krzemien, wojciech.krzemien@if.uj.edu.pl
 *  @brief The interface only mimics the JPetReader class
 */
#ifndef _J_PET_HLD_READER_H_
#define _J_PET_HLD_READER_H_

#include <TBranch.h>
#include <TFile.h>
#include <TNamed.h>
#include <TTree.h>

#include "../Event/Event.h"
#include "../../JPetLoggerInclude.h"


class JPetHLDReader
{
 public:
  JPetHLDReader();
  explicit JPetHLDReader(const char* filename);
  virtual ~JPetHLDReader();

  void CloseFile();
  long long GetEntries () const { return fTree->GetEntries(); }
  int GetEntry (int entryNo) { return fTree->GetEntry(entryNo); }
  bool OpenFile(const char* filename);
  void ReadData();
  Event& GetData() { return *fObject; }
 protected:
  TBranch* fBranch;
  TFile* fFile;
  TTree* fTree;
  Event* fObject;
 private:
  JPetHLDReader(const JPetHLDReader&);
  void operator=(const JPetHLDReader);
};
#endif