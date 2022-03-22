#include <stdio.h>
#include <iostream>
#include <assert.h>
#include "circom.hpp"
#include "calcwit.hpp"
void triangleJumpVerifier_0_create(uint soffset,uint coffset,Circom_CalcWit* ctx,std::string componentName,uint componentFather);
void triangleJumpVerifier_0_run(uint ctx_index,Circom_CalcWit* ctx);
Circom_TemplateFunction _functionTable[1] = { 
triangleJumpVerifier_0_run };
uint get_main_input_signal_start() {return 2;}

uint get_main_input_signal_no() {return 7;}

uint get_total_signal_no() {return 9;}

uint get_number_of_components() {return 1;}

uint get_size_of_input_hashmap() {return 256;}

uint get_size_of_witness() {return 9;}

uint get_size_of_constants() {return 1;}

uint get_size_of_io_map() {return 0;}

// function declarations
// template declarations
void triangleJumpVerifier_0_create(uint soffset,uint coffset,Circom_CalcWit* ctx,std::string componentName,uint componentFather){
ctx->componentMemory[coffset].templateId = 0;
ctx->componentMemory[coffset].templateName = "triangleJumpVerifier";
ctx->componentMemory[coffset].signalStart = soffset;
ctx->componentMemory[coffset].inputCounter = 7;
ctx->componentMemory[coffset].componentName = componentName;
ctx->componentMemory[coffset].idFather = componentFather;
ctx->componentMemory[coffset].subcomponents = new uint[0];
}

void triangleJumpVerifier_0_run(uint ctx_index,Circom_CalcWit* ctx){
FrElement* signalValues = ctx->signalValues;
u64 mySignalStart = ctx->componentMemory[ctx_index].signalStart;
std::string myTemplateName = ctx->componentMemory[ctx_index].templateName;
std::string myComponentName = ctx->componentMemory[ctx_index].componentName;
u64 myFather = ctx->componentMemory[ctx_index].idFather;
u64 myId = ctx_index;
u32* mySubcomponents = ctx->componentMemory[ctx_index].subcomponents;
FrElement* circuitConstants = ctx->circuitConstants;
std::string* listOfTemplateMessages = ctx->listOfTemplateMessages;
FrElement expaux[1];
FrElement lvar[0];
uint sub_component_aux;
{
PFrElement aux_dest = &signalValues[mySignalStart + 0];
// load src
// end load src
Fr_copy(aux_dest,&circuitConstants[0]);
}
if (!Fr_isTrue(&circuitConstants[0])) std::cout << "Failed assert in template " << myTemplateName << " line 68. " <<  "Followed trace: " << ctx->getTrace(myId) << std::endl;
assert(Fr_isTrue(&circuitConstants[0]));
if (!Fr_isTrue(&circuitConstants[0])) std::cout << "Failed assert in template " << myTemplateName << " line 69. " <<  "Followed trace: " << ctx->getTrace(myId) << std::endl;
assert(Fr_isTrue(&circuitConstants[0]));
if (!Fr_isTrue(&circuitConstants[0])) std::cout << "Failed assert in template " << myTemplateName << " line 70. " <<  "Followed trace: " << ctx->getTrace(myId) << std::endl;
assert(Fr_isTrue(&circuitConstants[0]));
if (!Fr_isTrue(&circuitConstants[0])) std::cout << "Failed assert in template " << myTemplateName << " line 71. " <<  "Followed trace: " << ctx->getTrace(myId) << std::endl;
assert(Fr_isTrue(&circuitConstants[0]));
}

void run(Circom_CalcWit* ctx){
triangleJumpVerifier_0_create(1,0,ctx,"main",0);
triangleJumpVerifier_0_run(0,ctx);
}

