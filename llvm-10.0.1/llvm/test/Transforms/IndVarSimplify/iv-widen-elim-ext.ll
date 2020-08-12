; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -S | FileCheck %s

target datalayout = "e-m:e-i64:64-p:64:64:64-n8:16:32:64-S128"

; When widening IV and its users, trunc and zext/sext are not needed
; if the original 32-bit user is known to be non-negative, whether
; the IV is considered signed or unsigned.
define void @foo(i32* %A, i32* %B, i32* %C, i32 %N) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[N]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_INC:%.*]] ], [ 0, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw nsw i64 [[INDVARS_IV]], 2
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds i32, i32* [[C:%.*]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD3:%.*]] = add nsw i32 [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i64 [[TMP1]] to i32
; CHECK-NEXT:    [[DIV0:%.*]] = udiv i32 5, [[TMP3]]
; CHECK-NEXT:    [[ADD4:%.*]] = add nsw i32 [[ADD3]], [[DIV0]]
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i32 [[ADD4]], i32* [[ARRAYIDX5]], align 4
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_FOR_END_CRIT_EDGE:%.*]]
; CHECK:       for.cond.for.end_crit_edge:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp1 = icmp slt i32 0, %N
  br i1 %cmp1, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.02 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %idxprom = sext i32 %i.02 to i64
  %arrayidx = getelementptr inbounds i32, i32* %B, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %add = add nsw i32 %i.02, 2
  %idxprom1 = zext i32 %add to i64
  %arrayidx2 = getelementptr inbounds i32, i32* %C, i64 %idxprom1
  %1 = load i32, i32* %arrayidx2, align 4
  %add3 = add nsw i32 %0, %1
  %div0 = udiv i32 5, %add
  %add4 = add nsw i32 %add3, %div0
  %idxprom4 = zext i32 %i.02 to i64
  %arrayidx5 = getelementptr inbounds i32, i32* %A, i64 %idxprom4
  store i32 %add4, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, %N
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge

for.cond.for.end_crit_edge:                       ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  ret void
}

define void @foo1(i32* %A, i32* %B, i32* %C, i32 %N) {
; CHECK-LABEL: @foo1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[N]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_INC:%.*]] ], [ 0, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw nsw i64 [[INDVARS_IV]], 2
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds i32, i32* [[C:%.*]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD3:%.*]] = add nsw i32 [[TMP0]], [[TMP2]]
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i32 [[ADD3]], i32* [[ARRAYIDX5]], align 4
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_FOR_END_CRIT_EDGE:%.*]]
; CHECK:       for.cond.for.end_crit_edge:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp1 = icmp slt i32 0, %N
  br i1 %cmp1, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.02 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %idxprom = zext i32 %i.02 to i64
  %arrayidx = getelementptr inbounds i32, i32* %B, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %add = add nsw i32 %i.02, 2
  %idxprom1 = sext i32 %add to i64
  %arrayidx2 = getelementptr inbounds i32, i32* %C, i64 %idxprom1
  %1 = load i32, i32* %arrayidx2, align 4
  %add3 = add nsw i32 %0, %1
  %idxprom4 = sext i32 %i.02 to i64
  %arrayidx5 = getelementptr inbounds i32, i32* %A, i64 %idxprom4
  store i32 %add3, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, %N
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge

for.cond.for.end_crit_edge:                       ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  ret void
}


@a = common global [100 x i32] zeroinitializer, align 16
@b = common global [100 x i32] zeroinitializer, align 16

define i32 @foo2(i32 %M) {
; CHECK-LABEL: @foo2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[M:%.*]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[TMP0:%.*]] = sext i32 [[M]] to i64
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[M]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_INC:%.*]] ], [ 0, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @b, i64 0, i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    [[TMP3:%.*]] = add nsw i64 [[INDVARS_IV]], [[TMP0]]
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 [[TMP3]]
; CHECK-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX5]], align 4
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_FOR_END_CRIT_EDGE:%.*]]
; CHECK:       for.cond.for.end_crit_edge:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @dummy(i32* getelementptr inbounds ([100 x i32], [100 x i32]* @a, i32 0, i32 0), i32* getelementptr inbounds ([100 x i32], [100 x i32]* @b, i32 0, i32 0))
; CHECK-NEXT:    ret i32 0
;
entry:
  %cmp1 = icmp slt i32 0, %M
  br i1 %cmp1, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.02 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %idxprom = zext i32 %i.02 to i64
  %arrayidx = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %idxprom1 = sext i32 %i.02 to i64
  %arrayidx2 = getelementptr inbounds [100 x i32], [100 x i32]* @b, i64 0, i64 %idxprom1
  %1 = load i32, i32* %arrayidx2, align 4
  %add = add nsw i32 %0, %1
  %add3 = add nsw i32 %i.02, %M
  %idxprom4 = sext i32 %add3 to i64
  %arrayidx5 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 %idxprom4
  store i32 %add, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, %M
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge

