#include "JPetTaskLoader.h"
#include <iostream>
#include "../../framework/JPetTask/JPetTask.h"
//ClassImp(JPetTaskLoader);

JPetTaskLoader::JPetTaskLoader(const char* in_file_type,
                               const char* out_file_type,
                               JPetTask* taskToExecute):
  fInFileType(in_file_type),
  fOutFileType(out_file_type),
  JPetTaskIO()
{
  addSubTask(taskToExecute);
}



void JPetTaskLoader::init(const JPetOptions::Options& opts)
{
  auto newOpts(opts);
  auto inFile = newOpts.at("inputFile");
  auto outFile = inFile;
  inFile = generateProperNameFile(inFile, fInFileType);
  outFile = generateProperNameFile(outFile, fOutFileType);
  newOpts.at("inputFile") = inFile;
  newOpts.at("inputFileType") = fInFileType;
  newOpts.at("outputFile") = outFile;
  newOpts.at("outputFileType") = fOutFileType;
  setOptions(JPetOptions(newOpts));
  //here we should call some function to parse options
  auto inputFilename = fOptions.getInputFile();
  auto outputFilename = fOptions.getOutputFile();
  createInputObjects(inputFilename);
  createOutputObjects(outputFilename);
}

std::string JPetTaskLoader::generateProperNameFile(const std::string& srcFilename, const std::string& fileType) const
{
  auto baseFileName = getBaseFileName(srcFilename);
  return baseFileName + "." + fileType + ".root";
}

std::string JPetTaskLoader::getBaseFileName(const std::string& srcName) const
{
  auto name(srcName);
  auto pos = name.find(".");
  if ( pos != std::string::npos ) {
    name.erase( pos );
  }
  return name;
}

JPetTaskLoader::~JPetTaskLoader()
{
}

