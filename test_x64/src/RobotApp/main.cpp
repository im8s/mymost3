#include "RobotDialog.h"
#include "RobotApplication.h"


int main(int argc, char *argv[])
{
	RobotApplication a(argc, argv);

	RobotDialog w;
    w.show();

    return a.exec();
}