for.cond.for.end_crit_edge:                       ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  %call = call i32 @dummy(i32* getelementptr inbounds ([100 x i32], [100 x i32]* @a, i32 0, i32 0), i32* getelementptr inbounds ([100 x i32], [100 x i32]* @b, i32 0, i32 0))
  ret i32 0
}

declare i32 @dummy(i32*, i32*)

; A case where zext should not be eliminated when its operands could only be extended by sext.
define i32 @foo3(i32 %M) {
; CHECK-LABEL: @foo3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[M:%.*]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[TMP0:%.*]] = sext i32 [[M]] to i64
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[M]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_INC:%.*]] ], [ 0, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @b, i64 0, i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    [[TMP3:%.*]] = add nsw i64 [[INDVARS_IV]], [[TMP0]]
; CHECK-NEXT:    [[TMP4:%.*]] = trunc i64 [[TMP3]] to i32
; CHECK-NEXT:    [[IDXPROM4:%.*]] = zext i32 [[TMP4]] to i64
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 [[IDXPROM4]]
; CHECK-NEXT:    store i32 [[ADD]], i32* [[ARRAYIDX5]], align 4
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_FOR_END_CRIT_EDGE:%.*]]
; CHECK:       for.cond.for.end_crit_edge:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @dummy(i32* getelementptr inbounds ([100 x i32], [100 x i32]* @a, i32 0, i32 0), i32* getelementptr inbounds ([100 x i32], [100 x i32]* @b, i32 0, i32 0))
; CHECK-NEXT:    ret i32 0
;
entry:
  %cmp1 = icmp slt i32 0, %M
  br i1 %cmp1, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.inc
  %i.02 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.inc ]
  %idxprom = sext i32 %i.02 to i64
  %arrayidx = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %idxprom1 = sext i32 %i.02 to i64
  %arrayidx2 = getelementptr inbounds [100 x i32], [100 x i32]* @b, i64 0, i64 %idxprom1
  %1 = load i32, i32* %arrayidx2, align 4
  %add = add nsw i32 %0, %1
  %add3 = add nsw i32 %i.02, %M
  %idxprom4 = zext i32 %add3 to i64
  %arrayidx5 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0, i64 %idxprom4
  store i32 %add, i32* %arrayidx5, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.02, 1
  %cmp = icmp slt i32 %inc, %M
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge

for.cond.for.end_crit_edge:                       ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  %call = call i32 @dummy(i32* getelementptr inbounds ([100 x i32], [100 x i32]* @a, i32 0, i32 0), i32* getelementptr inbounds ([100 x i32], [100 x i32]* @b, i32 0, i32 0))
  ret i32 0
}

