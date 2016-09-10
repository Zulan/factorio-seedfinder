#include <boost/random/linear_feedback_shift.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random/taus88.hpp>

#include <iostream>

struct coords
{
    coords(int32_t xx, int32_t yy) : x(xx), y(yy) {}
    
    uint32_t distance_squared(coords other) const
    {
        auto dx = x - other.x;
        auto dy = y - other.y;
        return dx * dx + dy * dy;
    }
    
    bool operator==(coords other) const
    {
        return x == other.x && y == other.y;
    }
    
    int32_t x, y;
};

coords get_shift(uint32_t seed)
{
    boost::random::taus88 e(seed);
    boost::random::uniform_01<> u;
    auto x = u(e) * 2000;
    auto y = u(e) * 2000;
    return coords(x, y);
}

void find_seed(coords target)
{
    std::cout << "seeds = {\n";
    for (uint32_t seed = 0; seed != -1; seed++)
    {
        auto c = get_shift(seed);
        if (c == target) {
            std::cout << seed << ",\n";
        }
    }
    std::cout << "}" << std::endl;
}

int main(int argc, const char** argv)
{
    assert(argc == 3);
    find_seed(coords(atol(argv[1]), atol(argv[2])));
}
