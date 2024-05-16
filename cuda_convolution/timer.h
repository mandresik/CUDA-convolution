#pragma once

#include <chrono>
#include <xstring>
#include <iostream>

class Timer
{
private:
	std::chrono::steady_clock::time_point start_time;
	std::chrono::steady_clock::time_point end_time;

public:
	void start();
	void stop(std::string measurement_title);
};