%struct.image = type {i32, i32}
define i32 @foo4(%struct.image* %input, i32 %length, i32* %in) {
; CHECK-LABEL: @foo4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[STRIDE:%.*]] = getelementptr inbounds [[STRUCT_IMAGE:%.*]], %struct.image* [[INPUT:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[STRIDE]], align 4
; CHECK-NEXT:    [[CMP17:%.*]] = icmp sgt i32 [[LENGTH:%.*]], 1
; CHECK-NEXT:    br i1 [[CMP17]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_COND_CLEANUP:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[CHANNEL:%.*]] = getelementptr inbounds [[STRUCT_IMAGE]], %struct.image* [[INPUT]], i64 0, i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = sext i32 [[TMP0]] to i64
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[LENGTH]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup.loopexit:
; CHECK-NEXT:    [[TMP2:%.*]] = phi i32 [ [[TMP10:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[TMP3:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[TMP2]], [[FOR_COND_CLEANUP_LOOPEXIT:%.*]] ]
; CHECK-NEXT:    ret i32 [[TMP3]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ], [ 1, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, i32* [[CHANNEL]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = sext i32 [[TMP4]] to i64
; CHECK-NEXT:    [[TMP6:%.*]] = mul nsw i64 [[TMP5]], [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i32, i32* [[IN:%.*]], i64 [[TMP6]]
; CHECK-NEXT:    [[TMP7:%.*]] = load i32, i32* [[ADD_PTR]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = mul nsw i64 [[TMP1]], [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    [[ADD_PTR1:%.*]] = getelementptr inbounds i32, i32* [[IN]], i64 [[TMP8]]
; CHECK-NEXT:    [[TMP9:%.*]] = load i32, i32* [[ADD_PTR1]], align 4
; CHECK-NEXT:    [[TMP10]] = add i32 [[TMP7]], [[TMP9]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_CLEANUP_LOOPEXIT]]
;
entry:
  %stride = getelementptr inbounds %struct.image, %struct.image* %input, i64 0, i32 1
  %0 = load i32, i32* %stride, align 4
  %cmp17 = icmp sgt i32 %length, 1
  br i1 %cmp17, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %entry
  %channel = getelementptr inbounds %struct.image, %struct.image* %input, i64 0, i32 0
  br label %for.body

for.cond.cleanup.loopexit:                        ; preds = %for.body
  %1 = phi i32 [ %6, %for.body ]
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %entry
  %2 = phi i32 [ 0, %entry ], [ %1, %for.cond.cleanup.loopexit ]
  ret i32 %2

; mul instruction below is widened instead of generating a truncate instruction for it
; regardless if Load operand of mul is inside or outside the loop (we have both cases).
for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %x.018 = phi i32 [ 1, %for.body.lr.ph ], [ %add, %for.body ]
  %add = add nuw nsw i32 %x.018, 1
  %3 = load i32, i32* %channel, align 8
  %mul = mul nsw i32 %3, %add
  %idx.ext = sext i32 %mul to i64
  %add.ptr = getelementptr inbounds i32, i32* %in, i64 %idx.ext
  %4 = load i32, i32* %add.ptr, align 4
  %mul1 = mul nsw i32 %0, %add
  %idx.ext1 = sext i32 %mul1 to i64
  %add.ptr1 = getelementptr inbounds i32, i32* %in, i64 %idx.ext1
  %5 = load i32, i32* %add.ptr1, align 4
  %6 = add i32 %4, %5
  %cmp = icmp slt i32 %add, %length
  br i1 %cmp, label %for.body, label %for.cond.cleanup.loopexit
}


define i32 @foo5(%struct.image* %input, i32 %length, i32* %in) {
; CHECK-LABEL: @foo5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[STRIDE:%.*]] = getelementptr inbounds [[STRUCT_IMAGE:%.*]], %struct.image* [[INPUT:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[STRIDE]], align 4
; CHECK-NEXT:    [[CMP17:%.*]] = icmp sgt i32 [[LENGTH:%.*]], 1
; CHECK-NEXT:    br i1 [[CMP17]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_COND_CLEANUP:%.*]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[CHANNEL:%.*]] = getelementptr inbounds [[STRUCT_IMAGE]], %struct.image* [[INPUT]], i64 0, i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = sext i32 [[TMP0]] to i64
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[LENGTH]] to i64
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup.loopexit:
; CHECK-NEXT:    [[TMP2:%.*]] = phi i32 [ [[TMP10:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[TMP3:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[TMP2]], [[FOR_COND_CLEANUP_LOOPEXIT:%.*]] ]
; CHECK-NEXT:    ret i32 [[TMP3]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ], [ 1, [[FOR_BODY_LR_PH]] ]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, i32* [[CHANNEL]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[MUL:%.*]] = mul nsw i32 [[TMP4]], [[TMP5]]
; CHECK-NEXT:    [[IDX_EXT:%.*]] = sext i32 [[MUL]] to i64
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i32, i32* [[IN:%.*]], i64 [[IDX_EXT]]
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, i32* [[ADD_PTR]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = mul nsw i64 [[TMP1]], [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    [[ADD_PTR1:%.*]] = getelementptr inbounds i32, i32* [[IN]], i64 [[TMP7]]
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, i32* [[ADD_PTR1]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = add i32 [[TMP6]], [[TMP8]]
; CHECK-NEXT:    [[TMP10]] = add i32 [[TMP9]], [[MUL]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_BODY]], label [[FOR_COND_CLEANUP_LOOPEXIT]]
;
entry:
  %stride = getelementptr inbounds %struct.image, %struct.image* %input, i64 0, i32 1
  %0 = load i32, i32* %stride, align 4
  %cmp17 = icmp sgt i32 %length, 1
  br i1 %cmp17, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %entry
  %channel = getelementptr inbounds %struct.image, %struct.image* %input, i64 0, i32 0
  br label %for.body

for.cond.cleanup.loopexit:                        ; preds = %for.body
  %1 = phi i32 [ %7, %for.body ]
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %entry
  %2 = phi i32 [ 0, %entry ], [ %1, %for.cond.cleanup.loopexit ]
  ret i32 %2

; This example is the same as above except that the first mul is used in two places
; and this may result in having two versions of the multiply: an i32 and i64 version.
; In this case, keep the trucate instructions to avoid this redundancy.
for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %x.018 = phi i32 [ 1, %for.body.lr.ph ], [ %add, %for.body ]
  %add = add nuw nsw i32 %x.018, 1
  %3 = load i32, i32* %channel, align 8
  %mul = mul nsw i32 %3, %add
  %idx.ext = sext i32 %mul to i64
  %add.ptr = getelementptr inbounds i32, i32* %in, i64 %idx.ext
  %4 = load i32, i32* %add.ptr, align 4
  %mul1 = mul nsw i32 %0, %add
  %idx.ext1 = sext i32 %mul1 to i64
  %add.ptr1 = getelementptr inbounds i32, i32* %in, i64 %idx.ext1
  %5 = load i32, i32* %add.ptr1, align 4
  %6 = add i32 %4, %5
  %7 = add i32 %6, %mul
  %cmp = icmp slt i32 %add, %length
  br i1 %cmp, label %for.body, label %for.cond.cleanup.loopexit
}
