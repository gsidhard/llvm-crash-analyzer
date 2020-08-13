//===- crash-blamer.cpp ---------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the entry point for the crash blamer tool.
//
//===----------------------------------------------------------------------===//

#include "Decompiler/Decompiler.h"
#include "CoreFile/CoreFile.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/WithColor.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using namespace crash_blamer;

/// @}
/// Command line options.
/// @{
namespace {
using namespace cl;
OptionCategory CrashBlamer("Specific Options");
static opt<bool> Help("h", desc("Alias for -help"), Hidden,
                      cat(CrashBlamer));
static opt<std::string>
    InputFilename(Positional, desc("<input file>"), cat(CrashBlamer));
static opt<std::string>
    OutputFilename("out-file", cl::init("-"),
                   cl::desc("Redirect output to the specified file"),
                   cl::value_desc("filename"),
                   cat(CrashBlamer));
static alias OutputFilenameAlias("o", desc("Alias for -out-file"),
                                 aliasopt(OutputFilename),
                                 cat(CrashBlamer));
static opt<std::string> CoreFileName("core-file", cl::init(""),
                                     cl::desc("<core-file>"),
                                     cl::value_desc("corefilename"),
                                     cat(CrashBlamer));
} // namespace
/// @}
//===----------------------------------------------------------------------===//

static void error(StringRef Prefix, std::error_code EC) {
  if (!EC)
    return;
  WithColor::error() << Prefix << ": " << EC.message() << "\n";
  exit(1);
}

int main(int argc, char **argv) {
  llvm::outs() << "Crash Blamer -- crash analyzer utility\n";

  InitLLVM X(argc, argv);
  InitializeAllTargetInfos();
  InitializeAllTargetMCs();
  InitializeAllTargets();
  InitializeAllDisassemblers();

  HideUnrelatedOptions({&CrashBlamer});
  cl::ParseCommandLineOptions(argc, argv, "crash blamer\n");
  if (Help) {
    PrintHelpMessage(false, true);
    return 0;
  }

  if (InputFilename == "") {
    WithColor::error(errs()) << "no input file\n";
    exit(1);
  }

  if (CoreFileName == "") {
    WithColor::error(errs()) << "no core-file specified\n";
    exit(1);
  }

  std::error_code EC;
  ToolOutputFile OutputFile(OutputFilename, EC, sys::fs::OF_None);
  error("Unable to open output file" + OutputFilename, EC);
  // Don't remove output file if we exit with an error.
  OutputFile.keep();
  int exit_code = 0;

  // Read the symbols from core file (e.g. function names from crash backtrace).
  // TODO: Read registers and memory state from core-file.
  CoreFile coreFile(CoreFileName);
  coreFile.read(InputFilename);
  // Get the functions from backtrace.
  StringSet<> functionsFromCoreFile = coreFile.getFunctionsFromBacktrace();

  // Implement decompiler.
  Triple Triple(Triple::normalize(sys::getDefaultTargetTriple()));

  auto Decompiler = crash_blamer::Decompiler::create(Triple);
  if (!Decompiler)
    return 1;
  crash_blamer::Decompiler *Dec = Decompiler.get().get();

  auto Err = Dec->run(InputFilename, functionsFromCoreFile);
  if (Err)
    return 1;

  // TODO: Implement LLVM MIR analysis.

  return exit_code;
}
