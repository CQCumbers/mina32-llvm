; RUN: llvm-as < %s | opt -scalar-evolution -analyze -disable-output \
; RUN:  | grep {Loop bb3\\.i: Unpredictable backedge-taken count\\.}

; ScalarEvolution can't compute a trip count because it doesn't know if
; dividing by the stride will have a remainder. This could theoretically
; be teaching it how to use a more elaborate trip count computation.

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128"
target triple = "x86_64-unknown-linux-gnu"
	%struct.FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct.FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
	%struct.SHA_INFO = type { [5 x i32], i32, i32, [16 x i32] }
	%struct._IO_marker = type { %struct._IO_marker*, %struct.FILE*, i32 }
@_2E_str = external constant [26 x i8]		; <[26 x i8]*> [#uses=0]
@stdin = external global %struct.FILE*		; <%struct.FILE**> [#uses=0]
@_2E_str1 = external constant [3 x i8]		; <[3 x i8]*> [#uses=0]
@_2E_str12 = external constant [30 x i8]		; <[30 x i8]*> [#uses=0]

declare void @sha_init(%struct.SHA_INFO* nocapture) nounwind

declare fastcc void @sha_transform(%struct.SHA_INFO* nocapture) nounwind

declare void @sha_print(%struct.SHA_INFO* nocapture) nounwind

declare i32 @printf(i8* nocapture, ...) nounwind

declare void @sha_final(%struct.SHA_INFO* nocapture) nounwind

declare void @llvm.memset.i64(i8* nocapture, i8, i64, i32) nounwind

declare void @sha_update(%struct.SHA_INFO* nocapture, i8* nocapture, i32) nounwind

declare void @llvm.memcpy.i64(i8* nocapture, i8* nocapture, i64, i32) nounwind

declare i64 @fread(i8* noalias nocapture, i64, i64, %struct.FILE* noalias nocapture) nounwind

declare i32 @main(i32, i8** nocapture) nounwind

declare noalias %struct.FILE* @fopen(i8* noalias nocapture, i8* noalias nocapture) nounwind

declare i32 @fclose(%struct.FILE* nocapture) nounwind

declare void @sha_stream(%struct.SHA_INFO* nocapture, %struct.FILE* nocapture) nounwind

define void @sha_stream_bb3_2E_i(%struct.SHA_INFO* %sha_info, i8* %data1, i32, i8** %buffer_addr.0.i.out, i32* %count_addr.0.i.out) nounwind {
newFuncRoot:
	br label %bb3.i

sha_update.exit.exitStub:		; preds = %bb3.i
	store i8* %buffer_addr.0.i, i8** %buffer_addr.0.i.out
	store i32 %count_addr.0.i, i32* %count_addr.0.i.out
	ret void

bb2.i:		; preds = %bb3.i
	%1 = getelementptr %struct.SHA_INFO* %sha_info, i64 0, i32 3		; <[16 x i32]*> [#uses=1]
	%2 = bitcast [16 x i32]* %1 to i8*		; <i8*> [#uses=1]
	call void @llvm.memcpy.i64(i8* %2, i8* %buffer_addr.0.i, i64 64, i32 1) nounwind
	%3 = getelementptr %struct.SHA_INFO* %sha_info, i64 0, i32 3, i64 0		; <i32*> [#uses=1]
	%4 = bitcast i32* %3 to i8*		; <i8*> [#uses=1]
	br label %codeRepl

codeRepl:		; preds = %bb2.i
	call void @sha_stream_bb3_2E_i_bb1_2E_i_2E_i(i8* %4)
	br label %byte_reverse.exit.i

byte_reverse.exit.i:		; preds = %codeRepl
	call fastcc void @sha_transform(%struct.SHA_INFO* %sha_info) nounwind
	%5 = getelementptr i8* %buffer_addr.0.i, i64 64		; <i8*> [#uses=1]
	%6 = add i32 %count_addr.0.i, -64		; <i32> [#uses=1]
	br label %bb3.i

bb3.i:		; preds = %byte_reverse.exit.i, %newFuncRoot
	%buffer_addr.0.i = phi i8* [ %data1, %newFuncRoot ], [ %5, %byte_reverse.exit.i ]		; <i8*> [#uses=3]
	%count_addr.0.i = phi i32 [ %0, %newFuncRoot ], [ %6, %byte_reverse.exit.i ]		; <i32> [#uses=3]
	%7 = icmp sgt i32 %count_addr.0.i, 63		; <i1> [#uses=1]
	br i1 %7, label %bb2.i, label %sha_update.exit.exitStub
}

declare void @sha_stream_bb3_2E_i_bb1_2E_i_2E_i(i8*) nounwind
