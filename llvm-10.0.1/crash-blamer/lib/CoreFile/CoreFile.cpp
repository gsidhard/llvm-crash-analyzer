//===- CoreFile.cpp -------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements crash blamer core file loading.
//
//===----------------------------------------------------------------------===//

#include "CoreFile/CoreFile.h"

#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/WithColor.h"
#include "llvm/Support/raw_ostream.h"

#include "lldb/API/SBDebugger.h"
#include "lldb/API/SBFileSpec.h"
#include "lldb/API/SBFrame.h"
#include "lldb/API/SBProcess.h"
#include "lldb/API/SBTarget.h"
#include "lldb/API/SBThread.h"
#include "lldb/Utility/ConstString.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/lldb-forward.h"

using namespace llvm;
using namespace lldb;
using namespace lldb_private;

#define DEBUG_TYPE "crash-blamer-corefile"

static constexpr const char *GPR = "General Purpose Registers";

void llvm::crash_blamer::CoreFile::read(StringRef InputFile) {
  outs() << "\nLoading core-file " << name << "\n";

  SBDebugger::Initialize();
  SBDebugger debugger(SBDebugger::Create());

  SBTarget target = debugger.CreateTarget(InputFile.data());
  if (!target.IsValid()) {
    WithColor::error() << "invalid target inside debugger\n";
    return;
  }

  SBProcess process = target.LoadCore(name);
  if (!process.IsValid()) {
    WithColor::error() << "invalid core-file\n";
    return;
  }

  SBThread thread = process.GetSelectedThread();
  if (!thread.IsValid()) {
    WithColor::error() << "invalid thread selected within core-file\n";
    return;
  }

  int NumOfFrames = thread.GetNumFrames();
  LLVM_DEBUG(dbgs() << "Num of frames " << NumOfFrames << "\n");

  for (int i = 0; i < NumOfFrames; ++i) {
    SBFrame frame = thread.GetFrameAtIndex(i);
    if (!frame.IsValid()) {
      WithColor::error() << "invalid frame found within core-file\n";
      return;
    }
    LLVM_DEBUG(dbgs() << frame.GetFunctionName() << "\n");
    FunctionsFromBacktrace.insert(frame.GetFunctionName());
  }

  // Get registers state at the point of the crash.
  auto crashFrame = thread.GetFrameAtIndex(NumOfFrames - 1);
  auto Regs = crashFrame.GetRegisters();
  auto GPRegss = Regs.GetFirstValueByName(GPR);
  int NumOfGPRegs = GPRegss.GetNumChildren();
  for (int j = 0; j < NumOfGPRegs; ++j) {
    auto Reg = GPRegss.GetChildAtIndex(j);
    if (Reg.GetValue())
      insertIntoGPRFromCrashFrame(Reg.GetName(), Reg.GetValue());
    else
      insertIntoGPRFromCrashFrame(Reg.GetName(), nullptr);
  }

  LLVM_DEBUG(auto GPRegs = getGRPsFromCrashFrame();
             dbgs() << "Function from top of the stack: "
                    << crashFrame.GetFunctionName() << "\n";
             dbgs() << "Regs:\n";
             for (auto &R : GPRegs)
               dbgs() << " reg: " << R.first << " val: "
                      << R.second << "\n";);

  SBDebugger::Destroy(debugger);
  SBDebugger::Terminate();

  outs() << "core-file processed.\n\n";
}
