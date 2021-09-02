#include "TaskBase.h"


TaskBase::TaskBase(QObject *parent)
	: QThread(parent)
{
	restart = false;
	quit = false;
}

TaskBase::~TaskBase()
{
	toShutdown();
}

void TaskBase::toStartup()
{
	mutex.lock();
	restart = true;
	condition.wakeOne();
	mutex.unlock();

	start();
}

void TaskBase::toShutdown()
{
	mutex.lock();
	quit = true;
	condition.wakeOne();
	mutex.unlock();

	wait();
}

void TaskBase::run()
{
	while (!quit)
	{
		mutex.lock();
		if (!restart)
			condition.wait(&mutex);
		restart = false;
		mutex.unlock();

		doWork();
	}
}



