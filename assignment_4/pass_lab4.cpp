/* Name Surname */

#include <llvm/Pass.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/InstVisitor.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/InstIterator.h>
#include <llvm/IR/Constants.h>
#include <llvm/ADT/SmallVector.h>
#include <llvm/ADT/DenseSet.h>
#include <llvm/Support/raw_ostream.h>

#include <set>

using namespace llvm;

namespace {

    /* Represents state of a single Value. There are three possibilities:
     *  * undefined: Initial state. Unknown whether constant or not.
     *  * constant: Value is constant.
     *  * overdefined: Value is not constant. */
    class State {
    public:
        State() : Kind(UNDEFINED), Const(nullptr) {}

        bool isOverdefined() const { return Kind == OVERDEFINED; }
        bool isUndefined() const { return Kind == UNDEFINED; }
        bool isConstant() const { return Kind == CONSTANT; }
        Constant *getConstant() const {
            assert(isConstant());
            return Const;
        }

        void markOverdefined() { Kind = OVERDEFINED; }
        void markUndefined() { Kind = UNDEFINED; }
        void markConstant(Constant *C) {
            Kind = CONSTANT;
            Const = C;
        }

        void print(raw_ostream &O) const {
            switch (Kind) {
                case UNDEFINED: O << "undefined"; break;
                case OVERDEFINED: O << "overdefined"; break;
                case CONSTANT: O << "const " << *Const; break;
            }
        }

    private:
        enum {
            OVERDEFINED,
            UNDEFINED,
            CONSTANT
        } Kind;
        Constant *Const;
    };

    raw_ostream &operator<<(raw_ostream &O, const State &S) {
        S.print(O);
        return O;
    }

    class ConstPropPass : public FunctionPass, public InstVisitor<ConstPropPass> {
    public:
        static char ID;
        ConstPropPass() : FunctionPass(ID) {}

        virtual void getAnalysisUsage(AnalysisUsage &au) const {
            au.setPreservesAll();
        }

        virtual bool runOnFunction(Function &F) {
            // TODO Implement constant propagation

        /*    // Map from Values to their current State
            DenseMap<Value *, State> StateMap;
            // Worklist of instructions that need to be (re)processed
            SmallVector<Value *, 64> WorkList; */


          //std::set<Instruction*> WorkList;
            // store all the instructions
          for(inst_iterator I = inst_begin(F), EI = inst_end(F); I != EI; I++){
            WorkList.push_back(I.getInstructionIterator());
          }

          while(!WorkList.empty()){
            Instruction* I = WorkList.begin();
            WorkList.erase(WorkList.begin());

            State* oldS = &getValueState(I);
              errs() << "-----------------------" <<"\n";
              errs() << "debug info.  "  << "\n";
              errs() << *I << " -> " << *oldS << "\n";
            visit(I);
            State* newS = &getValueState(I);
              errs() << " new debug info.  "  << "\n";
              errs() << *I << " -> " << *oldS << "\n";
              errs() << "-----------------------" <<"\n";

            if(&newS != &oldS){
              for(User *U : I->users()){
                WorkList.insert(cast<Instruction>(U));
              }
            }
            WorkList.erase(I);
          //  I->eraseFromParent();
          }


      /*    while(!WorkList.empty()){
            Instruction *I = *WorkList.begin();
            State* oldS = &getValueState(I);
            WorkList.erase(WorkList.begin());

            if(!I->use_empty()){
              visit(I);
              State* newS = &getValueState(I);

              if(newS != oldS){
                for(User *U : I->users()){
                  WorkList.insert(cast<Instruction>(U));
                }
              }
            }
              WorkList.erase(I);
              I->eraseFromParent();
          }*/



            // First visit all instructions. The instructions also fill the
            // worklist if necessary.
          //  // visit all instuctions

            /// @todo revisit all instructions in the worklist until the worklist is empty

//             for (BasicBlock &BB : F) {
//                 for (Instruction &I : BB) {
//                 }
//             }


            printResults(F);
            return false;
        }


        /// @todo getUsers() // to get the users of an instruction. We will need this to add to the worklist.

        void visitPHINode(PHINode &Phi) {
            // TODO

            State* S = &getValueState(&Phi);

            /// @todo check if the state actually changes so that we can add to worklist

            for(int i = 0; i < Phi.getNumIncomingValues(); i++) {
                // get the State of the current incoming value
                State IncS = getValueState(Phi.getIncomingValue(i));

                if(IncS.isUndefined()) {
                    // this should not change the state of the phi node
                    // undefined stays undefined, constant stays constant and
                    // overdefined stays overdefined.
                }
                else if(IncS.isConstant()) {
                    if(S->isOverdefined()) {
                        // the state stays overdefined here
                    }
                    else if(S->isUndefined()) {
                        // the state changes to constant here
                        S->markConstant(IncS.getConstant());
                    }
                    else if(S->isConstant()) {
                        // if any const values are different, the result is overdefined

                        if(S->getConstant() != IncS.getConstant()) {
                            S->markOverdefined();
                        }
                    }

                }
                else if(IncS.isOverdefined()) {
                    // if any values are overdefined, the result is overdefined

                    if(!S->isOverdefined()) {
                        S->markOverdefined();
                    }
                }
            }

            /// @todo add users to worklist if the state changed.

        }

