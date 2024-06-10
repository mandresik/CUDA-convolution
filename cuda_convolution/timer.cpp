#include "Timer.h"

void Timer::start()
{
	start_time = std::chrono::steady_clock::now();
}

void Timer::stop(std::string measurement_title)
{
	end_time = std::chrono::steady_clock::now();
	std::cout << measurement_title << ": " <<
		std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count() << " ms (" <<
		std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time).count() << " microsec)\n";
}
