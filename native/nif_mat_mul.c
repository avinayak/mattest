#include <erl_nif.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Helper function to convert Erlang list to C array
static int* list_to_array(ErlNifEnv* env, ERL_NIF_TERM list, int size) {
    int* arr = (int*)enif_alloc(size * sizeof(int));
    ERL_NIF_TERM head, tail;
    int i = 0;
    while (enif_get_list_cell(env, list, &head, &tail)) {
        enif_get_int(env, head, &arr[i++]);
        list = tail;
    }
    return arr;
}

static ERL_NIF_TERM multiply_matrices(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    unsigned int m, n, p;
    if (!enif_get_uint(env, argv[0], &m) || !enif_get_uint(env, argv[1], &n) || !enif_get_uint(env, argv[2], &p)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM matrix1_term = argv[3], matrix2_term = argv[4];

    // Convert matrices to C arrays
    int* matrix1 = (int*)enif_alloc(m * n * sizeof(int));
    int* matrix2 = (int*)enif_alloc(n * p * sizeof(int));
    
    ERL_NIF_TERM row;
    for (unsigned int i = 0; i < m; i++) {
        enif_get_list_cell(env, matrix1_term, &row, &matrix1_term);
        int* row_arr = list_to_array(env, row, n);
        memcpy(matrix1 + i * n, row_arr, n * sizeof(int));
        enif_free(row_arr);
    }

    for (unsigned int i = 0; i < n; i++) {
        enif_get_list_cell(env, matrix2_term, &row, &matrix2_term);
        int* row_arr = list_to_array(env, row, p);
        for (unsigned int j = 0; j < p; j++) {
            matrix2[j * n + i] = row_arr[j];  // Transpose for better cache performance
        }
        enif_free(row_arr);
    }

    // Allocate memory for result matrix
    int* result = (int*)enif_alloc(m * p * sizeof(int));
    memset(result, 0, m * p * sizeof(int));

    // Multiply matrices
    for (unsigned int i = 0; i < m; i++) {
        for (unsigned int j = 0; j < p; j++) {
            int sum = 0;
            for (unsigned int k = 0; k < n; k++) {
                sum += matrix1[i * n + k] * matrix2[j * n + k];
            }
            result[i * p + j] = sum;
        }
    }

    // Convert result to Erlang term
    ERL_NIF_TERM result_list = enif_make_list(env, 0);
    for (int i = m - 1; i >= 0; i--) {
        ERL_NIF_TERM row_list = enif_make_list(env, 0);
        for (int j = p - 1; j >= 0; j--) {
            row_list = enif_make_list_cell(env, enif_make_int(env, result[i * p + j]), row_list);
        }
        result_list = enif_make_list_cell(env, row_list, result_list);
    }

    // Free allocated memory
    enif_free(matrix1);
    enif_free(matrix2);
    enif_free(result);

    return result_list;
}

static ErlNifFunc nif_funcs[] = {
    {"multiply_matrices", 5, multiply_matrices}
};

ERL_NIF_INIT(Elixir.NifSerialMatMul, nif_funcs, NULL, NULL, NULL, NULL)