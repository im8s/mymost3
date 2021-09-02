#include "SMachine.h"

#include "ToolFunc.h"


SMachine::SMachine(QObject *parent)
	: QObject(parent)
{
	m_gsLock = new QMutex();

	setGStatus(GS_idle);
}

SMachine::~SMachine()
{
	delete m_gsLock;
}

void SMachine::doAction(GAction ga)
{
	GStatus& gs = m_gs;

	if (GA_Idled == ga)
	{
		if(GS_idle == gs)
			gs = GS_init;
	}
	else if (GA_InitedDone == ga)
	{
		if(GS_init == gs)
			gs = GS_connecting;
	}
	else if (GA_ConnectingDone == ga)
	{
		if(GS_connecting == gs)
			gs = GS_connected;
	}
	else if (GA_ConnectedDone == ga)
	{
		if(GS_connected == gs)
			gs = GS_logining;
	}
	else if (GA_LoginingDone == ga)
	{
		if(GS_logining == gs)
			gs = GS_logined;
	}
	else if (GA_LoginedDone == ga)
	{
		if(GS_logined == gs)
			gs = GS_fetchplayerlist;
	}
	else if (GS_fetchplayerlistDone == ga)
	{
		if(GS_fetchplayerlist == gs)
			gs = GS_fetchservertime;
	}
	else if (GA_ServerTimeDone == ga)
	{
		if(GS_fetchservertime == gs)
			gs = GS_fetchlothistory;
	}
	else if (GA_FetchLotHistoryDone == ga)
	{
		if(GS_fetchlothistory == gs)
			gs = GS_curlotperiods;
	}
	else if (GA_CurrentPeriodsDone == ga)
	{
		if(GS_curlotperiods == gs)
			gs = GS_openbet;
	}
	else if (GA_OpenBetDone == ga)
	{
		if(GS_openbet == gs)
			gs = GS_waitfordrawlot;
	}
	else if (GA_WaitForDrawLotDone == ga)
	{
		if(GS_waitfordrawlot == gs)
			gs = GS_closebet;
	}
	else if (GA_CloseBetDone == ga)
	{
		if(GS_closebet == gs)
			gs = GS_fetchlatestlot;
	}
	else if (GA_FetchLatestLotDone == ga)
	{
		if(GS_fetchlatestlot == gs)
			gs = GS_calculot;
	}
	else if (GA_PSCoreDone == ga)
	{
		if(GS_calculot == gs)
			gs = GS_curlotperiods;
	}
	else if (GA_DisconnectingDone == ga)
	{
		gs = GS_disconnected;
	}
	else if (GA_DisconnectedDone == ga)
	{
		gs = GS_idle;
	}
}

QString SMachine::getGSString(int gs)
{
	QString strMsg;

	if (GS_idle == gs)
	{
		strMsg = ZN_STR("ϵͳ��ת");
	}
	else if (GS_init == gs)
	{
		strMsg = ZN_STR("ͬ��������ʱ��");
	}
	else if (GS_connecting == gs)
	{
		strMsg = ZN_STR("�������ӷ�����");
	}
	else if (GS_connected == gs)
	{
		strMsg = ZN_STR("���ӷ������ɹ�");
	}
	else if (GS_logining == gs)
	{
		strMsg = ZN_STR("���ڵ�¼������");
	}
	else if (GS_logined == gs)
	{
		strMsg = ZN_STR("��¼�������ɹ�");
	}
	else if (GS_fetchservertime == gs)
	{
		strMsg = ZN_STR("ͬ��������ʱ��");
	}
	else if (GS_fetchlothistory == gs)
	{
		strMsg = ZN_STR("��ȡ��ʷ��¼");
	}
	else if (GS_curlotperiods == gs)
	{
		strMsg = ZN_STR("��ȡ������Ϣ");
	}
	else if (GS_openbet == gs)
	{
		strMsg = ZN_STR("�ȴ����̵���ʱ...");
	}
	else if (GS_waitfordrawlot == gs)
	{
		strMsg = ZN_STR("�ȴ���ע��...");
	}
	else if (GS_closebet == gs)
	{
		strMsg = ZN_STR("�ȴ����̵���ʱ...");
	}
	else if (GS_fetchlatestlot == gs)
	{
		strMsg = ZN_STR("��ȡ������Ϣ");
	}
	else if (GS_calculot == gs)
	{
		strMsg = ZN_STR("����ͳ���н���Ϣ...");
	}
	else if (GS_disconnecting == gs)
	{
		strMsg = ZN_STR("���ڶϿ�����������...");
	}
	else if (GS_disconnected == gs)
	{
		strMsg = ZN_STR("������������Ѿ��Ͽ�");
	}

	return strMsg;
}