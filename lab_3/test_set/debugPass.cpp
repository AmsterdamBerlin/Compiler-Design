/* First-Name Last-Name Matr-No */

/* TODO: Add a short explanation of your algorithm here.
 * E.g., if you use iterative data-flow analysis, write down
 * the used gen/kill sets and flow-equations here. */

// Include some headers that might be useful
#include <llvm/Pass.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/InstIterator.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/ValueMap.h>
#include <llvm/ADT/BitVector.h>
#include <llvm/ADT/DenseSet.h>
#include <llvm/Support/raw_ostream.h>

#include <string.h>
#include <iostream>
#include <map>
#include <utility>

using namespace std;
using namespace llvm;

namespace {

class DefinitionPass : public FunctionPass {
public:
  static char ID;
  DefinitionPass() : FunctionPass(ID) {}

  virtual void getAnalysisUsage(AnalysisUsage &au) const {
    au.setPreservesAll();
  }

  virtual bool runOnFunction(Function &F) {
    // Example: Print all stores and where they occur
    map<string, map<string, bool>> BBgenSet;
    map<string, map<string, bool>> BBkillSet;
    map<string, map<string, bool>> BBinSet;
    map<string, map<string, bool>> BBoutSet;
    map<string, bool> BBchanged;
    int i=0;
    bool changed = true;

    for (BasicBlock &BB : F) {
      BB.setName(to_string(i));
  // map set and kill set for function
      map<string, bool> genSet;
      map<string, bool> killSet;

      /**************  1: create gen and kill set for each BB *******************/
      for (Instruction &I : BB) {
        if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
          Value *PtrOp = SI->getPointerOperand(); // Store target
          if (PtrOp->hasName()) {
            /************* 1.1 creat kill for store Instruction  *******/
            killSet[PtrOp->getName()] = true;
          }
        }
        if (AllocaInst *AI = dyn_cast<AllocaInst>(&I)){
          if( AI->hasName()){
          /**************** 1.2 create gen for allocate Instruction *************/
            genSet[AI->getName()] = true;

          }
        }
      }
        /***************** 1.3 map gen and kill set for each block ***************/
      BBgenSet[to_string(i)] = genSet;
      BBkillSet[to_string(i)] = killSet;
      i++;
    }
      /*************  2 create in and out set for each block
                        by iterating gen and kill set *****************/
    while (changed){
      errs() << "change mark" << "\n";
      for (BasicBlock &BB : F){
        string BBid = BB.getName();
        // copy in and out set for current block and check the change later
        map<string, bool> inSetCopy;
        map<string, bool> outSetCopy;
        map<string, bool> genSetCopy(BBgenSet[BBid]);
        map<string, bool> killSetCopy(BBkillSet[BBid]);
      //  inSetCopy = BBgenSet[BBid]; // different from lecture

      // generate the in set from its get set and its predecessor`s out set

        /******* 2.1 insert predecessor`s out sets into current block`s in set
                  IN[B] = U(OUT[P]) / P predecessor Of B ************/
       for (auto it = pred_begin(&BB), et = pred_end(&BB); it != et; it++){
          string PBid = (*it)->getName();
          //inSetCopy = BBoutSet[PBid];
          inSetCopy.insert(BBoutSet[PBid].begin(),BBoutSet[PBid].end());
          errs() << "Block`s " << BBid << " predecessor is : " << PBid << "\n";
          for(auto const& bit : BBoutSet[PBid])
          errs() << "     predecessor " << PBid << " OutSet items are : " <<  bit.first << "  =>  " << bit.second << "\n";
          for(auto const& bit : inSetCopy)
          errs() << "     InSet items are : " <<  bit.first << "  =>  " << bit.second << "\n";
        }
        /********* 2.2 delete the kill set from In set and insert gen set
                 OUT[B] = gen[B] U (IN[B] - kill[B]) *******************/

        genSetCopy.insert(inSetCopy.begin(),inSetCopy.end());
        for (auto const& item : genSetCopy){
          if(killSetCopy[item.first] == false){
             outSetCopy[item.first] = item.second;
          }
        }

        BBchanged[BBid] = false;

      if(outSetCopy.size()!=BBoutSet[BBid].size()){
          BBchanged[BBid] = true;
          errs() << "Size Change!" << "\n";
        }
        else {
          for(auto const& item : inSetCopy){
            if(item.second != BBinSet[BBid][item.first]){
              BBchanged[BBid] = true;
                errs() << "InSet Chagne!" << "\n";
              break;
            }
          }

          for(auto const& item: outSetCopy){
            if(item.second != BBoutSet[BBid][item.first]){
              BBchanged[BBid] = true;
              errs() << "OutSet Chagne!" << "\n";
              break;
            }
          }
        }

        BBinSet[BBid] = inSetCopy;
        BBoutSet[BBid] = outSetCopy;
      //  BBgenSet[Bbid]
      }

      for(auto const& bbchanged : BBchanged){
         if(bbchanged.second == true){
            changed = true;
            break;
         }
         else{
            changed = false;
         }
       }
     }



