#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION

#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

#include <erl_nif.h>
#include <vector>
#include <algorithm>
#include <cstring>
#include <iostream>

using namespace std;

const char *shaderSource = R"(
#include <metal_stdlib>
using namespace metal;

kernel void matrixMultiply(
    device int* a [[ buffer(0) ]],
    device int* b [[ buffer(1) ]],
    device int* result [[ buffer(2) ]],
    constant uint& M [[ buffer(3) ]],
    constant uint& N [[ buffer(4) ]],
    constant uint& K [[ buffer(5) ]],
    uint2 id [[ thread_position_in_grid ]]) {
    if (id.x < N && id.y < M) {
        int sum = 0;
        for (uint i = 0; i < K; ++i) {
            sum += a[id.y * K + i] * b[i * N + id.x];
        }
        result[id.y * N + id.x] = sum;
    }
}
)";

void multiplyMatricesGPU(const vector<int> &a, const vector<int> &b, vector<int> &result, uint32_t M, uint32_t N, uint32_t K)
{
    NS::AutoreleasePool *pAutoreleasePool = NS::AutoreleasePool::alloc()->init();
    MTL::Device *device = MTL::CreateSystemDefaultDevice();
    MTL::CommandQueue *commandQueue = device->newCommandQueue();

    // Create buffers
    MTL::Buffer *bufferA = device->newBuffer(a.data(), sizeof(int) * a.size(), MTL::ResourceStorageModeShared);
    MTL::Buffer *bufferB = device->newBuffer(b.data(), sizeof(int) * b.size(), MTL::ResourceStorageModeShared);
    MTL::Buffer *bufferResult = device->newBuffer(result.data(), sizeof(int) * result.size(), MTL::ResourceStorageModeShared);
    MTL::Buffer *bufferM = device->newBuffer(&M, sizeof(uint32_t), MTL::ResourceStorageModeShared);
    MTL::Buffer *bufferN = device->newBuffer(&N, sizeof(uint32_t), MTL::ResourceStorageModeShared);
    MTL::Buffer *bufferK = device->newBuffer(&K, sizeof(uint32_t), MTL::ResourceStorageModeShared);

    // Compile shader
    MTL::CompileOptions *compileOptions = MTL::CompileOptions::alloc()->init();
    NS::String *source = NS::String::string(shaderSource, NS::UTF8StringEncoding);
    NS::Error *error = nullptr;
    MTL::Library *library = device->newLibrary(source, compileOptions, &error);

    if (!library)
    {
        std::cerr << "Failed to create library: " << error->localizedDescription()->utf8String() << std::endl;
        return;
    }

    MTL::Function *function = library->newFunction(NS::String::string("matrixMultiply", NS::UTF8StringEncoding));
    MTL::ComputePipelineState *computePipelineState = device->newComputePipelineState(function, &error);

    if (!computePipelineState)
    {
        std::cerr << "Failed to create pipeline state: " << error->localizedDescription()->utf8String() << std::endl;
        return;
    }

    // Create command buffer and compute command encoder
    MTL::CommandBuffer *commandBuffer = commandQueue->commandBuffer();
    MTL::ComputeCommandEncoder *computeEncoder = commandBuffer->computeCommandEncoder();
    computeEncoder->setComputePipelineState(computePipelineState);
    computeEncoder->setBuffer(bufferA, 0, 0);
    computeEncoder->setBuffer(bufferB, 0, 1);
    computeEncoder->setBuffer(bufferResult, 0, 2);
    computeEncoder->setBuffer(bufferM, 0, 3);
    computeEncoder->setBuffer(bufferN, 0, 4);
    computeEncoder->setBuffer(bufferK, 0, 5);

    // Set up thread groups
    MTL::Size gridSize = MTL::Size::Make(N, M, 1);
    MTL::Size threadGroupSize = MTL::Size::Make(16, 16, 1);
    computeEncoder->dispatchThreads(gridSize, threadGroupSize);

    // Finish encoding and commit the command buffer
    computeEncoder->endEncoding();
    commandBuffer->commit();
    commandBuffer->waitUntilCompleted();

    // Copy result from GPU to CPU
    memcpy(result.data(), bufferResult->contents(), sizeof(int) * result.size());
    computeEncoder->release();
    commandBuffer->release();
    computePipelineState->release();
    function->release();
    library->release();
    bufferA->release();
    bufferB->release();
    bufferResult->release();
    bufferM->release();
    bufferN->release();
    bufferK->release();
    commandQueue->release();
    device->release();
    // pAutoreleasePool->release();
}

static void list_to_matrix(ErlNifEnv *env, ERL_NIF_TERM list_term, unsigned int rows, unsigned int cols, vector<int> &matrix)
{
    ERL_NIF_TERM row_term;
    for (unsigned int i = 0; i < rows; ++i)
    {
        enif_get_list_cell(env, list_term, &row_term, &list_term);
        ERL_NIF_TERM elem_term;
        for (unsigned int j = 0; j < cols; ++j)
        {
            enif_get_list_cell(env, row_term, &elem_term, &row_term);
            int value;
            enif_get_int(env, elem_term, &value);
            matrix[i * cols + j] = value;
        }
    }
}

static ERL_NIF_TERM multiply_matrices(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    unsigned int m, n, p;
    if (!enif_get_uint(env, argv[0], &m) || !enif_get_uint(env, argv[1], &n) || !enif_get_uint(env, argv[2], &p))
    {
        return enif_make_badarg(env);
    }

    // Initialize matrices
    vector<int> matrix1(m * n);
    list_to_matrix(env, argv[3], m, n, matrix1);
    vector<int> matrix2(n * p);
    list_to_matrix(env, argv[4], n, p, matrix2);
    vector<int> result(m * p, 0);

    // Multiply matrices
    multiplyMatricesGPU(matrix1, matrix2, result, m, p, n);

    // Convert result to Erlang term
    ERL_NIF_TERM result_list = enif_make_list(env, 0);
    for (int i = m - 1; i >= 0; --i)
    {
        ERL_NIF_TERM row_list = enif_make_list(env, 0);
        for (int j = p - 1; j >= 0; --j)
        {
            row_list = enif_make_list_cell(env, enif_make_int(env, result[i * p + j]), row_list);
        }
        result_list = enif_make_list_cell(env, row_list, result_list);
    }

    return result_list;
}

static ErlNifFunc nif_funcs[] = {
    {"multiply_matrices", 5, multiply_matrices}};

extern "C"
{
    ERL_NIF_INIT(Elixir.NifMatMulMetal, nif_funcs, NULL, NULL, NULL, NULL)
}