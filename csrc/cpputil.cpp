#include <iostream>
#include <vector>

extern "C" int hello()
{
    std::cout << "Hello from C++" << std::endl;
    std::vector<int> values = {1, 2, 3, 4, 5};
    for (int i = 0; i < values.size(); ++i)
    {
        std::cout << values[i] << ' ';
    }
    std::cout << '\n';
    return 0;
}

extern "C" int sum_ints(int *values, size_t size)
{
    int sum = 0;
    for (size_t i = 0; i < size; ++i)
    {
        sum += values[i];
    }
    return sum;
}

template <typename T>
struct Vector
{
    const T *xs;
    size_t size;
};

extern "C" double sum_vector(const Vector<double> *vec)
{
    double sum = 0;
    for (size_t i = 0; i < vec->size; ++i)
    {
        sum += vec->xs[i];
        // std::cout << sum << std::endl;
    }
    return sum;
}