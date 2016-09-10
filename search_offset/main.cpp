#include <boost/random/linear_feedback_shift.hpp>
#include <boost/random/uniform_01.hpp>
#include <boost/random/taus88.hpp>

#include <iostream>

struct coords
{
    coords(int32_t xx, int32_t yy) : x(xx), y(yy) {}
    
    uint32_t distance_squared(coords other)
    {
        auto dx = x - other.x;
        auto dy = y - other.y;
        return dx * dx + dy * dy;
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
    uint32_t min_dist_square = -1;
    for (uint32_t seed = 0; seed != -1; seed++)
    {
        auto c = get_shift(seed);
        auto ds = c.distance_squared(target);
        if (ds == 0) {
            std::cout << "found perfect seed " << seed << std::endl;
            continue;
        }
        if (ds < min_dist_square) {
            std::cout << "found better seed " << seed << " @ " << c.x << ", " << c.y << std::endl;
            min_dist_square = ds;
        }
    }
}

int main()
{
    find_seed(coords(2000, 2000));
}
