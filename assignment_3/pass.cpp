/* Yuang Chen 387599, Björn Fischer 319384 */

/* TODO: Add a short explanation of your algorithm here.
 * E.g., if you use iterative data-flow analysis, write down
 * the used gen/kill sets and flow-equations here.
 *
 * We used iterative data flow analysis to solve the assignment.
 * This was implemented in 3 steps.
 * The first step generates the gen and kill sets for each basic block. Here
 * for each allocation the corresponding variable is saved in the gen set, while
 * for each store the corresponding variable is saved in the kill set.
 * In the second step the actual iterative data flow analysis is performed. The
 * in set is generated by aggregating the out sets of the previous basic blocks
 * and the gen set of the current basic block. Then the entries in the kill set
 * are removed from the in set to generate this blocks out set.
 * The analysis is done top to bottom.
 * In the third step, we did a local analysis of the basic blocks. here we use
 * the generated in sets and go though each instruction. If we find a store
 * instruction we remove the corresponding variable from the in set like before,
 * and if we find a load instruction and the corresponding variable is still in
 * the in set we know that the variable might be uninitialized at that location
 * and print an error message.
 *
 * For the second part of the assignment where we should fix a missing
 * initialisation, we just added a fitting store instruction directly after
 * every allocation. We might do some unnecessary work here, but the solution
 * works in every case and is simple.
 */

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

            // Map of gen sets for all basic blocks
            std::map<int, std::map<std::string, bool>> BBGenSets;
            // Map of kill sets for all basic blocks
            std::map<int, std::map<std::string, bool>> BBKillSets;

            // Map of in sets for all basic blocks
            std::map<int, std::map<std::string, bool>> BBInSets;
            // Map of out sets for all basic blocks
            std::map<int, std::map<std::string, bool>> BBOutSets;


            // Map wich basic blocks changed
            std::map<int, bool> BBchanged;

            // generate the gen and kill sets

            int i = 0;
            // first process all allocations
            for (BasicBlock &BB : F) {

                BB.setName(std::to_string(i));

                // create a genSet for the basic block
                std::map<std::string, bool> genSet;
                // create a killSet for the basic block
                std::map<std::string, bool> killSet;


                for (Instruction &I : BB) {
                    // if we find an allocation
                    if (AllocaInst *SI = dyn_cast<AllocaInst>(&I)) {
                        if (SI->hasName()) {
                            // add the allocated variable to the gen set until it is defined via a store
                            genSet[SI->getName()] = true;
                        }
                    }

                    // if we find a store
                    if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
                        Value *PtrOp = SI->getPointerOperand(); // Store target
                        if (PtrOp->hasName()) {
                            DebugLoc Loc = SI->getDebugLoc();

                            // Add the variable to the kill set.

                            killSet[PtrOp->getName()] = true;
                        }
                    }
                }

                // save the gen and kill sets for each basicBlock

                BBGenSets[i] = genSet;
                BBKillSets[i] = killSet;

                i++;
            }

            int blocksChanging = true;

            // repeat generating the in and out sets until they don't change
            // any more. Then we correctly propagated all variables.
            while (blocksChanging) {

                // Iterate all basic blocks and calculate the ins and outs.
                for (BasicBlock &BB : F) {



                    // local copy of the in and out set
                    std::map<std::string, bool> InSetLocal(BBInSets[std::stoi(BB.getName())]);
                    std::map<std::string, bool> OutSetLocal(BBOutSets[std::stoi(BB.getName())]);

                    // generate the in set from this blocks gen set and the previous ones out sets.

                    // add this blocks gen set to its in set.
                    /// @todo We only need to do this if the block is first visited.

                    InSetLocal = BBGenSets[std::stoi(BB.getName())];


                    // check all predecessors out sets to generate the in set for this block

                    for (pred_iterator SI = pred_begin(&BB), E = pred_end(&BB); SI != E; ++SI) {
                        BasicBlock *BBPred = *SI;

                        // insert the predecessors out sets into the in set of this block.
                        InSetLocal.insert(
                            BBOutSets[std::stoi(BBPred->getName())].begin(),
                            BBOutSets[std::stoi(BBPred->getName())].end());
                    }

                    // kill variables from the in set to generate the out set.

                    for (auto const& genVariable : InSetLocal) {
                        // if the found variable is not in the kill set, add it to the out set.

                        if (
                            BBKillSets[std::stoi(BB.getName())].find(genVariable.first) ==
                                BBKillSets[std::stoi(BB.getName())].end()
                        ) {
                            OutSetLocal[genVariable.first] = genVariable.second;
                        }
                    }


                    // check if the basic block did or didn't change.

                    BBchanged[std::stoi(BB.getName())] = false;

                    if (
                        InSetLocal.size() != BBInSets[std::stoi(BB.getName())].size() ||
                        OutSetLocal.size() != BBOutSets[std::stoi(BB.getName())].size()
                    ) {
                        BBchanged[std::stoi(BB.getName())] = true;
                    }
                    else {
                        /// @todo the code here is too duplicated, should be a function.

                        for (auto const& Variable : InSetLocal) {
                            if (Variable.second != BBInSets[std::stoi(BB.getName())][Variable.first]) {
                                BBchanged[std::stoi(BB.getName())] = true;
                                break;
                            }
                        }

                        for (auto const& Variable : OutSetLocal) {
                            if (Variable.second != BBOutSets[std::stoi(BB.getName())][Variable.first]) {
                                BBchanged[std::stoi(BB.getName())] = true;
                                break;
                            }
                        }
                    }

                    // write the changed sets back

                    BBInSets[std::stoi(BB.getName())] = InSetLocal;
                    BBOutSets[std::stoi(BB.getName())] = OutSetLocal;

                }

                for (auto const& blockChanged : BBchanged) {
                    if (blockChanged.second == true) {
                        blocksChanging = true;
                        break;
                    }
                    else {
                        blocksChanging = false;
                    }
                }
            }

            // Do local analysis as to where variables are missing, based on the
            // InSet. Throw a message for the corresponding load.

            for (BasicBlock &BB : F) {

                // copy inSet to localSet for local analysis
                std::map<std::string, bool> localSet(BBInSets[std::stoi(BB.getName())]);

                //iterate all instructions
                for (Instruction &I : BB) {
                    // if we find a store, remove the variable from localSet
                    if (StoreInst *SI = dyn_cast<StoreInst>(&I)) {
                        Value *PtrOp = SI->getPointerOperand(); // Store target
                        if (PtrOp->hasName()) {
                            // remove the variable from the localSet
                            localSet.erase(PtrOp->getName());
                        }
                    }

                    // if we find a load
                    if (LoadInst *SI = dyn_cast<LoadInst>(&I)) {
                        Value *PtrOp = SI->getPointerOperand(); // Load target
                        if (PtrOp->hasName()) {
                            // check if the loaded variable is in the local set.

                            if (
                                localSet.find(PtrOp->getName()) !=
                                    localSet.end()
                            ) {
                                DebugLoc Loc = SI->getDebugLoc();

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

            for (BasicBlock &BB : F) {
                for (Instruction &I : BB) {
                    // if we find an allocation
                    if (AllocaInst *SI = dyn_cast<AllocaInst>(&I)) {
                        if (SI->hasName()) {

                            // intitialize variables to the predefined values for each type

                            if(SI->getAllocatedType()->isIntegerTy()) {
                                LLVMContext &context = SI->getContext();
                                Value *ten = ConstantInt::get(Type::getInt32Ty(context), 10, true);
                                StoreInst* store = new StoreInst(ten, SI);
                                store->insertAfter(SI);
                            }
                            if(SI->getAllocatedType()->isFloatTy()) {
                                LLVMContext &context = SI->getContext();
                                Value *twenty = ConstantFP::get(Type::getFloatTy(context), 20.0);
                                StoreInst* store = new StoreInst(twenty, SI);
                                store->insertAfter(SI);
                            }
                            if(SI->getAllocatedType()->isDoubleTy()) {
                                LLVMContext &context = SI->getContext();
                                Value *twenty = ConstantFP::get(Type::getDoubleTy(context), 30.0);
                                StoreInst* store = new StoreInst(twenty, SI);
                                store->insertAfter(SI);
                            }
                        }
                    }
                }
            }

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
