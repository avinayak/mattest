#include <erl_nif.h>
#include <vector>
#include <algorithm>
#include <cstring>

class Matrix
{
public:
    Matrix(unsigned int rows, unsigned int cols) : rows(rows), cols(cols), data(rows * cols) {}

    int &operator()(unsigned int i, unsigned int j)
    {
        return data[i * cols + j];
    }

    const int &operator()(unsigned int i, unsigned int j) const
    {
        return data[i * cols + j];
    }

    unsigned int rows;
    unsigned int cols;
    std::vector<int> data;
};

static Matrix list_to_matrix(ErlNifEnv *env, ERL_NIF_TERM list_term, unsigned int rows, unsigned int cols)
{
    Matrix matrix(rows, cols);
    ERL_NIF_TERM row_term;

    for (unsigned int i = 0; i < rows; ++i)
    {
        enif_get_list_cell(env, list_term, &row_term, &list_term);
        ERL_NIF_TERM elem_term;
        for (unsigned int j = 0; j < cols; ++j)
        {
            enif_get_list_cell(env, row_term, &elem_term, &row_term);
            enif_get_int(env, elem_term, &matrix(i, j));
        }
    }

    return matrix;
}

static ERL_NIF_TERM multiply_matrices(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    unsigned int m, n, p;
    if (!enif_get_uint(env, argv[0], &m) || !enif_get_uint(env, argv[1], &n) || !enif_get_uint(env, argv[2], &p))
    {
        return enif_make_badarg(env);
    }

    Matrix matrix1 = list_to_matrix(env, argv[3], m, n);
    Matrix matrix2 = list_to_matrix(env, argv[4], n, p);
    Matrix result(m, p);

    // Multiply matrices
    for (unsigned int i = 0; i < m; ++i)
    {
        for (unsigned int j = 0; j < p; ++j)
        {
            int sum = 0;
            for (unsigned int k = 0; k < n; ++k)
            {
                sum += matrix1(i, k) * matrix2(k, j);
            }
            result(i, j) = sum;
        }
    }

    // Convert result to Erlang term
    ERL_NIF_TERM result_list = enif_make_list(env, 0);
    for (int i = m - 1; i >= 0; --i)
    {
        ERL_NIF_TERM row_list = enif_make_list(env, 0);
        for (int j = p - 1; j >= 0; --j)
        {
            row_list = enif_make_list_cell(env, enif_make_int(env, result(i, j)), row_list);
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