        void visitBinaryOperator(Instruction &I) {
            // TODO

            State* S = &getValueState(&I);


            State SOp0 = getValueState(I.getOperand(0));
            State SOp1 = getValueState(I.getOperand(1));

            if(SOp0.isOverdefined() || SOp1.isOverdefined()) {
                S->markOverdefined();
            }
            else {
                Constant* Op0 = nullptr;

                if (Constant::classof(I.getOperand(0))) {
                    Op0 = dyn_cast<Constant>(I.getOperand(0));
                }
                else if (SOp0.isConstant()) {
                    Op0 = SOp0.getConstant();
                }

                Constant* Op1 = nullptr;

                if (Constant::classof(I.getOperand(1))) {
                    Op1 = dyn_cast<Constant>(I.getOperand(1));
                }
                else if (SOp1.isConstant()) {
                    Op1 = SOp1.getConstant();
                }

                if (Op0 != nullptr && Op1 != nullptr) {
                    Constant* C = ConstantExpr::get(I.getOpcode(), Op0, Op1);

                    S->markConstant(C);
                }

                // nothing changes if we have an undefined
            }

        }

        void visitCmpInst(CmpInst &I) {
          State* S = &getValueState(&I);

          State SOp0 = getValueState(I.getOperand(0));
          State SOp1 = getValueState(I.getOperand(1));

          if(SOp0.isOverdefined() || SOp1.isOverdefined()) {
              S->markOverdefined();
          }
          else {
              Constant* Op0 = nullptr;

              if (Constant::classof(I.getOperand(0))) {
                  Op0 = dyn_cast<Constant>(I.getOperand(0));
              }
              else if (SOp0.isConstant()) {
                  Op0 = SOp0.getConstant();
              }

              Constant* Op1 = nullptr;

              if (Constant::classof(I.getOperand(1))) {
                  Op1 = dyn_cast<Constant>(I.getOperand(1));
              }
              else if (SOp1.isConstant()) {
                  Op1 = SOp1.getConstant();
              }

              if (Op0 != nullptr && Op1 != nullptr) {
                  Constant* C = ConstantExpr::getCompare(I.getPredicate(), Op0, Op1);

                  S->markConstant(C);
              }

              // nothing changes if we have an undefined
          }
        }

        void visitCastInst(CastInst &I) {
          State* S = &getValueState(&I);

          State SOp = getValueState(I.getOperand(0));

          if(SOp.isOverdefined()) {
              S->markOverdefined();
          }
          else {
              Constant* Op = nullptr;

              if (Constant::classof(I.getOperand(0))) {
                  Op = dyn_cast<Constant>(I.getOperand(0));
              }
              else if (SOp.isConstant()) {
                  Op = SOp.getConstant();
              }

              if (Op != nullptr) {
                  Constant* C = ConstantExpr::getCast(I.getOpcode(), Op, I.getType());

                  S->markConstant(C);
              }

              // nothing changes if we have an undefined
          }




        }

        void visitInstruction(Instruction &I) {
            // Fallback case

            // Instructions that are not explicitly handled are always overdefined.

            State S;
            S.markOverdefined();

            StateMap.insert({ &I, S });

        }

    private:
        /* Gets the current state of a Value. This method also lazily
         * initializes the state if there is no entry in the StateMap
         * for this Value yet. The initial value is CONSTANT for
         * Constants and UNDEFINED for everything else. */
        State &getValueState(Value *Val) {
            auto It = StateMap.insert({ Val, State() });
            State &S = It.first->second;

            if (!It.second) {
                // Already in map, return existing state
                return S;
            }

            if (Constant *C = dyn_cast<Constant>(Val)) {
                // Constants are constant...
                S.markConstant(C);
            }

            // Everything else is undefined (the default)
            return S;
        }

        /* Print the final result of the analysis. */
        void printResults(Function &F) {
          errs() << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" << "\n";
            for (BasicBlock &BB : F) {
                for (Instruction &I : BB) {
                    State S = getValueState(&I);
                    errs() << I << "\n    -> " << S << "\n";
                }
            }
        }

        // Map from Values to their current State
        DenseMap<Value *, State> StateMap;
        // Worklist of instructions that need to be (re)processed
        SmallVector<Value *, 64> WorkList;
    };

}

// Pass registration
char ConstPropPass::ID = 0;
static RegisterPass<ConstPropPass> X("const-prop-pass", "Constant propagation pass");
