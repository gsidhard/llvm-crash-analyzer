//===--- UpgradeDurationConversionsCheck.h - clang-tidy ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_ABSEIL_UPGRADEDURATIONCONVERSIONSCHECK_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_ABSEIL_UPGRADEDURATIONCONVERSIONSCHECK_H

#include "../ClangTidy.h"

#include <unordered_set>

namespace clang {
namespace tidy {
namespace abseil {

/// Finds deprecated uses of `absl::Duration` arithmetic operators and factories.
///
/// For the user-facing documentation see:
/// http://clang.llvm.org/extra/clang-tidy/checks/abseil-upgrade-duration-conversions.html
class UpgradeDurationConversionsCheck : public ClangTidyCheck {
public:
  UpgradeDurationConversionsCheck(StringRef Name, ClangTidyContext *Context)
      : ClangTidyCheck(Name, Context) {}
  void registerMatchers(ast_matchers::MatchFinder *Finder) override;
  void check(const ast_matchers::MatchFinder::MatchResult &Result) override;

private:
  std::unordered_set<unsigned> MatchedTemplateLocations;
};

} // namespace abseil
} // namespace tidy
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_ABSEIL_UPGRADEDURATIONCONVERSIONSCHECK_H