    /*****************   Analyze for invalid load  ************************/
    for (BasicBlock &BB : F) {
      string BBid = BB.getName();
      map<string, bool> SetCopy (BBinSet[BBid]);

      errs() << "=============================================="  << "\n" ;
      errs() << "BB ID : " << BBid << "\n";

      for (auto it = pred_begin(&BB), et = pred_end(&BB); it != et; it++){
         string PBid = (*it)->getName();
         errs() << "predecessor block of current one: " << PBid << "\n";
       }

      for(auto const& item : BBgenSet[BBid]){
        errs() << "GEN set : " << item.first << "=>" << item.second << "\n";
      }
      for(auto const& item : BBkillSet[BBid]){
        errs() << "KILL set : " << item.first << "=>" << item.second << "\n";
      }
      errs() << "----------------------------------------------"  << "\n";
      for(auto const& item : BBinSet[BBid]){
        errs() << "IN set : " << item.first << "=>" << item.second << "\n";
      }
      for(auto const& item : BBoutSet[BBid]){
        errs() << "OUT set : " << item.first << "=>" << item.second << "\n";
      }

      for(Instruction &I : BB){
        if(AllocaInst *AI = dyn_cast<AllocaInst>(&I)){
          if(AI->hasName()){
            SetCopy[AI->getName()] = true;
          }
        }
        if(StoreInst *SI = dyn_cast<StoreInst>(&I)){
          Value *PtrOp = SI->getPointerOperand();
          if(PtrOp->hasName()){
            SetCopy[PtrOp->getName()] = false;
          }
        }
        if(LoadInst *LI = dyn_cast<LoadInst>(&I)){
          Value *PtrOp = LI->getPointerOperand(); // Store target
          if (PtrOp->hasName()) {
            if(SetCopy[PtrOp->getName()] == true){
              DebugLoc Loc = LI->getDebugLoc();
              errs() << "Variable " << PtrOp->getName() << " may be uninitialized on line " << Loc.getLine() << "\n";
            }
          }
        }
      }
    }
     // We did not modify the function
    return false;
  }
};

class FixingPass : public FunctionPass {
public:
  static char ID;
  FixingPass() : FunctionPass(ID) {}

  virtual void getAnalysisUsage(AnalysisUsage &au) const {
    au.setPreservesCFG();
  }

  virtual bool runOnFunction(Function &F) {
    // TODO

    // The function was modified
    return true;
  }
};

} // namespace


char DefinitionPass::ID = 0;
char FixingPass::ID = 1;

// Pass registrations
static RegisterPass<DefinitionPass> X("def-pass", "Uninitialized variable pass");
static RegisterPass<FixingPass> Y("fix-pass", "Fixing initialization pass");
